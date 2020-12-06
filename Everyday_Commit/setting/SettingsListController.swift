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

    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let userDetailVC = UIStoryboard(name: "UserDetailController", bundle: nil).instantiateViewController(withIdentifier: "UserDetailController") as? UserDetailController else { return }
            userDetailVC.modalPresentationStyle = .fullScreen
            self.present(userDetailVC, animated: true, completion: nil)
        case 1:
            if indexPath.row == 0 {
                guard let themeVC = UIStoryboard(name: "ThemeColorController", bundle: nil).instantiateViewController(withIdentifier: "ThemeColorController") as? ThemeColorController else { return }
                themeVC.modalPresentationStyle = .fullScreen
                self.present(themeVC, animated: true, completion: nil)
            } else {
                // application information view
            }
        default:
            print("indexPath section: \(indexPath.section), row: \(indexPath.row)")
        }
        
    }
}
