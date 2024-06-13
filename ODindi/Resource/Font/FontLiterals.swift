//
//  FontLiterals.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/28/24.
//

import Foundation
import UIKit

enum FontName: String {
    case pretendardRegular = "Pretendard-Regular"
    case pretendardBlack = "Pretendard-Black"
    case pretendardBold = "Pretendard-Bold"
    case pretendardExtraBold = "Pretendard-ExtraBold"
    case pretendardExtraLight = "Pretendard-ExtraLight"
    case pretendardLight = "Pretendard-Light"
    case pretendardMedium = "Pretendard-Medium"
    case pretendardSemiBold = "Pretendard-SemiBold"
    case pretendardThin = "Pretendard-Thin"
}

extension UIFont {
    static func customFont(ofSize size: CGFloat, style: FontName) -> UIFont {
        guard let customFont = UIFont(name: style.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: 15)
        }
        return customFont
    }
}
