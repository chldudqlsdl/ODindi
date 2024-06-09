//
//  MapViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/21/24.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import MapKit

protocol MapViewModelType {
    var coordinate: BehaviorSubject<CLLocationCoordinate2D> { get }
    
    var region: Observable<MKCoordinateRegion> { get }
    var annotations: Observable<[MKPointAnnotation]> { get }
}

class MapViewModel: MapViewModelType {

    var disposeBag = DisposeBag()
    
    var coordinate = BehaviorSubject<CLLocationCoordinate2D>(value: CLLocationCoordinate2D())
        
    var region : Observable<MKCoordinateRegion>
    var annotations: Observable<[MKPointAnnotation]>
        
    init(_ currentCoordinate: CLLocationCoordinate2D) {
        
        coordinate.onNext(currentCoordinate)
        
        let currentCoordinate = Observable.just(currentCoordinate)
            .share()
        
        region = currentCoordinate
            .map({ coordinate in
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 20000, longitudinalMeters: 20000)
                return region
            })
        
        annotations = Observable.just(IndieCinema.list)
            .map({ indieCinemas in
                var cinemaAnnotations: [MKPointAnnotation] = []
                indieCinemas.forEach { indieCinema in
                    let annotation = MKPointAnnotation()
                    annotation.title = indieCinema.name
                    annotation.coordinate = indieCinema.coordinate
                    cinemaAnnotations.append(annotation)
                }
                return cinemaAnnotations
            })
    }
}




