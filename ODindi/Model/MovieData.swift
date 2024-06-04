//
//  MovieData.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/26/24.
//

import Foundation
import UIKit

struct MovieData {
    var title: String = ""
    var engTitle: String = ""
    var poster: Poster = Poster("")
    var releasedDate: String = ""
    var overView: String = ""
    var director: String = ""
    var cast: String = ""
    var genre: String = ""
    var runningTime: String = ""
    var rating: Rating = .rAll
}

struct Poster {
    var small: String
    var large: String
    
    init(_ string: String){
        small = string
        let largeString = string.replacingOccurrences(of: "small", with: "large")
        large = largeString
    }
}

enum Rating {
    case rAll
    case r12
    case r15
    case r18
    
    init(from string: String) {
        switch string {
        case "전체관람가":
            self = .rAll
        case "12세이상관람가":
            self = .r12
        case "15세이상관람가":
            self = .r15
        case "청소년관람불가":
            self = .r18
        default:
            self = .rAll
        }
    }
    
    var image: UIImage {
        switch self {
        case.rAll:
            return UIImage(named: "ratingAll")!
        case.r12:
            return UIImage(named: "rating12")!
        case.r15:
            return UIImage(named: "rating15")!
        case.r18:
            return UIImage(named: "rating18")!
        }
    }
}
