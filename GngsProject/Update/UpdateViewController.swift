//
//  UpdateViewController.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/22.
//

import UIKit

class UpdateViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    typealias empDetailRecord = (String, String, String, String, String, Int, String, String, String, Int, String)
    var empDetailList = [empDetailRecord]()
    var idxNum: Int = 0
    var employEmail: String = ""
    var megazineValue: Int = 0
    let dbInfo = DBInfo()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        myScrollView.addGestureRecognizer(singleTapGestureRecognizer)

        firstTel.delegate = self
        secondTel.delegate = self
        lastTel.delegate = self
        
        self.empNumTF.text = empDetailList[idxNum].0
        self.empIdTF.text = employEmail
        self.nameKjTF.text = empDetailList[idxNum].1
        self.nameKtTF.text = empDetailList[idxNum].2
        self.nameEngTF.text = empDetailList[idxNum].3
        firstNum(tel: empDetailList[idxNum].4)
        self.firstTel.text = firstNum
        self.secondTel.text = secondNum
        self.lastTel.text = lastNum
        gender(gender: empDetailList[idxNum].5)
        self.positionTF.text = empDetailList[idxNum].6
        self.teamTF.text = empDetailList[idxNum].7
        let regDate = empDetailList[idxNum].8
        self.resDateTF.text = newRegDate(registDate: regDate)
        self.megazineValue = empDetailList[idxNum].9
        if self.megazineValue == 1{
            self.megazineSwitch.isOn = true
        }else {
            self.megazineSwitch.isOn = false
        }
        self.memoTV.text = empDetailList[idxNum].10
        
        empNumTF.isEnabled = false
        empNumTF.textColor = .gray
        empIdTF.isEnabled = false
        empIdTF.textColor = .gray
        resDateTF.isEnabled = false
        resDateTF.textColor = .gray
        
        createPickerView()
        
        addKeyboardNotifications()
        removeKeyboardNotifications()
    }
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var empNumTF: UITextField!
    @IBOutlet weak var empIdTF: UITextField!
    @IBOutlet weak var nameKjTF: UITextField!
    @IBOutlet weak var nameKtTF: UITextField!
    @IBOutlet weak var nameEngTF: UITextField!
    @IBOutlet weak var firstTel: UITextField!
    @IBOutlet weak var secondTel: UITextField!
    @IBOutlet weak var lastTel: UITextField!
    @IBOutlet weak var resDateTF: UITextField!
    @IBOutlet weak var positionTF: UITextField!
    @IBOutlet weak var teamTF: UITextField!
    @IBOutlet weak var megazineSwitch: UISwitch!
    @IBOutlet weak var memoTV: UITextView!
    
    var manRa: UIImage!
    var womanRa: UIImage!
    @IBOutlet weak var manRadio: UIImageView!
    @IBOutlet weak var womanRadio: UIImageView!
    func gender(gender: Int) {
        if gender == 1 {
            self.womanRadio.image = UIImage(systemName: "record.circle")
            self.manRadio.image = UIImage(systemName: "circle")
        } else {
            self.womanRadio.image = UIImage(systemName: "circle")
            self.manRadio.image = UIImage(systemName: "record.circle")
        }
    }
    
    
    @IBAction func onSwitch(_ sender: UISwitch) {
        if(sender.isOn == true) {
            self.megazineValue = 1
        }else {
            megazineValue = 0
        }
    }

    let position = ["社員", "主任", "課長", "次長", "部長", "代表"]
    let team = ["第1チーム", "第2チーム", "第3チーム", "第4チーム"]
    var pickerView1 = UIPickerView()
    let pickerView2 = UIPickerView()
    func createPickerView() {
        pickerView1.delegate = self
        pickerView1.dataSource = self
        positionTF.tintColor = .clear
        pickerView2.delegate = self
        pickerView2.dataSource = self
        teamTF.tintColor = .clear
    
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(onPickDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "キャンサル", style: .done, target: self, action: #selector(onPickCancel))
        toolBar.setItems([btnCancel , space , btnDone], animated: true)
        toolBar.isUserInteractionEnabled = true
              
        positionTF.inputView = pickerView1
        teamTF.inputView = pickerView2
        positionTF.inputAccessoryView = toolBar
        teamTF.inputAccessoryView = toolBar
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerView1{
            return position.count
        }
        else{
            return team.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerView1{
            return position[row]
        }
        else{
            return team[row]
        }
    }
    var positionValue: String = ""
    var teamValue: String = ""
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerView1{
            positionValue = position[row]
            teamValue = self.teamTF.text!
        }
        else{
            positionValue = self.positionTF.text!
            teamValue = team[row]
        }
    }
    
   
    @objc func onPickDone() {
        positionTF.text = positionValue
        positionTF.resignFirstResponder()
        teamTF.text = teamValue
        teamTF.resignFirstResponder()
    }
    @objc func onPickCancel() {
        positionTF.resignFirstResponder()
        teamTF.resignFirstResponder()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "ListVC") else {
            return
        }
        uvc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        uvc.modalPresentationStyle = .fullScreen
        self.present(uvc, animated: true)
    }
    
    func newRegDate(registDate: String) -> String {
        let str = registDate
        let arr = Array(str)
        let year = "\(arr[0])\(arr[1])\(arr[2])\(arr[3])"
        let month = "\(arr[5])\(arr[6])"
        let date = "\(arr[8])\(arr[9])"
        let registerDate = "\(year)年\(month)月\(date)日"
        return registerDate
    }
    
    var firstNum: String = ""
    var secondNum: String = ""
    var lastNum: String = ""
    func firstNum(tel: String){
        let str = tel
        let arr = Array(str)
        firstNum = "\(arr[0])\(arr[1])\(arr[2])"
        secondNum = "\(arr[4])\(arr[5])\(arr[6])\(arr[7])"
        lastNum = "\(arr[9])\(arr[10])\(arr[11])\(arr[12])"
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let firstNum = self.firstTel.text else {return false}
        guard let secondNum = self.secondTel.text else {return false}
        guard let lastNum = self.lastTel.text else {return false}
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        if firstNum.count >= 3 && secondNum.count >= 4 && lastNum.count >= 4{
            return false
        }
        return true
    }
    
    @IBAction func updateBtn(_ sender: Any) {
        // MARK: - 名前（漢字）
        // 1) is empry?, count
        // if .. == false {
        //     show error
        //     return
        // } 
        
        // 2) pattern check
        
        // 3)
        
        
        // MARK: - 名前（漢字）
        
        
        // MARK: - ...
        
        if self.nameKjTF.text == empDetailList[idxNum].1 && self.nameKtTF.text == empDetailList[idxNum].2 && self.nameEngTF.text == empDetailList[idxNum].3 && self.firstTel.text == firstNum && self.secondTel.text == secondNum && self.lastTel.text == lastNum && self.positionTF.text == empDetailList[idxNum].6 && self.teamTF.text == empDetailList[idxNum].7 && self.megazineValue == empDetailList[idxNum].9 &&  self.memoTV.text == empDetailList[idxNum].10 {
            wrongCaseAlert(title: "", message: "修正事項がありません。")
        } else{
            let kanjiPattern = "^[一-龠]*$"
            let kataPattern = "^[ァ-ヶー]*$"
            let emgPattern = "^[a-zA-Z]*$"
            let telPattern = "^[0-9]*$"
            var kanji = self.nameKjTF.text
            var kata = self.nameKtTF.text
            var eng = self.nameEngTF.text
            var firTel = self.firstTel.text!
            var secTel = self.secondTel.text!
            var lastTel = self.lastTel.text!
            let isVaildKanjiPattern = (kanji!.range(of: kanjiPattern, options: .regularExpression) != nil)
            let isVaildKataPattern = (kata!.range(of: kataPattern, options: .regularExpression) != nil)
            let isVaildEngPattern = (eng!.range(of: emgPattern, options: .regularExpression) != nil)
            let isVaildfirTelPattern = (firTel.range(of: telPattern, options: .regularExpression) != nil)
            if kanji?.count != 0 {
                if kata?.count != 0 {
                    if eng?.count != 0 {
                        if firTel.count != 0 && secTel.count != 0 && lastTel.count != 0 {
                            if isVaildKanjiPattern {
                                if isVaildKataPattern {
                                    if isVaildEngPattern {
                                        dbInfo.update(nameKj: kanji!, nameKn: kata!, nameEng: eng!, tel: "\(firTel)-\(secTel)-\(lastTel)", position: self.positionTF.text!, team: self.teamTF.text!, megazine: self.megazineValue, memo: self.memoTV.text, empNum: self.empNumTF.text!)
                                        let uvc = self.storyboard!.instantiateViewController(withIdentifier: "ListVC")
                                        uvc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                        uvc.modalPresentationStyle = .fullScreen
                                        self.present(uvc, animated: true)
                                    } else {
                                        wrongCaseAlert(title: "", message: "正しい英語形式ではありません。")
                                    }
                                } else {
                                    wrongCaseAlert(title: "", message: "正しいカタカナ形式ではありません。")
                                }
                            }else {
                                wrongCaseAlert(title: "", message: "正しい漢字形式ではありません。")
                            }
                        } else {
                            wrongCaseAlert(title: "", message: "電話番号を入力してください")
                        }
                    } else {
                        wrongCaseAlert(title: "", message: "名前(英語)を入力してください")
                    }
                }else {
                    wrongCaseAlert(title: "", message: "名前(カナ)を入力してください")
                }
                
            } else {
                wrongCaseAlert(title: "", message: "名前(漢字)を入力してください")
            }
        }
    }
    
    func wrongCaseAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let check = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
            alert.addAction(check)
            self.present(alert, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameKjTF || textField == self.nameKtTF || textField == self.nameEngTF || textField == self.firstTel || textField == self.secondTel || textField == self.lastTel {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
            self.myScrollView.endEditing(true)
        }
    //ダメ。。 왜 안돼..
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
            self.myScrollView.endEditing(true)
    }
    
    
    // 노티피케이션을 추가하는 메서드
    func addKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    // 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBOutlet weak var stack: UIStackView!
    
    // 키보드가 나타났다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillShow(_ noti: NSNotification){
        let userInfo = noti.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        self.myScrollView.contentSize = CGSize(
            width: self.myScrollView.frame.width,
            height: 1280
        )
        
        if self.memoTV.isFirstResponder {
            let y = self.stack.frame.height - self.myScrollView.frame.height + (-20) + keyboardFrame
            self.myScrollView.contentOffset = CGPoint(x: 0, y: y)
        }
        
        if self.positionTF.isFirstResponder {
            let y = self.stack.frame.height - self.myScrollView.frame.height + (-300) + keyboardFrame
            self.myScrollView.contentOffset = CGPoint(x: 0, y: y)
        }
        
        if self.teamTF.isFirstResponder {
            let y = self.stack.frame.height - self.myScrollView.frame.height + (-300) + keyboardFrame
            self.myScrollView.contentOffset = CGPoint(x: 0, y: y)
        }
    }

    // 키보드가 사라졌다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillHide(_ noti: NSNotification){
        myScrollView.frame = self.view.frame
        myScrollView.contentSize = CGSize(width:0, height:1000)
        self.myScrollView.contentOffset = CGPoint(x: 0, y: 150)

    }
}
