//
//  ListViewController.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/21.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dbInfo = DBInfo()
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var listTB: UITabBarItem!
    
    var employeeList: [(empNum: String, empKanzi: String, empPosition: String, empTeam: String)]!
    
    override func viewDidLoad() {
        employeeList = dbInfo.empList()
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.employeeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.employeeList[indexPath.row]
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cell")
        
        let empNum = cell?.viewWithTag(1) as? UILabel
        let empKangi = cell?.viewWithTag(2) as? UILabel
        let empPosition = cell?.viewWithTag(3) as? UILabel
        let empTeam = cell?.viewWithTag(4) as? UILabel
        
        empNum?.text = row.empNum
        empKangi?.text = row.empKanzi
        empPosition?.text = row.empPosition
        empTeam?.text = row.empTeam
        
        return cell!
    }
    
    typealias empDetailRecord = (String, String, String, String, String, Int, String, String, String, Int, String)
    var empDetailList = [empDetailRecord]()
    typealias LoginRecord = (String, String, String, String)
    var loginList = [LoginRecord]()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let indexPath = myTableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? UpdateViewController else {
                    fatalError("Failed to prepare UpdateViewController")
                }
                let empEmail = dbInfo.find()[indexPath.row].1
                empDetailList = dbInfo.empDetailList()
                destination.empDetailList = empDetailList
                destination.idxNum = indexPath.row
                destination.employEmail = empEmail
            }
        }
    }
        
    

    
    
}
