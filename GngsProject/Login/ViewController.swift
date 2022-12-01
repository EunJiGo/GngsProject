//
//  ViewController.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/18.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    let dbInfo = DBInfo()
    let alertMessage = AlertViewController()
    
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var pw: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        id.delegate = self
        pw.delegate = self
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        let idCount = id.text?.count
        let pwCount = pw.text?.count
        let empLoginInfo = dbInfo.loginValueGet(id: id.text!)
        
        if idCount == 0 {
            alertMessage.wrongCaseAlert(title: "", message: "アカウントを入力ください", target: self)
            return
        }
        if pwCount == 0 {
            alertMessage.wrongCaseAlert(title: "", message: "パスワードを入力ください", target: self)
            return
        }
        guard id.text == empLoginInfo.employeeEmail else {
            alertMessage.wrongCaseAlert(title: "", message: "存在しないIDです。 もう一度入力してください。", target: self)
            return
        }
        guard pw.text == empLoginInfo.employeePw else {
            alertMessage.wrongCaseAlert(title: "", message: "パスワードが間違っています。 もう一度入力してください。", target: self)
            return
        }
        
        dbInfo.lastLoginUpdate(id: empLoginInfo.employeeEmail)
        self.performSegue(withIdentifier: "Login", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.id || textField == self.pw {
            textField.resignFirstResponder()
        }
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

