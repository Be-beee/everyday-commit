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
        UserDefaults(suiteName: "group.com.sbk.todaycommit")?.removeObject(forKey: "userID")
        // 화면 이동하기 - 자동 로그인 되어 있는 상황에서는 해당 메서드가 실행 안됨, 수정하기
        self.performSegue(withIdentifier: "toLogin", sender: self)
        
    }
}
