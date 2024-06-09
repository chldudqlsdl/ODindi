//
//  TabBarViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/5/24.
//

import Foundation
import RxSwift
import CoreLocation
import RxRelay

protocol MainTabBarViewModelType {
    var checkLocationAuth: PublishSubject<Void> { get }
    var fetchCoordinate: PublishSubject<Void> { get }
        
    var currentCoordinate: BehaviorSubject<CLLocationCoordinate2D> { get }
}

class MainTabBarViewModel: MainTabBarViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT
    var checkLocationAuth = PublishSubject<Void>()
    var fetchCoordinate = PublishSubject<Void>()
    
    // OUTPUT
    var currentCoordinate = BehaviorSubject<CLLocationCoordinate2D>(value: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    init(){
                
        checkLocationAuth
            .flatMap(LocationService.shared.requestLocation)
            .take(1)
            .bind { _ in }
            .disposed(by: disposeBag)
        
        fetchCoordinate
            .flatMap { LocationService.shared.locationSubject }
            .withLatestFrom(currentCoordinate, resultSelector: { (newCoordinate, oldCoordinate) -> CLLocationCoordinate2D? in
                if oldCoordinate.latitude == 0 {
                    return newCoordinate
                }
                if oldCoordinate.distance(to: newCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)) > 300 {
                    return newCoordinate
                } else {
                    return nil
                }
            })
            .compactMap { $0 }
            .bind(to: currentCoordinate)
            .disposed(by: disposeBag)
    }
}
