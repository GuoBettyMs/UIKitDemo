//
//  CustomAlert.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//

import UIKit

/// 警告
struct Alert{
    static func showBasicAlert(on vc: UIViewController, with title: String, message: String, actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default)]) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actions {
            alertVC.addAction(action)
        }
        
        DispatchQueue.main.async {
            vc.present(alertVC, animated: true)
        }
    }
}
