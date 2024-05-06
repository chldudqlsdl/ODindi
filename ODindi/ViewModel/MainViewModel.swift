//
//  MainViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/6/24.
//

import Foundation
import RxSwift
import CoreLocation

protocol MainViewModelType {
    var currentCoordinate: Observable<CLLocationCoordinate2D> { get }
}

class MainViewModel: MainViewModelType {
    var currentCoordinate: Observable<CLLocationCoordinate2D>
    
    init(_ currentCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()){
        self.currentCoordinate = Observable.just(currentCoordinate)
    }
}
