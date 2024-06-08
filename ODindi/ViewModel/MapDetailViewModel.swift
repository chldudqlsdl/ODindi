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
    
    var instaBtnTapped: PublishSubject<Void> { get }
    var mapBtnTapped: PublishSubject<Void> { get }
    
    var distance: BehaviorSubject<CLLocationDistance> { get }
    var cinemaData: BehaviorSubject<IndieCinema> { get }
    
    var urlRequest: PublishSubject<URLRequest> { get }
}

class MapDetailViewModel: MapDetailViewModelType {
    
    let disposeBag = DisposeBag()
    
    var instaBtnTapped = PublishSubject<Void>()
    var mapBtnTapped = PublishSubject<Void>()
    
    var distance = BehaviorSubject<CLLocationDistance>(value: 0.0)
    var cinemaData = BehaviorSubject<IndieCinema>(value: IndieCinema.list[0])
    
    var urlRequest = PublishSubject<URLRequest>()
    
    init(coordinate: CLLocationCoordinate2D, cinemaName: String ){
        
        Observable
            .just(cinemaName)
            .bind(onNext: { [weak self] cinemaName in
                let selectedCinemas = IndieCinema.list.filter { indieCinema in
                    indieCinema.name == cinemaName
                }
                guard let selectedCinema = selectedCinemas.first else { return }
                self?.cinemaData.onNext(selectedCinema)
            })
            .disposed(by: disposeBag)
        
        instaBtnTapped
            .withLatestFrom(cinemaData) { _, cinemaData in
                return cinemaData.instagram
            }
            .bind { [weak self] urlString in
                guard let URL = URL(string: urlString) else { return }
                let URLRequest = URLRequest(url: URL)
                self?.urlRequest.onNext(URLRequest)
            }
            .disposed(by: disposeBag)
        
        mapBtnTapped
            .withLatestFrom(cinemaData) { _, cinemaData in
                return cinemaData.map
            }
            .bind { [weak self] urlString in
                guard let URL = URL(string: urlString) else { return }
                let URLRequest = URLRequest(url: URL)
                self?.urlRequest.onNext(URLRequest)
            }
            .disposed(by: disposeBag)
    }
}
