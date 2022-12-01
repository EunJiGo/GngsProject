//
//  ListViewController.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/21.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var listTB: UITabBarItem!
    let dbInfo = DBInfo()
    var list = [ListVO()]
//    var login = [LoginVO()]
    
    override func viewDidLoad() {
        list = dbInfo.listInfoGet()
//        login = dbInfo.loginInfoGet()
        super.viewDidLoad()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.list[indexPath.row]
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cell")
        let empNum = cell?.viewWithTag(1) as? UILabel
        let empKangi = cell?.viewWithTag(2) as? UILabel
        let empPosition = cell?.viewWithTag(3) as? UILabel
        let empTeam = cell?.viewWithTag(4) as? UILabel
        
        empNum?.text = row.employeeNum
        empKangi?.text = row.employeeKj
        empPosition?.text = row.position
        empTeam?.text = row.team
        return cell!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let indexPath = myTableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? UpdateViewController else {
                    fatalError("Failed to prepare UpdateViewController")
                }
                var listEmpUpd = dbInfo.updateDetail(index: indexPath.row)
                destination.listEmpValue = listEmpUpd
            }
        }
    }
}
