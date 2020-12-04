//
//  ViewController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/09.
//

import UIKit

class LoginController: UIViewController {
    
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
            self.dismiss(animated: true, completion: nil)
        }
    }
}
