//
//  MovieService.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/26/24.
//

import Foundation
import RxSwift
import SwiftSoup

enum MovieDataError: Error {
    case error(String)
    case defaultError
    
    var message: String? {
        switch self {
        case let .error(msg):
            return msg
        case .defaultError:
            return "잠시 후에 다시 시도해주세요."
        }
    }
}

class MovieService {
    static var shared = MovieService()
    private init() {}
    
    func fetchMovieData(movieCode: String) -> Observable<Result<MovieData, MovieDataError>> {
        let urlString = "https://www.dtryx.com/movie/view.do?cgid=FE8EF4D2-F22D-4802-A39A-D58F23A29C1E&MovieCd=\(movieCode)"
        
        guard let url = URL(string: urlString) else {
            return .just(.failure(.error("유효하지 않은 URL")))
        }
                
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data in
                do {
                    var movieData = MovieData()
                    let html = String(data: data, encoding: .utf8)
                    guard let html = html else {
                        return .failure(.error("디코딩 Error"))
                    }
                    let doc: Document = try SwiftSoup.parse(html)
                    
                    movieData.title = try doc.select("div.info-box").select("h3.h3").first()!.text()
                    movieData.engTitle = try doc.select("div.info-box").select("h4.h4").first()!.text()
                    
                    let posterImgString = try doc.select("div.info-box").select("div.poster").select("img").first()!.attr("src")
                    movieData.poster = Poster(posterImgString)
                    
                    let etc : Elements = try doc.select("div.info-box").select("div.etc").select("span")
                    let ratingString = try etc.array()[0].text()
                    movieData.rating = Rating(from: ratingString)
                    movieData.releasedDate = try etc.array()[1].text()
                    movieData.genre = try etc.array()[2].text()
                    movieData.runningTime = try etc.array()[3].text()
                    
                    movieData.overView = try doc.select("div.info2").select("div.txt").select("span").text()
                    
                    let castLink : Elements = try doc.select("div.info2").select("div.txt").select("dd")
                    movieData.director = try castLink.array()[0].text()
                    movieData.cast = try castLink.array()[1].text()
                    
                    return .success(movieData)
                } catch {
                    return .failure(.error("크롤링 Error"))
                }
            }
            .catch { error in
                return .just(.failure(.error("유효하지 않은 URL")))
            }
            .observe(on: MainScheduler.instance)
    }
}
