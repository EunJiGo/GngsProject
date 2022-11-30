//
//  AlertMessage.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/30.
//

import Foundation

class AlertMessage {
    func wrongCaseAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let check = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
            alert.addAction(check)
            self.present(alert, animated: false)
    }
}
