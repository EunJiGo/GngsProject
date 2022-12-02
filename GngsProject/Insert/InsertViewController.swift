//
//  InsertViewController.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/30.
//

import UIKit

class InsertViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var pwTF: UITextField!
    @IBOutlet weak var repwTF: UITextField!
    @IBOutlet weak var nameKjTF: UITextField!
    @IBOutlet weak var nameKtTF: UITextField!
    @IBOutlet weak var nameEngTF: UITextField!
    @IBOutlet weak var firstTel: UITextField!
    @IBOutlet weak var secondTel: UIView!
    @IBOutlet weak var lastTel: UITextField!
    @IBOutlet weak var positionTF: UITextField!
    @IBOutlet weak var teamTF: UITextField!
    @IBOutlet weak var memoTV: UITextView!
    @IBOutlet weak var megazineSwitch: UISwitch!
    @IBOutlet weak var insertbtn: UIButton!
    @IBOutlet weak var insertSubBtb: UIButton!
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var stack: UIStackView!
    
    var positionList = [PositionVO()]
    var teamList = [TeamVO()]
    var positionValue = PositionVO()
    var teamValue = TeamVO()
    
    let dbInfo = DBInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.megazineSwitch.isOn = false
        insertSubBtb.layer.isHidden = true
        
        myScrollView.delegate = self
        emailTF.delegate = self
        pwTF.delegate = self
        repwTF.delegate = self
        nameKjTF.delegate = self
        nameKtTF.delegate = self
        nameEngTF.delegate = self
        memoTV.text = ""
        
        tapScrollDown()
        addKeyboardNotifications()
        removeKeyboardNotifications()
        
        positionList = dbInfo.positionInfo()
        teamList = dbInfo.teamInfo()
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.myScrollView.contentOffset.y == myScrollView.contentSize.height - myScrollView.bounds.size.height {
            insertSubBtb.layer.isHidden = false
            return
        }
        if myScrollView.contentOffset.y >= 600 {
            insertSubBtb.layer.isHidden = false
            return
        }
        else {
            insertSubBtb.layer.isHidden = true
            return
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTF || textField == self.pwTF || textField == self.repwTF || textField == self.nameKjTF || textField == self.nameKtTF || textField == self.nameEngTF {
            textField.resignFirstResponder()
        }
        return true
    }
    func tapScrollDown() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        myScrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
            self.myScrollView.endEditing(true)
        }
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    func removeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ noti: NSNotification){
        let userInfo = noti.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        self.myScrollView.contentSize = CGSize(
            width: self.myScrollView.frame.width,
            height: 1430
        )
        if self.memoTV.isFirstResponder {
            let y = self.stack.frame.height - self.myScrollView.frame.height + (-50) + keyboardFrame
            self.myScrollView.contentOffset = CGPoint(x: 0, y: y)
        }
        if self.nameEngTF.isFirstResponder || self.firstTel.isFirstResponder || self.secondTel.isFirstResponder || self.lastTel.isFirstResponder || self.positionTF.isFirstResponder || self.teamTF.isFirstResponder {
            let y = self.stack.frame.height - self.myScrollView.frame.height + (-300) + keyboardFrame
            self.myScrollView.contentOffset = CGPoint(x: 0, y: y)
        }
    }
    @objc func keyboardWillHide(_ noti: NSNotification){
        myScrollView.frame = self.view.frame
        myScrollView.contentSize = CGSize(width:0, height:1170)
        self.myScrollView.contentOffset = CGPoint(x: 0, y: 300)

    }
    

}
