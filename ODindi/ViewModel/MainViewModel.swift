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
    
    var fetchNearCinemas: AnyObserver<Void> { get }
    var didCinemaSelected: AnyObserver<Int> { get }
    
    var nearCinemas: Observable<[IndieCinema]> { get }
    var selectedCinemaCalendar: Observable<CinemaCalendar> { get }
    
    var isLoading: Observable<Bool> { get }
}

class MainViewModel: MainViewModelType {
    let disposeBag = DisposeBag()
    var currentCoordinate: Observable<CLLocationCoordinate2D>
    
    // INPUT
    var fetchNearCinemas: AnyObserver<Void>
    var didCinemaSelected: AnyObserver<Int>
    
    // OUTPUT
    var nearCinemas: Observable<[IndieCinema]>
    var selectedCinemaCalendar: Observable<CinemaCalendar>
    var isLoading: Observable<Bool>
    
    init(_ currentCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()){
        self.currentCoordinate = Observable.just(currentCoordinate)
        
        let fetchingNearCinemas = PublishSubject<Void>()
        let fetchingSelectedCinemaCalendar = BehaviorSubject<Int>(value: 0)
        
        let tempNearCinemas = BehaviorSubject<[IndieCinema]>(value: [])
        let tempSelectedCinemaCalendar = BehaviorSubject<CinemaCalendar>(value: CinemaCalendar())
        let loading = BehaviorSubject<Bool>(value: false)
        
        // INPUT
        fetchNearCinemas = fetchingNearCinemas.asObserver()
        
        fetchingNearCinemas
            .do(onNext: { _ in loading.onNext(true) })
            .withLatestFrom(self.currentCoordinate)
            .subscribe(onNext: { currentCoordinate in
                let sortedCinemaListByDistance = IndieCinema.list.sorted { cinema1, cinema2 in
                    let distance1 = currentCoordinate.distance(to: cinema1.location)
                    let distance2 = currentCoordinate.distance(to: cinema2.location)
                    return distance1 < distance2
                }
                tempNearCinemas.onNext(Array(sortedCinemaListByDistance.prefix(3)))
            })
            .disposed(by: disposeBag)
        
        didCinemaSelected = fetchingSelectedCinemaCalendar.asObserver()
        
        fetchingSelectedCinemaCalendar
            .withLatestFrom(tempNearCinemas) { index, cinemas -> IndieCinema? in
                guard !cinemas.isEmpty else {
                    return nil
                }
                return cinemas[index]
            }
            .flatMap { cinema in
                guard let cinema = cinema else { return Observable<CinemaCalendar>.empty() }
                return CinemaService.shared.fetchCinemaCalendar(cinema: cinema)
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { _ in loading.onNext(false) })
            .subscribe(onNext: { calendar in
                print(calendar.businessDays)
                tempSelectedCinemaCalendar.onNext(calendar)
            })
            .disposed(by: disposeBag)
            
        
        // OUTPUT
        nearCinemas = tempNearCinemas
        selectedCinemaCalendar = tempSelectedCinemaCalendar
        isLoading = loading.distinctUntilChanged()
    }
}
