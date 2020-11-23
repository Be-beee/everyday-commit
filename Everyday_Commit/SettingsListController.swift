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
        case 0:
            guard let userDetailVC = UIStoryboard(name: "UserDetailController", bundle: nil).instantiateViewController(withIdentifier: "UserDetailController") as? UserDetailController else { return }
            self.present(userDetailVC, animated: true, completion: nil)
        default:
            print("indexPath section: \(indexPath.section), row: \(indexPath.row)")
        }
        
    }
}
