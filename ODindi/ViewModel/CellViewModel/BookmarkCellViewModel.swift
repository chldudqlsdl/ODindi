//
//  BookmarkCellViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/3/24.
//

import Foundation
import RxSwift

protocol BookmarkCellViewModelType {
    var movieData: BehaviorSubject<MovieData> { get }
}

class BookmarkCellViewModel: BookmarkCellViewModelType{
    
    let disposeBag = DisposeBag()
    var movieData = BehaviorSubject<MovieData>(value: MovieData())
    
    init(movieCode: String) {
        
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
            .compactMap {$0}
        
        let failure = movieDataResult
            .map { result -> String? in
                guard case .failure(let error) = result else {
                    return nil
                }
                return error.message
            }
            .compactMap {$0}
        
        success
            .bind { [weak self] movieData in
                self?.movieData.onNext(movieData)
            }
            .disposed(by: disposeBag)
        
    }
}
