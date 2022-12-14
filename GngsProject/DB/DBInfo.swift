//
//  DBInfo.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/18.
//

import Foundation
import UIKit

class DBInfo {
    var db: OpaquePointer? = nil
    
    init() {
        print("Start init")
        let dbPath = self.getDBPath()
        print(dbPath)
        self.openDB(dbPath: dbPath)
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    func getDBPath() -> String {
        let fileMgr = FileManager()
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent("GngsPj.sqlite").path
        return dbPath
    }
    func openDB(dbPath: String){
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("OPEN DB")
            loginCreateTable()
            employCreateTable()
            positionCreateTable()
            teamCreateTable()
        } else {
            print("Database Connection Fail")
            sqlite3_close(db)
            return
        }
    }
    
    func loginCreateTable() {
        let query = "CREATE TABLE IF NOT EXISTS login_tbl (EMPLOYEE_NUM TEXT PRIMARY KEY NOT NULL, EMPLOYEE_ID TEXT UNIQUE NOT NULL, EMPLOYEE_PW TEXT NOT NULL, LAST_LOGIN TEXT)"
        guard sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("login table create fail")
            print(errmsg)
            return
        }
    }
    
    func employCreateTable() {
        let query = "CREATE TABLE IF NOT EXISTS employee_tbl (EMPLOYEE_NUM TEXT PRIMARY KEY NOT NULL, NAME_KANJI TEXT NOT NULL, NAME_KANA TEXT NOT NULL, NAME_ENG TEXT NOT NULL, TEL TEXT NOT NULL, GENDER INTEGER NOT NULL, POSITION TEXT NOT NULL, TEAM TEXT NOT NULL, AGREE INTEGER DEFAULT 0, MEGAZINE INTEGER NOT NULL, MEMO TEXT, REGISTER_DATE TEXT, CHANGE_DATE TEXT)"
        guard sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("employee table create fail")
            print(errmsg)
            return
        }
    }
    
    func positionCreateTable() {
        let query = "CREATE TABLE IF NOT EXISTS position_tbl (POSITION_CODE TEXT PRIMARY KEY NOT NULL, POSITION_NAME TEXT NOT NULL)"
        guard sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("position table create fail")
            print(errmsg)
            return
        }
    }
    
    func teamCreateTable() {
        let query = "CREATE TABLE IF NOT EXISTS team_tbl (TEAM_CODE TEXT PRIMARY KEY NOT NULL, TEAM_NAME TEXT NOT NULL)"
        guard sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("team table create fail")
            print(errmsg)
            return
        }
    }
    
    var empVo = EmployeeVO()
    func csvInsert() {
        var csvLines = [String]()
        var empList = [EmployeeVO]()
        guard let path = Bundle.main.path(forResource:"dataList2", ofType:"csv") else {
            return
        }
        do {
            let csvString = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            csvLines = csvString.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n").components(separatedBy: .newlines)
            csvLines.removeLast()
        } catch let error as NSError {
            print("エラー: \(error)")
            return
        }
        
        for data in csvLines {
            let empDetail = data.components(separatedBy: ",")
            empVo.employeeNum = empDetail[0]
            empVo.employeeEmail = empDetail[1]
            empVo.employeePw = empDetail[2]
            empVo.employeeKj = empDetail[3]
            empVo.employeeKt = empDetail[4]
            empVo.employeeEng = empDetail[5]
            empVo.employeeTel = empDetail[6]
            let empGender = Int(empDetail[7])!
            empVo.gender = empGender
            let empMegazine = Int(empDetail[8])!
            empVo.megazine = empMegazine
            empVo.position = empDetail[9]
            empVo.team = empDetail[10]
            empVo.registerDate = empDetail[11]
            empList.append(empVo)
            print(empVo.registerDate)
            csvEmpInput(employeeNum: empDetail[0], employeeKj: empDetail[3], employeeKt: empDetail[4], employeeEng: empDetail[5], employeeTel: empDetail[6], gender: empGender, megazine: empMegazine, position: empDetail[9], team: empDetail[10], registerDate: empDetail[11])
            csvLoginInput(employeeNum: empDetail[0], employeeEmail: empDetail[1], employeePw: empDetail[2])
        }
    }
    
    func csvEmpInput(employeeNum: String, employeeKj: String, employeeKt: String, employeeEng: String, employeeTel: String, gender: Int, megazine: Int, position: String, team: String, registerDate: String ) {
        var stmt: OpaquePointer?
        let query = "INSERT INTO employee_tbl (EMPLOYEE_NUM, NAME_KANJI, NAME_KANA, NAME_ENG, TEL, GENDER, MEGAZINE, POSITION, TEAM, REGISTER_DATE) VALUES ('\(employeeNum)', '\(employeeKj)', '\(employeeKt)', '\(employeeEng)', '\(employeeTel)', \(gender), '\(megazine)', '\(position)', '\(team)', '\(registerDate)')"
       
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print(errmsg)
            return
        }
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            let errmsg = String(cString: sqlite3_errmsg(stmt))
            print(errmsg)
            return
        }
        sqlite3_finalize(stmt)
    }
        
    func csvLoginInput(employeeNum: String, employeeEmail: String, employeePw: String) {
        var stmt: OpaquePointer?
        let query = "INSERT INTO login_tbl (EMPLOYEE_NUM, EMPLOYEE_ID, EMPLOYEE_PW) VALUES ('\(employeeNum)', '\(employeeEmail)', '\(employeePw)')"
           
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print(errmsg)
            return
        }
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return
        }
        sqlite3_finalize(stmt)
    }

    
    func lastLoginUpdate(id: String) {
        var stmt: OpaquePointer? = nil
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var current_date_string = formatter.string(from: Date())
        let query = "UPDATE login_tbl SET LAST_LOGIN = '\(current_date_string)' WHERE EMPLOYEE_ID= '\(id)'"
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        guard sqlite3_step(stmt) != SQLITE_DONE else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero111: \(errmsg)")
            return
        }
        sqlite3_finalize(stmt)
    }
    
    func LoginInfoInsert() -> Bool {
        print("loginInsert")
        var stmt: OpaquePointer?
        let employee_num: String = self.employeeNum()
        let query = "INSERT INTO login_tbl (EMPLOYEE_NUM, EMPLOYEE_ID, EMPLOYEE_PW) VALUES ('\(employee_num)', 'aaaa', 'aaaa' )"
       
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            return false
        }
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }
    
    func team() {
        var stmt: OpaquePointer?
        let query = "INSERT INTO team_tbl (TEAM_CODE, TEAM_NAME) VALUES ('O1', '第1チーム'), ('O2', '第2チーム'), ('O3', '第3チーム'), ('O4', '第4チーム')"
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            return
        }
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            print("team Insert Fail")
            return
        }
    }
    
    func position() {
        var stmt: OpaquePointer?
        let query = "INSERT INTO position_tbl (POSITION_CODE, POSITION_NAME) VALUES ('O6', '社長')"
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            return
        }
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return
        }
        sqlite3_finalize(stmt)
    }
    
    
    func employeeInfoInsert() -> Bool {
        var stmt: OpaquePointer?
        let employee_num: String = self.employeeNum()
        print(employee_num)
        let query = "INSERT INTO employee_tbl (EMPLOYEE_NUM, NAME_KANJI, NAME_KANA, NAME_ENG, TEL, GENDER, POSITION, TEAM, MEGAZINE) VALUES ('\(employee_num)', '桃子', 'モモコ', 'momoko', '080-9600-5997', 1, '社員', '第３チーム', 1)"
//        let query = "DELETE FROM employee_tbl WHERE tel = '080-1234-5678'"
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            return false
        }
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }
        
    func employeeNum() -> String{
        var formatter = DateFormatter()
        formatter.dateFormat = "yy"
        var current_year_string = formatter.string(from: Date())
        print(current_year_string)
        
        formatter.dateFormat = "MM"
        var current_month_string = formatter.string(from: Date())
        print(current_month_string)
        
        formatter.dateFormat = "dd"
        var current_date_string = formatter.string(from: Date())
        print(current_date_string)
        
        var stmt: OpaquePointer? = nil // 컴파일된 SQL을 담을 객체
        let query = "SELECT COUNT(*) FROM employee_tbl"
    //employeeNum: String, employeeId: String, employeePw: String, LastLogin: String
        
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            return ""
        }
        guard sqlite3_step(stmt) == SQLITE_ROW else{
            return ""
        }
        
        let empCount = sqlite3_column_int(stmt, 0)
        var rs: String = ""
        if empCount >= 0 && empCount <= 8 {
            let empCD = empCount+1
            rs = "000\(empCD)"
        } else if empCount >= 9 && empCount <= 98 {
            let empCD = empCount+1
            rs = "00\(empCD)"
        } else if empCount >= 99 && empCount <= 998 {
            let empCD = empCount+1
            rs = "0\(empCD)"
        } else if empCount >= 999 && empCount <= 9998 {
            let empCD = empCount+1
            rs = "\(empCD)"
        } else {
            print("Error")
        }
        
        let employeeCD = "\(current_year_string)-\(current_month_string)\(current_date_string)\(rs)"
        sqlite3_finalize(stmt)
        return employeeCD
    }
  
    func loginInfoGet() -> [LoginVO] {
        var stmt: OpaquePointer? = nil
        var login = [LoginVO]()
        let query = "select * from login_tbl"
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else{
            print("loginValueGet Method Fail")
            return login
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            var loginInfo = LoginVO()
            loginInfo.employeeNum = String(cString: sqlite3_column_text(stmt, 0))
            loginInfo.employeeEmail = String(cString: sqlite3_column_text(stmt, 1))
            loginInfo.employeePw = String(cString: sqlite3_column_text(stmt, 2))
            if sqlite3_column_text(stmt, 3) != nil {
                loginInfo.lastLogin = String(cString: sqlite3_column_text(stmt, 3))
            } else {
                loginInfo.lastLogin = ""
            }
            login.append(loginInfo)
        }
        sqlite3_finalize(stmt)
        return login
    }

    func loginValueGet(id: String) -> LoginVO {
        let loginInfo = LoginVO()
        var stmt: OpaquePointer? = nil
        let query = "SELECT * FROM login_tbl WHERE EMPLOYEE_ID = '\(id)'"
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
            let err = String(cString: sqlite3_errmsg(db))
            print("loginInfo Method Fail")
            print(err)
        }else {
            print("loginInfo Method Success")
        }
        if sqlite3_step(stmt) == SQLITE_ROW {
            loginInfo.employeeNum = String(cString: sqlite3_column_text(stmt, 0))
            loginInfo.employeeEmail = String(cString: sqlite3_column_text(stmt, 1))
            loginInfo.employeePw = String(cString: sqlite3_column_text(stmt, 2))
            sqlite3_finalize(stmt)
            return loginInfo
        } else {
            sqlite3_finalize(stmt)
            return loginInfo
        }
    }
    

    func listInfoGet() -> [ListVO] {
        var stmt: OpaquePointer? = nil
        
        var list = [ListVO]()
        let query = "select * from employee_tbl"
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else{
            print("listInfoGet Method Fail")
            return list
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            var listInfo = ListVO()
            listInfo.employeeNum = String(cString: sqlite3_column_text(stmt, 0))
            listInfo.employeeKj = String(cString: sqlite3_column_text(stmt, 1))
            listInfo.position = positionChange(ps: String(cString: sqlite3_column_text(stmt, 6)))
            listInfo.team = teamChange(team: String(cString: sqlite3_column_text(stmt, 7)))
            list.append(listInfo)
        }
        sqlite3_finalize(stmt)
        return list
    }
    
    func updateDetail(index: Int) -> UpdateVO {
        var updateDetail = [UpdateVO]()
        var stmt: OpaquePointer? = nil
        let query = "SELECT * FROM employee_tbl JOIN login_tbl on login_tbl.EMPLOYEE_NUM=employee_tbl.EMPLOYEE_NUM"
            
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else{
            let err = String(cString: sqlite3_errmsg(db))
            print("updateDetail Method Fail")
            print(err)
            return UpdateVO()
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            var listEmpUpd = UpdateVO()
            listEmpUpd.employeeNum = String(cString: sqlite3_column_text(stmt, 0))
            listEmpUpd.employeeEmail = String(cString: sqlite3_column_text(stmt, 14))
            listEmpUpd.employeeKj = String(cString: sqlite3_column_text(stmt, 1))
            listEmpUpd.employeeKt = String(cString: sqlite3_column_text(stmt, 2))
            listEmpUpd.employeeEng = String(cString: sqlite3_column_text(stmt, 3))
            listEmpUpd.employeeTel = String(cString: sqlite3_column_text(stmt, 4))
            listEmpUpd.gender = Int(sqlite3_column_int(stmt, 5))
            listEmpUpd.position = positionChange(ps: String(cString: sqlite3_column_text(stmt, 6)))
            listEmpUpd.team = teamChange(team: String(cString: sqlite3_column_text(stmt, 7)))
            listEmpUpd.megazine = Int(sqlite3_column_int(stmt, 9))
            if sqlite3_column_text(stmt, 11) != nil {
                listEmpUpd.registerDate = String(cString: sqlite3_column_text(stmt, 11))
            } else {
                listEmpUpd.registerDate = ""
            }
            if sqlite3_column_text(stmt, 12) != nil {
                listEmpUpd.changeDate = String(cString: sqlite3_column_text(stmt, 11))
            } else {
                listEmpUpd.changeDate = ""
            }
            if sqlite3_column_text(stmt, 10) != nil {
                listEmpUpd.memo = String(cString: sqlite3_column_text(stmt, 10))
            } else {
                listEmpUpd.memo = ""
            }
            updateDetail.append(listEmpUpd)
        }
        sqlite3_finalize(stmt)
        return updateDetail[index]
    }
    
    func positionInfo() -> [PositionVO] {
        var stmt: OpaquePointer? = nil
        var positionList = [PositionVO]()
        let query = "select * from position_tbl"
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else{
            print("positionInfo Method Fail")
            return positionList
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            var positionListInfo = PositionVO()
            positionListInfo.positionCode = String(cString: sqlite3_column_text(stmt, 0))
            positionListInfo.positionName = String(cString: sqlite3_column_text(stmt, 1))
            positionList.append(positionListInfo)
        }
        
        sqlite3_finalize(stmt)
        return positionList
    }
    
    func teamInfo() -> [TeamVO] {
        var stmt: OpaquePointer? = nil
        var teamList = [TeamVO]()
        let query = "select * from team_tbl"
        guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else{
            print("teamInfo Method Fail")
            return teamList
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            var teamListInfo = TeamVO()
            teamListInfo.teamCode = String(cString: sqlite3_column_text(stmt, 0))
            teamListInfo.teamName = String(cString: sqlite3_column_text(stmt, 1))
            teamList.append(teamListInfo)
        }
        
        sqlite3_finalize(stmt)
        return teamList
    }
    
    func positionChange(ps: String)->String{
        if ps == "01" {
            return "社員"
        }
        if ps == "02" {
            return "主任"
        }
        if ps == "03" {
            return "課長"
        }
        if ps == "04" {
            return "次長"
        }
        if ps == "05" {
            return "部長"
        }
        if ps == "06" {
            return "代表"
        }
        return ps //change
    }
    
    func teamChange(team: String)->String{
        if team == "01" {
            return "第1チーム"
        }
        if team == "02" {
            return "第2チーム"
        }
        if team == "03" {
            return "第3チーム"
        }
        if team == "04" {
            return "第4チーム"
        }
        return team //change
    }
    
    func update(nameKj: String, nameKn: String, nameEng: String, tel: String, position: String, team: String, megazine: Int, memo: String, changeDate: String, empNum: String) {
        print("ddddddddddd")
        var stmt: OpaquePointer? = nil
        let query = "UPDATE employee_tbl SET NAME_KANJI = '\(nameKj)', NAME_KANA = '\(nameKn)', NAME_ENG = '\(nameEng)', TEL = '\(tel)', POSITION = '\(position)', TEAM = '\(team)', MEGAZINE = '\(megazine)', MEMO = '\(memo)', CHANGE_DATE = '\(changeDate)' WHERE EMPLOYEE_NUM = '\(empNum)'"
//        let sql = "UPDATE employee_tbl SET NAME_KANJI = '\(nameKj)', NAME_KANA = '\(nameKn)', NAME_ENG = '\(nameEng)', TEL = '\(tel)', POSITION = '\(position)', TEAM = '\(team)', MEGAZINE = \(megazine), MEMO = '\(memo)' WHERE = EMPLOYEE_NUM = '22-1121---1'"
            // クエリを準備する
            guard sqlite3_prepare(db, query, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            // クエリを実行する
            guard sqlite3_step(stmt) == SQLITE_DONE else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero111: \(errmsg)")
                return
            }
            sqlite3_finalize(stmt)
    }

    
}


