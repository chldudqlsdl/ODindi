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
    var didDateSelected: AnyObserver<Int> { get }
    
    var nearCinemas: Observable<[IndieCinema]> { get }
    var selectedCinema: Observable<IndieCinema> { get }
    var selectedCinemaCalendar: Observable<CinemaCalendar> { get }
    var selectedDateMovieSchedule: Observable<CinemaSchedule> { get }
    
    var isLoading: Observable<Bool> { get }
}

class MainViewModel: MainViewModelType {
    let disposeBag = DisposeBag()
    var currentCoordinate: Observable<CLLocationCoordinate2D>
    
    // INPUT
    var fetchNearCinemas: AnyObserver<Void>
    var didCinemaSelected: AnyObserver<Int>
    var didDateSelected: AnyObserver<Int>
    
    // OUTPUT
    var nearCinemas: Observable<[IndieCinema]>
    var selectedCinema: Observable<IndieCinema>
    var selectedCinemaCalendar: Observable<CinemaCalendar>
    var selectedDateMovieSchedule: Observable<CinemaSchedule>
    
    var isLoading: Observable<Bool>
    
    init(_ currentCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()){
        self.currentCoordinate = Observable.just(currentCoordinate)
        
        let fetchingNearCinemas = PublishSubject<Void>()
        let fetchingSelectedCinemaCalendar = BehaviorSubject<Int>(value: 0)
        let fetchingSelectedDateMovieSchedule = BehaviorSubject<Int>(value: 0)
        
        let tempNearCinemas = BehaviorSubject<[IndieCinema]>(value: [])
        let tempSelectedCinema = BehaviorSubject<IndieCinema>(value: IndieCinema(id: 0, name: "", location: CLLocationCoordinate2D(), code: [""]))
        let tempSelectedCinemaCalendar = BehaviorSubject<CinemaCalendar>(value: CinemaCalendar())
        let tempSelectedDateMovieSchedule = BehaviorSubject<CinemaSchedule>(value: CinemaSchedule())
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
        
        Observable
            .combineLatest(fetchingSelectedCinemaCalendar, tempNearCinemas) { index, cinemas -> IndieCinema? in
                guard !cinemas.isEmpty else { return nil }
                return cinemas[index]
            }
            .flatMap { cinema in
                guard let cinema = cinema else { return Observable<CinemaCalendar>.empty() }
                tempSelectedCinema.onNext(cinema)
                return CinemaService.shared.fetchCinemaCalendar(cinema: cinema)
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { _ in loading.onNext(false) })
            .subscribe(onNext: { calendar in
                print(calendar.businessDays)
                tempSelectedCinemaCalendar.onNext(calendar)
            })
            .disposed(by: disposeBag)
        
        didDateSelected = fetchingSelectedDateMovieSchedule.asObserver()
        
        Observable
            .combineLatest(tempSelectedCinema, tempSelectedCinemaCalendar, fetchingSelectedDateMovieSchedule) { cinema, calendar, dateIndex -> (IndieCinema, String)? in
                guard !calendar.businessDays.isEmpty else { return nil }
                return (cinema, calendar.businessDays[dateIndex])
            }
            .flatMap { cinemaDateTuple in
                guard let cinemaDateTuple = cinemaDateTuple else { return Observable<CinemaSchedule>.empty() }
                return CinemaService.shared.fetchCinemaSchedule(cinema: cinemaDateTuple.0, date: cinemaDateTuple.1)
            }
            .subscribe { cinemaSchedule in
                print(cinemaSchedule)
                tempSelectedDateMovieSchedule.onNext(cinemaSchedule)
            }
            .disposed(by: disposeBag)
        
        
        
        
        // OUTPUT
        nearCinemas = tempNearCinemas
        selectedCinema = tempSelectedCinema
        selectedCinemaCalendar = tempSelectedCinemaCalendar
        selectedDateMovieSchedule = tempSelectedDateMovieSchedule
        
        isLoading = loading.distinctUntilChanged()
    }
}


