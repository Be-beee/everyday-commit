//
//  MainController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/10.
//

import UIKit

class MainController: UIViewController {

    @IBOutlet weak var userId: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let id = UserInfoManager.user?.login {
            userId.text = "Hello, \(id)!👋"
        }
    }
    
    
}
