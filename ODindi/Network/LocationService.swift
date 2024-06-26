//
//  LocationService.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/5/24.
//

import Foundation
import RxSwift
import CoreLocation
import RxCoreLocation

class LocationService {
    static let shared = LocationService()
    let disposeBag = DisposeBag()
    
    // 현재 위치 좌표를 저장하는 Subject
    let locationSubject = BehaviorSubject<CLLocationCoordinate2D?>(value: nil)
    let locationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        return locationManager
    }()
    
    private init() {
        self.locationManager.rx.didUpdateLocations
            .compactMap {$0.locations.last?.coordinate}
            .bind(to: locationSubject)
            .disposed(by: disposeBag)
        self.locationManager.startUpdatingLocation()
    }
    
    func requestLocation() -> Observable<Void> {
        return Observable<Void>
            .deferred { [weak self] in
                guard let ls = self else { return .empty() }
                ls.locationManager.requestWhenInUseAuthorization()
                return Observable.just(())
        }
    }
}

