//
//  CinemaCalendar.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/7/24.
//

import Foundation

struct CinemaCalendar {
    var alldays: [String] = []
    var businessDays: [String] = []
    var holidays: [String] = []
    var businessDayStatusArray: [BusinessDayStatus] = []
}

// 날짜와, 해당날짜의 영업여부를 불값으로 저장하는 모델
struct BusinessDayStatus: Hashable {
    let dateString: String
    let isBusinessDay: Bool
}
