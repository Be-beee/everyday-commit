//
//  SettingsController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/11.
//

import UIKit

class SettingsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func logoutGithub(_ sender: UIButton) {
        UserDefaults(suiteName: "group.com.sbk.todaycommit")?.removeObject(forKey: "token")
        self.navigationController?.popViewController(animated: true)
        // logout 안 됨
    }
}
