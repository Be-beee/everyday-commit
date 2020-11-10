//
//  Common.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/09.
//

import UIKit

struct ClientLogin {
    static let client_id = "da977e2d6b91ad96896f"
    static let client_secret = "5d06d669663255d70e5341f6284c017d582fa240"
    static let scope = "repo user"
    static let reqAuthUrl = "https://github.com/login/oauth/authorize"
    static let tokenReqUrl = "https://github.com/login/oauth/access_token"
    static let tokenReqHeader = ["Accept": "application/json"]
    
}

class UserInfo: Codable {
    var access_token: String
    var scope: String
    var token_type: String
    
    init(accessToken: String, scope: String, token_type: String) {
        self.access_token = accessToken
        self.scope = scope
        self.token_type = token_type
    }
}

class UserInfoManager {
    static var user: UserInfo?
    static var delegate: LoginDelegate?
    
    static func parseInfo(_ data: Data) -> UserInfo? {
        // resultData -> UserInfo
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(UserInfo.self, from: data)
            return response
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    static func loginSuccessed() {
        // access_token으로 유저 데이터를 가져온다
        delegate?.loginSucceessed()
        print("Login Successed")
    }
}

protocol LoginDelegate {
    func loginSucceessed()
}
