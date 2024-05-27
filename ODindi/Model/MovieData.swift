//
//  MovieData.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/26/24.
//

import Foundation

struct MovieData: Decodable {
    let title: String
    let engTitle: String
    let poster: String
    let releasedDate: String
    let overView: String
    let director: String
    let cast: String
    let genre: String
    let runningTime: String
    let rating: String
}
