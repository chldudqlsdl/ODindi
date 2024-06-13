//
//  DateCellViewModel.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/23/24.
//

import Foundation
import RxSwift

protocol DateCellViewModelType {
    var day: BehaviorSubject<String> { get }
    var daysOfweek: BehaviorSubject<String> { get }
}

class DateCellViewModel: DateCellViewModelType {
    let disposebag = DisposeBag()
    
    var day = BehaviorSubject<String>(value: "")
    var daysOfweek = BehaviorSubject<String>(value: "")
    
    init(_ dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        
        let dateObservable = Observable
            .just(date)
            .share()
        
        dateObservable
            .compactMap {$0}
            .map { date in
                let dateFormatter = dateFormatter
                dateFormatter.dateFormat = "dd"
                return dateFormatter.string(from: date)
            }
            .bind(onNext: { [weak self] string in
                self?.day.onNext(string)
            })
            .disposed(by: disposebag)
        
        dateObservable
            .compactMap {$0}
            .map { (date: Date) in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let dateString = dateFormatter.string(from: date)
                let todayString = dateFormatter.string(from: Date())
                let tomorrowString = dateFormatter.string(from: Date().addingTimeInterval(3600 * 24))
                
                // 요일을 리턴하는데, 오늘일 경우 오늘, 내일일 경우에는 내일을 리턴
                if dateString == todayString {
                    return "오늘"
                } else if dateString == tomorrowString {
                    return "내일"
                } else {
                    let dateFormatter = dateFormatter
                    dateFormatter.locale = Locale(identifier:"ko_KR")
                    dateFormatter.dateFormat = "E"
                    return dateFormatter.string(from: date)
                }
                
            }
            .bind(onNext: { [weak self] string in
                self?.daysOfweek.onNext(string)
            })
            .disposed(by: disposebag)
    }
}
