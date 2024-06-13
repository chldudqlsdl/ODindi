//
//  MovieCellViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/31/24.
//

import Foundation
import RxSwift

protocol MovieCellViewModelType {
    
    var movieSchedule: BehaviorSubject<MovieSchedule> { get }
    var saveWatchLater: PublishSubject<MovieSchedule> { get }
    
}

class MovieCellViewModel: MovieCellViewModelType {
    
    let disposeBag = DisposeBag()
    
    var movieSchedule = BehaviorSubject<MovieSchedule>(value: MovieSchedule(info: MovieScheduleInfo(MovieNm: "", Url: "", StartTime: "", MovieCd: "")))
    var saveWatchLater = PublishSubject<MovieSchedule>()
    
    init(_ movieSchedule: MovieSchedule) {
        
        Observable
            .just(movieSchedule)
            .map({ movieSchedule in
                var newMovieSchedule = movieSchedule
                // RealmDB 의 보고싶어요 여부 체크해서 프로퍼티 바꿔주기
                for watchLater in DataBaseManager.shared.read() {
                    if watchLater.movieCode == movieSchedule.code {
                        newMovieSchedule.watchLater = true
                        break
                    }
                }
                return newMovieSchedule
            })
            .bind { [weak self] movieSchedule in
                self?.movieSchedule.onNext(movieSchedule)
            }
            .disposed(by: disposeBag)
        
        saveWatchLater
            .bind { [weak self] movieSchedule in
                
                var newMovieSchedule = movieSchedule
                newMovieSchedule.watchLater.toggle()
                
                // 보고싶어요의 불값에 따라 보고싶어요에서 삭제할건지, 저장할건지 결정
                if movieSchedule.watchLater {
                    DataBaseManager.shared.tempDelete(movieSchedule.code)
                } else {
                    DataBaseManager.shared.write(movieSchedule.code)
                }
                self?.movieSchedule.onNext(newMovieSchedule)
            }
            .disposed(by: disposeBag)
        
    }
    
}
