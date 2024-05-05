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
    
    func requestLocation() -> Observable<CLAuthorizationStatus> {
        return Observable<CLAuthorizationStatus>
            .deferred { [weak self] in
                guard let ss = self else { return .empty() }
                ss.locationManager.requestWhenInUseAuthorization()
                return ss.locationManager.rx.didChangeAuthorization
                    .map { $1 }
                    .filter { $0 != .notDetermined }
                    .do(onNext: { _ in ss.locationManager.startUpdatingLocation() })
                    .take(1)
            }
    }
}
