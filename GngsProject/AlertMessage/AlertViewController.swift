//
//  AlertViewController.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/30.
//

import UIKit 

class AlertViewController: UIViewController {
    func wrongCaseAlert(title: String, message: String, target: UIViewController) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let check = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
            alert.addAction(check)
            target.present(alert, animated: false)
    }

}
