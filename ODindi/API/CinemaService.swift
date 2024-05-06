//
//  CinemaService.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/6/24.
//

import Foundation
import RxSwift

class CinemaService {
    static let shared = CinemaService()
    private init() {}
    
    func fetchCinemaSchedule(cinema: IndieCinema, date: String) -> Observable<CinemaSchedule> {
        print("Hi")
        return Observable<CinemaSchedule>.create { emitter in
            let urlString = "https://www.dtryx.com/cinema/showseq_list.do?cgid=FE8EF4D2-F22D-4802-A39A-D58F23A29C1E&ssid=&tokn=&BrandCd=\(cinema.code[0])&CinemaCd=\(cinema.code[1])&PlaySDT=\(date)"
            print(urlString)
            
            URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
                if let error = error {
                    print("에러")
                    emitter.onError(error)
                }
                guard let data = data else {
                    let response = response as! HTTPURLResponse
                    let error = NSError(domain: "No Data", code: response.statusCode)
                    print("에러")
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
                    print(cinemaSchedule)
                    emitter.onNext(cinemaSchedule)
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
}
