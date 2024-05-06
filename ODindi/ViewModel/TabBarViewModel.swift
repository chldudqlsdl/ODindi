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
    var fetchCoordinate: AnyObserver<Void> { get }
    
    var currentCoordinate: Observable<CLLocationCoordinate2D> { get }
}

class TabBarViewModel: TabBarViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT
    
    var checkLocationAuth: AnyObserver<Void>
    var fetchCoordinate: AnyObserver<Void>
    
    // OUTPUT
    
    var currentCoordinate: Observable<CLLocationCoordinate2D>
    
    init(){
        let checkingAuth = PublishSubject<Void>()
        let fetchingCoordinate = PublishSubject<Void>()
        
        let tempCoordinate = BehaviorSubject<CLLocationCoordinate2D>(value: CLLocationCoordinate2D())
        
        // INPUT
        
        checkLocationAuth = checkingAuth.asObserver()
        
        checkingAuth
            .flatMap(LocationService.shared.requestLocation)
            .bind { print($0) }
            .disposed(by: disposeBag)
        
        fetchCoordinate = fetchingCoordinate.asObserver()
        
        fetchingCoordinate
            .flatMap { _ in
                LocationService.shared.locationSubject
                    .compactMap { $0 }
                    .take(1)
            }
            .subscribe(onNext: tempCoordinate.onNext(_:))
            .disposed(by: disposeBag)
        
        // OUTPUT
        
        currentCoordinate = tempCoordinate
    }
    
}
