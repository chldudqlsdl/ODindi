//
//  CinemaService.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/6/24.
//

import Foundation
import RxSwift
import SwiftSoup

class CinemaService {
    static let shared = CinemaService()
    private init() {}
    
    // 영화관과 날짜를 파라미터로 받아 당일의 상영스케줄 Observable 을 리턴하는 메서드
    func fetchCinemaSchedule(cinema: IndieCinema, date: String) -> Observable<CinemaSchedule> {
        return Observable<CinemaSchedule>.create { emitter in
            let urlString = "https://www.dtryx.com/cinema/showseq_list.do?cgid=FE8EF4D2-F22D-4802-A39A-D58F23A29C1E&ssid=&tokn=&BrandCd=\(cinema.code[0])&CinemaCd=\(cinema.code[1])&PlaySDT=\(date)"
            
            guard let url = URL(string: urlString) else {
                let error = NSError(domain: "Invalid URL", code: 0)
                emitter.onError(error)
                return Disposables.create()
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    emitter.onError(error)
                    return
                }
                guard let data = data else {
                    if let response = response as? HTTPURLResponse {
                        let error = NSError(domain: "No Data", code: response.statusCode)
                        emitter.onError(error)
                    } else {
                        let error = NSError(domain: "No Data", code: 0)
                        emitter.onError(error)
                    }
                    return
                }
                if let movieScheduleInfos = self.ParseJSON(data: data) {
                    var cinemaSchedule: [MovieSchedule] = []
                    for info in movieScheduleInfos {
                        if let firstIndex = cinemaSchedule.firstIndex(where: {$0.name == info.MovieNm}) {
                            cinemaSchedule[firstIndex].timeTable.append(info.StartTime)
                        } else {
                            cinemaSchedule.append(MovieSchedule(info: info))
                        }
                    }
                    let sortedCinemaSchedule = cinemaSchedule.sorted {
                        return $0.timeTable.first ?? "0" < $1.timeTable.first ?? "1"
                    }
                    emitter.onNext(sortedCinemaSchedule)
                } else {
                    let error = NSError(domain: "Parsing Error", code: 0)
                    emitter.onError(error)
                }
            }.resume()
            
            return Disposables.create()
        }
    }
    
    func ParseJSON(data: Data) -> [MovieScheduleInfo]? {
        do {
            let response = try JSONDecoder().decode(MovieScheduleData.self, from: data)
            return response.Showseqlist
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // 영화관을 파라미터로 받아 해당 영화관의 영업일(휴일여부 포함) Observable 을 리턴하는 메서드
    func fetchCinemaCalendar(cinema: IndieCinema = IndieCinema.list[0]) -> Observable<CinemaCalendar> {
        return Observable<CinemaCalendar>.create { emitter in
            let urlString = "https://www.dtryx.com/cinema/main.do?cgid=FE8EF4D2-F22D-4802-A39A-D58F23A29C1E&BrandCd=\(cinema.code[0])&CinemaCd=\(cinema.code[1])"
            
            print("Fetching URL: \(urlString)")
            
            guard let url = URL(string: urlString) else {
                let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
                emitter.onError(error)
                return Disposables.create()
            }
            
            var cinemaCalendar = CinemaCalendar()
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    emitter.onError(error)
                    return
                }
                guard let data = data else {
                    let error = NSError(domain: "No Data", code: 0, userInfo: nil)
                    emitter.onError(error)
                    return
                }
                do {
                    let html = String(data: data, encoding: .utf8) ?? ""
                    
                    let doc: Document = try SwiftSoup.parse(html)
                    let elements = try doc.select("div.main-schedule").select("div.swiper-slide").select("a")
                    
                    for element in elements.array() {
                        let date = try element.attr("data-dt")
                        if try element.attr("class") == "btnDay disabled" {
                            cinemaCalendar.holidays.append(date)
                        } else {
                            cinemaCalendar.businessDays.append(date)
                        }
                        cinemaCalendar.alldays.append(date)
                    }
                    
                    cinemaCalendar.alldays.forEach { dateString in
                        if cinemaCalendar.businessDays.contains(dateString) {
                            cinemaCalendar.businessDayStatusArray.append(BusinessDayStatus(dateString: dateString, isBusinessDay: true))
                        } else {
                            cinemaCalendar.businessDayStatusArray.append(BusinessDayStatus(dateString: dateString, isBusinessDay: false))
                        }
                    }
                    
                    emitter.onNext(cinemaCalendar)
                } catch {
                    print("HTML Parsing Error: \(error.localizedDescription)")
                    emitter.onError(error)
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}



//// 영화관을 파라미터로 받아 해당 영화관의 영업일(휴일여부 포함) Observable 을 리턴하는 메서드
//func fetchCinemaCalendar(cinema: IndieCinema = IndieCinema.list[0]) -> Observable<CinemaCalendar> {
//    return Observable<CinemaCalendar>.create { emitter in
//        let urlString = "https://www.dtryx.com/cinema/main.do?cgid=FE8EF4D2-F22D-4802-A39A-D58F23A29C1E&BrandCd=\(cinema.code[0])&CinemaCd=\(cinema.code[1])"
//        
//        print(urlString)
//        
//        guard let url = URL(string: urlString) else {
//            let error = NSError(domain: "Invalid URL", code: 0)
//            emitter.onError(error)
//            return Disposables.create()
//        }
//        
//        var cinemaCalendar = CinemaCalendar()
//        
//        do {
//            let html = try String(contentsOf: url, encoding: .utf8)
//            let doc: Document = try SwiftSoup.parse(html)
//            let elements = try doc.select("div.main-schedule").select("div.swiper-slide").select("a")
//            
//            for element in elements.array() {
//                let date = try element.attr("data-dt")
//                if try element.attr("class") == "btnDay disabled" {
//                    cinemaCalendar.holidays.append(date)
//                } else {
//                    cinemaCalendar.businessDays.append(date)
//                }
//                cinemaCalendar.alldays.append(date)
//            }
//            
//            cinemaCalendar.alldays.forEach { dateString in
//                if cinemaCalendar.businessDays.contains(dateString) {
//                    cinemaCalendar.businessDayStatusArray.append(BusinessDayStatus(dateString: dateString, isBusinessDay: true))
//                } else {
//                    cinemaCalendar.businessDayStatusArray.append(BusinessDayStatus(dateString: dateString, isBusinessDay: false))
//                }
//            }
//            
//            emitter.onNext(cinemaCalendar)
//        } catch {
//            print(error.localizedDescription)
//            emitter.onError(error)
//        }
//        
//        return Disposables.create()
//    }
//}
