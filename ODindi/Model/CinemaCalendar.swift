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

struct BusinessDayStatus: Hashable {
    let dateString: String
    let isBusinessDay: Bool
}
