//
//  MainViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/6/24.
//

import Foundation
import RxSwift
import CoreLocation

protocol CinemaViewModelType {
    var currentCoordinate: Observable<CLLocationCoordinate2D> { get }
    
    var fetchNearCinemas: BehaviorSubject<Void> { get }
    var didSelectCinema: BehaviorSubject<Int> { get }
    var didSelectDate: BehaviorSubject<Int> { get }
    
    var nearCinemas: PublishSubject<[IndieCinema]> { get }
    var selectedCinema: PublishSubject<IndieCinema> { get }
    var selectedCinemaCalendar: PublishSubject<CinemaCalendar> { get }
    var cinemaCalendarFirstIndex: BehaviorSubject<Int> { get }
    var selectedDateMovieSchedule: PublishSubject<CinemaSchedule> { get }
    
    var isLoading : PublishSubject<Bool> { get }
}

class CinemaViewModel: CinemaViewModelType {
    let disposeBag = DisposeBag()
    var currentCoordinate: Observable<CLLocationCoordinate2D>
    
    // INPUT
    var fetchNearCinemas = BehaviorSubject<Void>(value: ())
    var didSelectCinema = BehaviorSubject<Int>(value: 0)
    var didSelectDate = BehaviorSubject<Int>(value: 0)
    
    // OUTPUT
    var nearCinemas = PublishSubject<[IndieCinema]>()
    var selectedCinema = PublishSubject<IndieCinema>()
    var selectedCinemaCalendar = PublishSubject<CinemaCalendar>()
    var cinemaCalendarFirstIndex = BehaviorSubject<Int>(value: 0)
    var selectedDateMovieSchedule = PublishSubject<CinemaSchedule>()
    
    var isLoading = PublishSubject<Bool>()
    
    init(_ currentCoordinate: CLLocationCoordinate2D){
        self.currentCoordinate = Observable.just(currentCoordinate)
                        
        // INPUT
        
        fetchNearCinemas
            .do(onNext: { [weak self] _ in self?.isLoading.onNext(true) })
            .withLatestFrom(self.currentCoordinate)
            .map { currentCoordinate in
                let sortedCinemaListByDistance = IndieCinema.list.sorted { cinema1, cinema2 in
                    let distance1 = currentCoordinate.distance(to: cinema1.coordinate)
                    let distance2 = currentCoordinate.distance(to: cinema2.coordinate)
                    return distance1 < distance2
                }
                return Array(sortedCinemaListByDistance.prefix(3))
            }
            .bind(to: nearCinemas)
            .disposed(by: disposeBag)
                
        Observable
            .combineLatest(nearCinemas, didSelectCinema) { cinemas, index -> IndieCinema in
                return cinemas[index]
            }
            .bind(to: selectedCinema)
            .disposed(by: disposeBag)
        
        selectedCinema
            .do(onNext: { [weak self] _ in self?.didSelectDate.onNext(0) })
            .flatMap { cinema in
                return CinemaService.shared.fetchCinemaCalendar(cinema: cinema)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            }
            .do(onNext: { [weak self] _ in self?.isLoading.onNext(false)})
            .bind(to: selectedCinemaCalendar)
            .disposed(by: disposeBag)
        
        selectedCinemaCalendar
            .map({ cinemaCalendar in
                let alldays = cinemaCalendar.alldays
                let businessDays = cinemaCalendar.businessDays
                guard let firstBusinessDay = businessDays.first else { return 0 }
                guard let firstCellIndex = alldays.firstIndex(of: firstBusinessDay) else { return 0 }
                return firstCellIndex
            })
            .bind(onNext: { [weak self] (index : Int) in
                self?.cinemaCalendarFirstIndex.onNext(index)
                self?.didSelectDate.onNext(index)
            })
            .disposed(by: disposeBag)
                
        Observable
            .combineLatest(selectedCinema, selectedCinemaCalendar, didSelectDate) { cinema, calendar, dateIndex -> (IndieCinema, String)? in
                guard !calendar.alldays.isEmpty else { return nil }
                return (cinema, calendar.alldays[dateIndex])
            }
            .compactMap { $0 }
            .flatMap { cinemaAndDate in
                return CinemaService.shared.fetchCinemaSchedule(cinema: cinemaAndDate.0, date: cinemaAndDate.1)
            }
            .bind(to: selectedDateMovieSchedule)
            .disposed(by: disposeBag)
    }
}

