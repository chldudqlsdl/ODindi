//
//  MovieService.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/26/24.
//

import Foundation
import RxSwift

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
    
//    func fetchMovieData(movieCode: String) -> Observable<Result<MovieData, MovieDataError>> {
//        
//    }
}
