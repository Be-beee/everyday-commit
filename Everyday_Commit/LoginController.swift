//
//  ViewController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/09.
//

import UIKit

// 참고: https://docs.github.com/en/enterprise-server@2.21/developers/apps/authorizing-oauth-apps

class LoginController: UIViewController {
    @IBOutlet weak var userId: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func loginGithub(_ sender: UIButton) {
        let clientID = ClientLogin.client_id
        let scope = ClientLogin.scope
        let urlString = ClientLogin.reqAuthUrl
        var components = URLComponents(string: urlString)!
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: scope)
        ]
        guard let url = components.url else { return }
        UserInfoManager.delegate = self
        UIApplication.shared.open(url)
    }
    
}

extension LoginController: LoginDelegate {
    func loginSucceessed() {
        DispatchQueue.main.async {
            self.userId.text = "Login Successed"
            
            guard let mainVC = UIStoryboard(name: "MainController", bundle: nil).instantiateViewController(withIdentifier: "MainTabVC") as? UITabBarController else { return }
            self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }
}
