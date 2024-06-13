//
//  AlertUtil.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/8/24.
//

import Foundation
import RxSwift
import UIKit

struct AlertHelper {
    static func showAlert(
        on viewController: UIViewController,
        title: String,
        msg: String,
        cancelMsg: String,
        confirmMsg: String,
        onConfirm: @escaping () -> Void
    ) {
        let alertSheet = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertSheet.addAction(UIAlertAction(title: cancelMsg, style: .default))
        alertSheet.addAction(UIAlertAction(title: confirmMsg, style: .destructive, handler: { _ in
            onConfirm()
        }))
        
        viewController.present(alertSheet, animated: true)
    }
}
