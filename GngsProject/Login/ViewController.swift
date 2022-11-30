//
//  ViewController.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/18.
//

import UIKit

class ViewController: UIViewController {
    
    let dbInfo = DBInfo()
    
    override func viewDidLoad() {
    }

    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var pw: UITextField!
    
    @IBAction func loginButton(_ sender: UIButton) {
        let idCount = id.text?.count
        let pwCount = pw.text?.count
        
        if idCount == 0 {
            let alert = UIAlertController(title: "", message: "アカウントを入力ください", preferredStyle: .alert)
            let check = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
            alert.addAction(check)
            self.present(alert, animated: false)
        } else {
            if pwCount == 0 {
                let alert = UIAlertController(title: "", message: "パスワードを入力ください", preferredStyle: .alert)
                let check = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
                alert.addAction(check)
                self.present(alert, animated: false)
            } else {
                var empId = dbInfo.get(id: id.text!)
                if id.text == empId {
                    if pw.text == dbInfo.pwExist(pw: pw.text!) {
                        print("일람 화면으로 이동 sqlite3_close(db) ")
                        dbInfo.lastLoginUpdate(id: empId)
                        self.performSegue(withIdentifier: "Login", sender: self)
                    } else {
                        let alert = UIAlertController(title: "", message: "パスワードが間違っています。 もう一度入力してください。", preferredStyle: .alert)
                        let check = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
                        alert.addAction(check)
                        self.present(alert, animated: false)
                    }
                } else {
                    print("存在しないIDです。 もう一度入力してください。")
                    let alert = UIAlertController(title: "", message: "存在しないIDです。 もう一度入力してください。", preferredStyle: .alert)
                    let check = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
                    alert.addAction(check)
                    self.present(alert, animated: false)
                }
            }
        }
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
    
    
    
    @IBAction func positionTouch(_ sender: Any) {
    }
}

