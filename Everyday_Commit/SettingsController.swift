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
    @IBAction func logout(_ sender: Any) {
        UserDefaults(suiteName: "group.com.sbk.todaycommit")?.removeObject(forKey: "token")
        // 화면 이동하기
        self.performSegue(withIdentifier: "toLogin", sender: self)
    }
}
