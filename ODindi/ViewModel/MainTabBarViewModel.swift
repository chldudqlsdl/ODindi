//
//  TabBarViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/5/24.
//

import Foundation
import RxSwift
import CoreLocation

protocol MainTabBarViewModelType {
    var checkLocationAuth: PublishSubject<Void> { get }
    var fetchCoordinate: PublishSubject<Void> { get }
    
    var currentCoordinate: PublishSubject<CLLocationCoordinate2D> { get }
}

class MainTabBarViewModel: MainTabBarViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT
    var checkLocationAuth = PublishSubject<Void>()
    var fetchCoordinate = PublishSubject<Void>()
    
    // OUTPUT
    var currentCoordinate = PublishSubject<CLLocationCoordinate2D>()
    
    init(){
                
        checkLocationAuth
            .flatMap(LocationService.shared.requestLocation)
            .take(1)
            .bind { _ in }
            .disposed(by: disposeBag)
        
        fetchCoordinate
            .flatMap { LocationService.shared.locationSubject }
            .compactMap { $0 }
            .take(1)
            .bind(to: currentCoordinate)
            .disposed(by: disposeBag)
    }
}

