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
    var fetchCinemaSchedule: AnyObserver<Void> { get }
    
    var nearCinemas: Observable<[IndieCinema]> { get }
    var cinemaSchedule: Observable<CinemaSchedule> { get }
    var cinemaCalendar: Observable<CinemaCalendar> { get }
}

class MainViewModel: MainViewModelType {
    let disposeBag = DisposeBag()
    var currentCoordinate: Observable<CLLocationCoordinate2D>
    
    // INPUT
    var fetchNearCinemas: AnyObserver<Void>
    var fetchCinemaSchedule: AnyObserver<Void>
    
    // OUTPUT
    var nearCinemas: Observable<[IndieCinema]>
    var cinemaSchedule: Observable<CinemaSchedule>
    var cinemaCalendar: Observable<CinemaCalendar>
    
    init(_ currentCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()){
        self.currentCoordinate = Observable.just(currentCoordinate)
        
        let fetchingNearCinemas = PublishSubject<Void>()
        let fetchingCinemaSchedule = PublishSubject<Void>()
        
        let tempNearCinemas = BehaviorSubject<[IndieCinema]>(value: [])
        let tempCinemaSchedule = BehaviorSubject<CinemaSchedule>(value: [])
        let tempCinemaCalendar = BehaviorSubject<CinemaCalendar>(value: CinemaCalendar())
        
        // INPUT
        fetchNearCinemas = fetchingNearCinemas.asObserver()
        
        fetchingNearCinemas
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
        
        fetchCinemaSchedule = fetchingCinemaSchedule.asObserver()
        
//        tempNearCinemas
//            .flatMap {
//                guard let nearestCinema = $0.first else {
//                    return Observable<CinemaSchedule>.empty()
//                }
//                let date = "2024-05-11"
//                return CinemaService.shared.fetchCinemaSchedule(cinema: nearestCinema, date: date)
//                    .take(1)
//            }
//            .subscribe(onNext: tempCinemaSchedule.onNext(_:))
//            .disposed(by: disposeBag)
        
        tempNearCinemas
            .flatMap {
                guard let nearestCinema = $0.first else {
                    return Observable<CinemaCalendar>.empty()
                }
                return CinemaService.shared.fetchCinemaCalendar(cinema: nearestCinema)
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: tempCinemaCalendar.onNext(_:))
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(tempNearCinemas, tempCinemaCalendar)
            .flatMap {
                guard let nearestCinema = $0.0.first else {
                    return Observable<CinemaSchedule>.empty()
                }
                let date = $0.1.businessDays.first ?? "2024-05-07"
                return CinemaService.shared.fetchCinemaSchedule(cinema: nearestCinema, date: date)
                    .take(1)
            }
            .subscribe(onNext: tempCinemaSchedule.onNext(_:))
            .disposed(by: disposeBag)
            
        
        // OUTPUT
        nearCinemas = tempNearCinemas
        cinemaSchedule = tempCinemaSchedule
        cinemaCalendar = tempCinemaCalendar
    }
}
