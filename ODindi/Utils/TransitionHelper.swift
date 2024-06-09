//
//  TransitionUtil.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/9/24.
//

import Foundation
import UIKit

struct TransitionHelper {
    static func configure(
        target: UIView?,
        duration: TimeInterval = 0.7,
        handler: @escaping () -> Void
    ){
        UIView.transition(with: target ?? UIView(), duration: duration, options: .transitionCrossDissolve, animations: handler)
    }
}
