//
//  MovieViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/26/24.
//

import Foundation
import RxSwift

protocol MovieViewModelType {
    var movieData: BehaviorSubject<MovieData> { get }
    var errorMessage: BehaviorSubject<String> { get }
}

class MovieViewModel: MovieViewModelType {
    
    let disposeBag = DisposeBag()
    let movieData = BehaviorSubject<MovieData>(value: MovieData())
    let errorMessage = BehaviorSubject<String>(value: "")
    
    init(_ movieCode: String) {
    
        let movieDataResult = Observable
            .just(movieCode)
            .flatMap { movieCode in
                return MovieService.shared.fetchMovieData(movieCode: movieCode)
            }
            .share()
        
        let success = movieDataResult
            .map { result -> MovieData? in
                guard case .success(let value) = result else {
                    return nil
                }
                return value
            }
            .compactMap { $0 }
        
        let failure = movieDataResult
            .map { result -> String? in
                guard case .failure(let error) = result else {
                    return nil
                }
                return error.message
            }
            .compactMap { $0 }
        
        success
            .bind { [weak self] data in
                self?.movieData.onNext(data)
            }
            .disposed(by: disposeBag)
        
        failure
            .bind { [weak self] string in
                self?.errorMessage.onNext(string)
            }
            .disposed(by: disposeBag)
    }
}
