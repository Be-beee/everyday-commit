//
//  ViewController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/09.
//

import UIKit
import WidgetKit

class LoginController: UIViewController {
    
    var clientData = ClientData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLightModeOnly()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func loginGithub(_ sender: UIButton) {
        let clientID = clientData.client_id
        let scope = clientData.scope
        let urlString = clientData.reqAuthUrl
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
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
