//
//  Colors.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/11/24.
//

import Foundation
import UIKit

extension UIColor {
    
    static let customLight = UIColor(hex: "EEDBFF")
    static let customMedium = UIColor(hex: "9235E8")
    static let customDark = UIColor(hex: "480D80")
    static let customDarker = UIColor(hex: "20003D")
    
    convenience init(hex: String) {
            var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")

            var rgb: UInt64 = 0
            Scanner(string: hexFormatted).scanHexInt64(&rgb)

            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0

            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        }
}
