//
//  DBInfo.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/18.
//

import Foundation

class DBInfo {
    var db: OpaquePointer? = nil
    
    init() {
        print("Start init")
        let dbPath = self.getDBPath()
        print(dbPath)
        self.openDB(dbPath: dbPath)
        team()
    }
    
    deinit {
        sqlite3_close(db)
        print("deinit")
    }
    
    func closeDB() {
        sqlite3_close(db)
        print("deinit")
    }
    
    func getDBPath() -> String {
        //앱 내 문서 디렉토리 경로에서 SQLite DB파일을 찾는다
        let fileMgr = FileManager() // 파일 매니저 객체 생성
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
        let createTable = "CREATE TABLE IF NOT EXISTS login_tbl (EMPLOYEE_NUM TEXT PRIMARY KEY NOT NULL, EMPLOYEE_ID TEXT UNIQUE NOT NULL, EMPLOYEE_PW TEXT NOT NULL, LAST_LOGIN TEXT)"
        if sqlite3_exec(db, createTable, nil, nil, nil) == SQLITE_OK{
        } else {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            print("table create fail")
            return
        }
    }
    
    func employCreateTable() {
        let createTable = "CREATE TABLE IF NOT EXISTS employee_tbl (EMPLOYEE_NUM TEXT PRIMARY KEY NOT NULL, NAME_KANJI TEXT NOT NULL, NAME_KANA TEXT NOT NULL, NAME_ENG TEXT NOT NULL, TEL TEXT NOT NULL, GENDER INTEGER NOT NULL, POSITION TEXT NOT NULL, TEAM TEXT NOT NULL, AGREE INTEGER DEFAULT 0, MEGAZINE INTEGER NOT NULL, MEMO TEXT, REGISTER_DATE TEXT DEFAULT CURRENT_TIMESTAMP, CHANGE_DATE TEXT)"
        if sqlite3_exec(db, createTable, nil, nil, nil) == SQLITE_OK{
        } else {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            print("table create fail")
            return
        }
    }
    
    func positionCreateTable() {
        let createTable = "CREATE TABLE IF NOT EXISTS position_tbl (POSITION_CODE TEXT PRIMARY KEY NOT NULL, POSITION_NAME TEXT NOT NULL)"
        if sqlite3_exec(db, createTable, nil, nil, nil) == SQLITE_OK{
        } else {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            print("table create fail")
            return
        }
    }
    
    func teamCreateTable() {
        let createTable = "CREATE TABLE IF NOT EXISTS team_tbl (TEAM_CODE TEXT PRIMARY KEY NOT NULL, TEAM_NAME TEXT NOT NULL)"
        if sqlite3_exec(db, createTable, nil, nil, nil) == SQLITE_OK{
        } else {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            print("table create fail")
            return
        }
    }
    
    var empVo = EmployeeVO()
    func csvInsert() {
        var csvLines = [String]()
        var empList = [EmployeeVO]()
        guard let path = Bundle.main.path(forResource:"dataList2", ofType:"csv") else {
            print("csvファイルがないよ")
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
            empVo.position = empDetail[8]
            empVo.team = empDetail[9]
            empVo.registerDate = empDetail[10]
            empList.append(empVo)
            
            csvEmpInput(employeeNum: empDetail[0], employeeKj: empDetail[3], employeeKt: empDetail[4], employeeEng: empDetail[5], employeeTel: empDetail[6], gender: empGender, position: empDetail[8], team: empDetail[9], registerDate: empDetail[10])
            
            csvLoginInput(employeeNum: empDetail[0], employeeEmail: empDetail[1], employeePw: empDetail[2])
        }
    }
    
    func csvEmpInput(employeeNum: String, employeeKj: String, employeeKt: String, employeeEng: String, employeeTel: String, gender: Int, position: String, team: String, registerDate: String ) {
        var stmt: OpaquePointer?
        let query = "INSERT INTO employee_tbl (EMPLOYEE_NUM, NAME_KANJI, NAME_KANA, NAME_ENG, TEL, GENDER, POSITION, TEAM, MEGAZINE) VALUES ('\(employeeNum)', '\(employeeKj)', '\(employeeKt)', '\(employeeEng)', '\(employeeTel)', \(gender), '\(position)', '\(team)', '\(registerDate)')"
       
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
            print("insert fail")
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
        }else {
            print("insert success")
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("insert ffail")
        }else {
            print("insert ssucess")
        }
        
        sqlite3_finalize(stmt)
    }
        
    func csvLoginInput(employeeNum: String, employeeEmail: String, employeePw: String) {
        var stmt: OpaquePointer?
        let query = "INSERT INTO login_tbl (EMPLOYEE_NUM, EMPLOYEE_ID, EMPLOYEE_PW) VALUES ('\(employeeNum)', '\(employeeEmail)', '\(employeePw)')"
           
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
            print("insert fail")
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
        }else {
            print("insert success")
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("insert ffail")
        }else {
            print("insert ssucess")
        }
        sqlite3_finalize(stmt)
    }
    
    func lastLoginUpdate(id: String) {
        var stmt: OpaquePointer? = nil
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var current_date_string = formatter.string(from: Date())
        let sql = "UPDATE login_tbl SET LAST_LOGIN = '\(current_date_string)' WHERE EMPLOYEE_ID= '\(id)'"
        if sqlite3_prepare(db, sql, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero111: \(errmsg)")
            sqlite3_finalize(stmt)
        }
    }
    
    func LoginInfoInsert() -> Bool {
        print("loginInsert")
        var stmt: OpaquePointer?
        let employee_num: String = self.employeeNum()
        
//        let query = "INSERT INTO login_tbl (EMPLOYEE_NUM, EMPLOYEE_ID, EMPLOYEE_PW) VALUES ('\(employee_num)', 'tanaka@gmail.com', '@tanaka1234' )"
          let query = "INSERT INTO login_tbl (EMPLOYEE_NUM, EMPLOYEE_ID, EMPLOYEE_PW) VALUES ('\(employee_num)', 'aaaa', 'aaaa' )"
       
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
            print("insert fail")
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
        }else {
            
            print("insert success")
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("insert ffail")
        }else {
            print("insert ssucess")
        }
        
        sqlite3_finalize(stmt)
        return true
    }
    
    func team() {
        var stmt: OpaquePointer?
        let query = "INSERT INTO team_tbl (TEAM_CODE, TEAM_NAME) VALUES ('O1', '第1チーム'), ('O2', '第2チーム'), ('O3', '第3チーム'), ('O4', '第4チーム')"
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
        }else {
            
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("team Insert Fail")
        } else {
            print("team Insert Ok")
        }
    }
    
    func position() {
        var stmt: OpaquePointer?
        let query = "INSERT INTO position_tbl (POSITION_CODE, POSITION_NAME) VALUES ('O6', '社長')"
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
        } else {
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("position insert Fail")
        } else {
            print("position insert OK")
        }
        sqlite3_finalize(stmt)
    }
    
    func employeeInfoInsert() -> Bool {
        var stmt: OpaquePointer?
        let employee_num: String = self.employeeNum()
        print(employee_num)
        let query = "INSERT INTO employee_tbl (EMPLOYEE_NUM, NAME_KANJI, NAME_KANA, NAME_ENG, TEL, GENDER, POSITION, TEAM, MEGAZINE) VALUES ('\(employee_num)', '桃子', 'モモコ', 'momoko', '080-9600-5997', 1, '社員', '第３チーム', 1)"
//        let query = "INSERT INTO employee_tbl (EMPLOYEE_NUM, NAME_KANJI, NAME_KANA, NAME_ENG, TEL, GENDER, POSITION, TEAM, MEGAZINE) VALUES ('22-11210001', '高恩智', 'ゴウンジ', 'GOEUNJI', '080-2039-1981', 1, '社員', '第1チーム', 1)"
//        let query = "DELETE FROM employee_tbl WHERE NAME_KANJI = '春'"
        if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
            print("insert fail")
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
        }else {
            
            print("insert success")
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("insert ffail")
        }else {
            print("insert ssucess")
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
            
            if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK {
                let err = String(cString: sqlite3_errmsg(db))
                print(err)
                print("emPrepare Statement Fail")
            }else {
                print("emprepare")
            }
            if sqlite3_step(stmt) != SQLITE_ROW {
                print("emsel ffail")
            }else {
                print("emsel ssucess")
                
            }
            let empCount = sqlite3_column_int(stmt, 0)
            print("확인")
            print(empCount)
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
            
            print("rs")
            print(rs)
            
            let employeeCD = "\(current_year_string)-\(current_month_string)\(current_date_string)\(rs)"
            print(employeeCD)
            sqlite3_finalize(stmt)
            return employeeCD
        }
    
    
    typealias LoginRecord = (String, String, String, String)
    
    func find() -> [LoginRecord] {
//        createTable()
        var stmt: OpaquePointer? = nil // 컴파일된 SQL을 담을 객체
        // 반환할 데이터를 담은 [DepartRecord] 타입의 객체 정의
        var loginList = [LoginRecord]()
        
        let sql = "select * from login_tbl"
            
        if sqlite3_prepare(db, sql, -1, &stmt, nil) != SQLITE_OK {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)
            print("Prepare Statement Fail")
        }else {
            print("find() prepare - login테이블의 모든 정보 가지고오기")
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let employeeNum = String(cString: sqlite3_column_text(stmt, 0))
            let employeeID = String(cString: sqlite3_column_text(stmt, 1))
            let employeePW = String(cString: sqlite3_column_text(stmt, 2))
            let lastLogin: String
            if sqlite3_column_text(stmt, 3) != nil {
                lastLogin = String(cString: sqlite3_column_text(stmt, 3))
            } else {
                lastLogin = ""
            }
            loginList.append((employeeNum, employeeID, employeePW, lastLogin))
        }
        sqlite3_finalize(stmt)
        return loginList
    }
    
    
    func loginInfoGet(id: String) -> LoginVO {
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
            print(loginInfo.employeeNum)
            print(loginInfo.employeeEmail)
            sqlite3_finalize(stmt)
            return loginInfo
        } else {
            sqlite3_finalize(stmt)
            return loginInfo
        }
    }
    
   
    typealias empRecord = (String, String, String, String)
    func empList() -> [empRecord] {
//        createTable()
        var stmt: OpaquePointer? = nil // 컴파일된 SQL을 담을 객체
        // 반환할 데이터를 담은 [DepartRecord] 타입의 객체 정의
        var empList = [empRecord]()
        
        let sql = "select * from employee_tbl"
            
        if sqlite3_prepare(db, sql, -1, &stmt, nil) != SQLITE_OK {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)

            print("Prepatre Statement Fail")
        }else {
            print("empList() prepare employee 테이블에서 전부 데이터 가지고 와서 일람화면 만들어주기 위함")
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let empNum = String(cString: sqlite3_column_text(stmt, 0))
            let empKanji = String(cString: sqlite3_column_text(stmt, 1))
            let empPosition = positionChange(ps: String(cString: sqlite3_column_text(stmt, 6)))
            let empTeam = teamChange(team: String(cString: sqlite3_column_text(stmt, 7)))
            empList.append((empNum, empKanji, empPosition, empTeam))
        }
        sqlite3_finalize(stmt)
        return empList
    }
    
    typealias empDetalRecord = (String, String, String, String, String, Int, String, String, String, Int, String)
    func empDetailList() -> [empDetalRecord] {

        var empDetailList = [empDetalRecord]()
        var stmt: OpaquePointer? = nil // 컴파일된 SQL을 담을 객체
  
        
        let sql = "select * from employee_tbl"
            
        if sqlite3_prepare(db, sql, -1, &stmt, nil) != SQLITE_OK {
            let err = String(cString: sqlite3_errmsg(db))
            print(err)

            print("Prepatre Statement Fail")
        }else {
            print("prepare")
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let empNum = String(cString: sqlite3_column_text(stmt, 0))
            let empKanji = String(cString: sqlite3_column_text(stmt, 1))
            let empKana = String(cString: sqlite3_column_text(stmt, 2))
            let empEng = String(cString: sqlite3_column_text(stmt, 3))
            let tel = String(cString: sqlite3_column_text(stmt, 4))
            let gender: Int = Int(sqlite3_column_int(stmt, 5))
            let empPosition = positionChange(ps: String(cString: sqlite3_column_text(stmt, 6)))
            let empTeam = teamChange(team: String(cString: sqlite3_column_text(stmt, 7)))
            let megazine: Int = Int(sqlite3_column_int(stmt, 9))
            let RegDate: String
            if sqlite3_column_text(stmt, 11) != nil {
                RegDate = String(cString: sqlite3_column_text(stmt, 11))
            } else {
                    RegDate = ""
            }
            let memo: String
            if sqlite3_column_text(stmt, 10) != nil {
                memo = String(cString: sqlite3_column_text(stmt, 10	))
            } else {
                memo = ""
            }
            
            empDetailList.append((empNum, empKanji, empKana, empEng, tel, gender, empPosition, empTeam, RegDate, megazine, memo))
        }
     
        sqlite3_finalize(stmt)
       //sqlite3_close(db)
        return empDetailList
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
    
    func update(nameKj: String, nameKn: String, nameEng: String, tel: String, position: String, team: String, megazine: Int, memo: String, empNum: String) {
        var stmt: OpaquePointer? = nil
        let sql = "UPDATE employee_tbl SET NAME_KANJI = '\(nameKj)', NAME_KANA = '\(nameKn)', NAME_ENG = '\(nameEng)', TEL = '\(tel)', POSITION = '\(position)', TEAM = '\(team)', MEGAZINE = '\(megazine)', MEMO = '\(memo)' WHERE EMPLOYEE_NUM = '\(empNum)'"
//        let sql = "UPDATE employee_tbl SET NAME_KANJI = '\(nameKj)', NAME_KANA = '\(nameKn)', NAME_ENG = '\(nameEng)', TEL = '\(tel)', POSITION = '\(position)', TEAM = '\(team)', MEGAZINE = \(megazine), MEMO = '\(memo)' WHERE = EMPLOYEE_NUM = '22-1121---1'"
            // クエリを準備する
            if sqlite3_prepare(db, sql, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
            }
            // クエリを実行する
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero111: \(errmsg)")
                sqlite3_finalize(stmt)
            }
            
    }

    
}


