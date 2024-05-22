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
    var region: Observable<MKCoordinateRegion> { get }
    var annotations: Observable<[MKPointAnnotation]> { get }
}

class MapViewModel: MapViewModelType {
    
    var disposeBag = DisposeBag()
        
    var region : Observable<MKCoordinateRegion>
    var annotations: Observable<[MKPointAnnotation]>
        
    init(_ currentCoordinate: CLLocationCoordinate2D) {
        
        let currentCoordinate = Observable.just(currentCoordinate)
            .share()
        
        region = currentCoordinate
            .map({ coordinate in
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
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




