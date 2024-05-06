//
//  Extensions.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/6/24.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    func distance(to target: CLLocationCoordinate2D) -> CLLocationDistance {
        let currentLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let targetLocation = CLLocation(latitude: target.latitude, longitude: target.longitude)
        return currentLocation.distance(from: targetLocation)
    }
}
