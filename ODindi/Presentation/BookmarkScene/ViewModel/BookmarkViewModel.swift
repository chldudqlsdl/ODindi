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
    
    var deleteBookmarkedMovie: PublishSubject<String> { get }
    
    var bookmarkedMovieDatas: BehaviorSubject<[WatchLater]> { get }
}

class BookmarkViewModel: BookmarkViewModelType {
    
    let disposeBag = DisposeBag()
    
    var viewWillAppear = PublishSubject<Void>()
    var viewDidAppear = PublishSubject<Void>()
    
    var deleteBookmarkedMovie = PublishSubject<String>()
    
    var bookmarkedMovieDatas = BehaviorSubject<[WatchLater]>(value: [])
    
    init() {
        
        // 보고싶어요한 영화 리스트를 bookmarkedMovieDatas 에 넘겨주기
        viewWillAppear
            .bind { [weak self] _ in
                let movieData = Array(DataBaseManager.shared.read())
                self?.bookmarkedMovieDatas.onNext(movieData)
            }
            .disposed(by: disposeBag)
        
        // 뷰가 Appear 되면 데이터 삭제 요청(isDeleted 가 true 인 값만 삭제됨)
        viewDidAppear
            .bind { _ in
                DataBaseManager.shared.delete()
            }
            .disposed(by: disposeBag)
        
        deleteBookmarkedMovie
            .bind { [weak self] movieCode in
                // 북마크 버튼이 눌리면(유저의 삭제요청) tempDelete 를 해서 인스턴스 isDeleted 프로퍼티만 true 로 변경
                // 인스턴스 자체를 삭제해버리면, 해당 인스턴스에는 절대 접근할 수 없는데,
                // DiffableDataSource 는 바뀐 전후 데이터를 비교해서 화면을 업데이트하므로 삭제된 인스턴스에 접근하려고 해서 크래쉬발생
                DataBaseManager.shared.tempDelete(movieCode)
                self?.viewWillAppear.onNext(())
            }
            .disposed(by: disposeBag)
    }
}
