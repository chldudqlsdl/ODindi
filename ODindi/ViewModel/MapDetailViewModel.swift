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
    var selectedCinema: BehaviorSubject<IndieCinema> { get }
    var didSelectDate: BehaviorSubject<Int> { get }
    
    var distance: BehaviorSubject<CLLocationDistance> { get }
    var cinemaData: BehaviorSubject<IndieCinema> { get }
    var urlRequest: PublishSubject<URLRequest> { get }
    var selectedCinemaCalendar: PublishSubject<CinemaCalendar> { get }
    var cinemaCalendarFirstIndex: BehaviorSubject<Int> { get }
    var selectedDateMovieSchedule: PublishSubject<CinemaSchedule> { get }
    
    var isLoading : BehaviorSubject<Bool> { get }
}

class MapDetailViewModel: MapDetailViewModelType {
    
    let disposeBag = DisposeBag()
    
    var instaBtnTapped = PublishSubject<Void>()
    var mapBtnTapped = PublishSubject<Void>()
    var selectedCinema = BehaviorSubject<IndieCinema>(value: IndieCinema.list[0])
    var didSelectDate = BehaviorSubject<Int>(value: 0)
    
    var distance = BehaviorSubject<CLLocationDistance>(value: 0.0)
    var cinemaData = BehaviorSubject<IndieCinema>(value: IndieCinema.list[0])
    var urlRequest = PublishSubject<URLRequest>()
    var selectedCinemaCalendar = PublishSubject<CinemaCalendar>()
    var cinemaCalendarFirstIndex = BehaviorSubject<Int>(value: 0)
    var selectedDateMovieSchedule = PublishSubject<CinemaSchedule>()
    
    var isLoading = BehaviorSubject<Bool>(value: true)
    
    init(coordinate: CLLocationCoordinate2D, cinemaName: String ){
        
        Observable
            .just(cinemaName)
            .bind(onNext: { [weak self] cinemaName in
                let selectedCinemas = IndieCinema.list.filter { indieCinema in
                    indieCinema.name == cinemaName
                }
                guard let selectedCinema = selectedCinemas.first else { return }
                self?.selectedCinema.onNext(selectedCinema)
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
            .flatMapLatest { cinemaAndDate in
                return CinemaService.shared.fetchCinemaSchedule(cinema: cinemaAndDate.0, date: cinemaAndDate.1)
            }
            .bind(to: selectedDateMovieSchedule)
            .disposed(by: disposeBag)
    }
}
