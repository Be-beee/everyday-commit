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
        let alert = UIAlertController(title: "알림", message: "로그아웃하시겠습니까?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let logout = UIAlertAction(title: "로그아웃", style: .destructive) { action in
            UserDefaults(suiteName: "group.com.sbk.todaycommit")?.removeObject(forKey: "token")
            UserDefaults(suiteName: "group.com.sbk.todaycommit")?.removeObject(forKey: "userID")
            
            // 화면 이동하기
            guard let loginVC = UIStoryboard(name: "LoginController", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginController else { return }
            loginVC.modalPresentationStyle = .fullScreen

            self.present(loginVC, animated: true, completion: nil)
        }
        alert.addAction(cancel)
        alert.addAction(logout)
        
        self.present(alert, animated: true, completion: nil)
    }
}
