//
//  CinemaSchedule.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/6/24.
//

import Foundation

typealias CinemaSchedule = [MovieSchedule]

struct MovieSchedule {
    let name: String
    let imageUrl: String
    var timeTable: [String]
    let code: String
    
    init(info: MovieScheduleInfo) {
        self.name = info.MovieNm
        self.imageUrl = info.Url
        self.timeTable = [info.StartTime]
        self.code = info.MovieCd
    }
}

struct MovieScheduleData: Codable {
    let Showseqlist : [MovieScheduleInfo]
}

struct MovieScheduleInfo: Codable {
    let MovieNm: String
    let Url: String
    let StartTime: String
    let MovieCd: String
}
