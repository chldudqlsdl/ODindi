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
    
    var fetchNearCinemas: BehaviorSubject<Void> { get }
    var didSelectCinema: BehaviorSubject<Int> { get }
    var didSelectDate: BehaviorSubject<Int> { get }
    var watchLaterButtonTapped: PublishSubject<String> { get }
    
    var nearCinemas: PublishSubject<[IndieCinema]> { get }
    var selectedCinema: PublishSubject<IndieCinema> { get }
    var selectedCinemaCalendar: PublishSubject<CinemaCalendar> { get }
    var cinemaCalendarFirstIndex: BehaviorSubject<Int> { get }
    var selectedDateMovieSchedule: PublishSubject<CinemaSchedule> { get }
    
    var isLoading : PublishSubject<Bool> { get }
}

class MainViewModel: MainViewModelType {
    let disposeBag = DisposeBag()
    var currentCoordinate: Observable<CLLocationCoordinate2D>
    
    // INPUT
    var fetchNearCinemas = BehaviorSubject<Void>(value: ())
    var didSelectCinema = BehaviorSubject<Int>(value: 0)
    var didSelectDate = BehaviorSubject<Int>(value: 0)
    var watchLaterButtonTapped = PublishSubject<String>()
    
    // OUTPUT
    var nearCinemas = PublishSubject<[IndieCinema]>()
    var selectedCinema = PublishSubject<IndieCinema>()
    var selectedCinemaCalendar = PublishSubject<CinemaCalendar>()
    // 상영 날짜 리스트에서 첫번째 상영일(휴일일 경우 제외)의 인덱스 저장
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
                // 영화관 리스트를 순회하면서 영화과 좌표과 현재 좌표를 비교해, 현재 위치로 부터 떨어진 거리 저장
                let cinemasWithDistance = IndieCinema.list.map { cinema -> IndieCinema in
                    var updatedCinema = cinema
                    updatedCinema.distance = updatedCinema.coordinate.distance(to: currentCoordinate)
                    return updatedCinema
                }
                // 거리 가까운 순서대로 영화관 정렬
                let sortedCinemaListByDistance = cinemasWithDistance.sorted { cinema1, cinema2 in
                    let distance1 = cinema1.distance
                    let distance2 = cinema2.distance
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
        
        // 영화관이 선택되면 그 영화관의 상영일 리스트를 받아오기
        selectedCinema
            .flatMap { cinema in
                return CinemaService.shared.fetchCinemaCalendar(cinema: cinema)
                    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            }
            .do(onNext: { [weak self] _ in self?.isLoading.onNext(false)})
            .bind(to: selectedCinemaCalendar)
            .disposed(by: disposeBag)
        
        selectedCinemaCalendar
            // 받아온 상영일 리스트에서 가장 빠른 상영일(휴일제외) 인덱스 리턴
            .map({ cinemaCalendar in
                let alldays = cinemaCalendar.alldays
                let businessDays = cinemaCalendar.businessDays
                guard let firstBusinessDay = businessDays.first else { return 0 }
                guard let firstCellIndex = alldays.firstIndex(of: firstBusinessDay) else { return 0 }
                return firstCellIndex
            })
            .bind(onNext: { [weak self] (index : Int) in
                self?.cinemaCalendarFirstIndex.onNext(index)
                // 가장 빠른 상영일 인덱스 전달
                self?.didSelectDate.onNext(index)
            })
            .disposed(by: disposeBag)
                
        Observable
            // 영화관이 선택되거나, 날짜가 선택되는 모든 경우에 값을 전달
            .combineLatest(selectedCinema, selectedCinemaCalendar, didSelectDate) { cinema, calendar, dateIndex -> (IndieCinema, String)? in
                guard !calendar.alldays.isEmpty else { return nil }
                return (cinema, calendar.alldays[dateIndex])
            }
            .compactMap { $0 }
            .flatMapLatest { cinemaAndDate in
                // 지정 영화관, 지정 날짜의 상영 정보 요청
                return CinemaService.shared.fetchCinemaSchedule(cinema: cinemaAndDate.0, date: cinemaAndDate.1)
            }
            .bind(to: selectedDateMovieSchedule)
            .disposed(by: disposeBag)
    }
}

