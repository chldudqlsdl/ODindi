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
        
        // LocationService 에 위치 권한 허용 요청
        checkLocationAuth
            .flatMap(LocationService.shared.requestLocation)
            .take(1)
            .bind { _ in }
            .disposed(by: disposeBag)
        
        // LocationSerivce 에서 현재 위치의 좌표를 받아옴
        fetchCoordinate
            .flatMap { LocationService.shared.locationSubject }
            // 새로 받아온 좌표, 기존에 받은 좌표 사이의 거리를 측정해 이 거리가 300(m) 이상일 때만 그 값을 리턴(아닐시 nil 리턴)
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
