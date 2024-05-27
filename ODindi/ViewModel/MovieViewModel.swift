//
//  MovieViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/26/24.
//

import Foundation
import RxSwift

protocol MovieViewModelType {
//    var movieData: BehaviorSubject<MovieData> { get }
}

class MovieViewModel: MovieViewModelType {
    
//    var movieData = BehaviorSubject<MovieData>(value:)
    
    init(_ movieCode: String) {
    
        let movieDataResult = Observable
            .just(movieCode)
            .map { code in
                print(code)
            }
            .bind { _ in
            }
    }
}
