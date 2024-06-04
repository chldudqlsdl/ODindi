//
//  BookmarkViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/3/24.
//

import Foundation
import RxSwift

protocol BookmarkViewModelType {
    var viewWillAppear: PublishSubject<Void> { get }
    var viewDidAppear: PublishSubject<Void> { get }
    
    var bookmarkedMovieDatas: BehaviorSubject<[WatchLater]> { get }
}

class BookmarkViewModel: BookmarkViewModelType {
    
    let disposeBag = DisposeBag()
    
    var viewWillAppear = PublishSubject<Void>()
    var viewDidAppear = PublishSubject<Void>()
    
    var bookmarkedMovieDatas = BehaviorSubject<[WatchLater]>(value: [])
    
    init() {
        
        viewWillAppear
            .flatMap { _ -> Observable<[WatchLater]> in
                return Observable.create { observer in
                    let movieData = DataBaseManager.shared.read()
                    observer.onNext(Array(movieData))
                    observer.onCompleted()
                    return Disposables.create()
                }
            }
            .bind { [weak self] movieData in
                self?.bookmarkedMovieDatas.onNext(movieData)
            }
            .disposed(by: disposeBag)
        
        viewDidAppear
            .bind { _ in
                DataBaseManager.shared.delete()
            }
            .disposed(by: disposeBag)
    }
}
