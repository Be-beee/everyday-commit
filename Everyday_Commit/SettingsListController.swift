//
//  SettingsListController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/20.
//

import UIKit

class SettingsListController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            UserDefaults(suiteName: "group.com.sbk.todaycommit")?.removeObject(forKey: "token")
            // 화면 이동하기
            // self.performSegue
        default:
            print("indexPath section: \(indexPath.section), row: \(indexPath.row)")
        }
        
    }
}
