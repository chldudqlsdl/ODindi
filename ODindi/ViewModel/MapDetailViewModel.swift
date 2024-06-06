//
//  MapDetailViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/5/24.
//

import Foundation
import CoreLocation
import RxSwift

protocol MapDetailViewModelType {
    
    var distance: BehaviorSubject<CLLocationDistance>{ get }
    var cinemaData: BehaviorSubject<IndieCinema> { get }
    
}

class MapDetailViewModel: MapDetailViewModelType {
    
    let disposeBag = DisposeBag()
    
    var distance = BehaviorSubject<CLLocationDistance>(value: 0.0)
    var cinemaData = BehaviorSubject<IndieCinema>(value: IndieCinema.list[0])
    
    init(coordinate: CLLocationCoordinate2D, cinemaName: String ){
        
        Observable
            .just(cinemaName)
            .bind(onNext: { [weak self] cinemaName in
                let selectedCinemas = IndieCinema.list.filter { indieCinema in
                    indieCinema.name == cinemaName
                }
                guard let selectedCinema = selectedCinemas.first else { return }
                print(selectedCinema)
                self?.cinemaData.onNext(selectedCinema)
            })
            .disposed(by: disposeBag)
    }
}
