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
    
    func fetchCinemaSchedule(cinema: IndieCinema = IndieCinema.list[0], date: String) -> Observable<CinemaSchedule> {
        return Observable<CinemaSchedule>.create { emitter in
            let urlString = "https://www.dtryx.com/cinema/showseq_list.do?cgid=FE8EF4D2-F22D-4802-A39A-D58F23A29C1E&ssid=&tokn=&BrandCd=\(cinema.code[0])&CinemaCd=\(cinema.code[1])&PlaySDT=\(date)"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
                if let error = error {
                    emitter.onError(error)
                }
                guard let data = data else {
                    let response = response as! HTTPURLResponse
                    let error = NSError(domain: "No Data", code: response.statusCode)
                    emitter.onError(error)
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
    
    func fetchCinemaCalendar(cinema: IndieCinema = IndieCinema.list[0]) -> Observable<CinemaCalendar> {
            
            return Observable<CinemaCalendar>.create { emitter in
                
                let urlString = "https://www.dtryx.com/cinema/main.do?cgid=FE8EF4D2-F22D-4802-A39A-D58F23A29C1E&BrandCd=\(cinema.code[0])&CinemaCd=\(cinema.code[1])"
                var cinemaCalendar = CinemaCalendar()
                do {
                    let html = try String(contentsOf: URL(string: urlString)!, encoding: .utf8)
                    let doc: Document = try SwiftSoup.parse(html)
                    let elements = try doc.select("div.main-schedule").select("div.swiper-slide").select("a")
                    
                    for element in elements.array() {
                        if try element.attr("class") == "btnDay disabled" {
                            cinemaCalendar.holidays.append(try element.attr("data-dt"))
                        } else {
                            cinemaCalendar.businessDays.append(try element.attr("data-dt"))
                        }
                        cinemaCalendar.alldays.append(try element.attr("data-dt"))
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
                emitter.onNext(cinemaCalendar)
                return Disposables.create()
            }
    }
}

