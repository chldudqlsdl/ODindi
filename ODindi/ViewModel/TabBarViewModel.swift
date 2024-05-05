//
//  TabBarViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/5/24.
//

import Foundation
import RxSwift
import CoreLocation

protocol TabBarViewModelType {
    var checkLocationAuth: AnyObserver<Void> { get }
}

class TabBarViewModel: TabBarViewModelType {
    let disposeBag = DisposeBag()
    
    var checkLocationAuth: AnyObserver<Void>
    
    init(){
        let checkingAuth = PublishSubject<Void>()
        
        checkLocationAuth = checkingAuth.asObserver()
        
        checkingAuth
            .flatMap(LocationService.shared.requestLocation)
            .bind { print($0) }
            .disposed(by: disposeBag)
    }
    
}
