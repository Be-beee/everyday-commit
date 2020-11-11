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
    static let scope = "site_admin user"
    static let reqAuthUrl = "https://github.com/login/oauth/authorize"
    static let tokenReqUrl = "https://github.com/login/oauth/access_token"
    static let reqUserInfoUrl = "https://api.github.com/user"
    static let tokenReqHeader = ("Accept", "application/json")
    static var userInfoHeader = ("Authorization", "token")
    
}

enum ParseType {
    case token, user
}

class TokenInfo: Codable {
    var access_token: String
    var scope: String
    var token_type: String
    
    init(access_token: String, scope: String, token_type: String) {
        self.access_token = access_token
        self.scope = scope
        self.token_type = token_type
    }
}

class UserInfo: Codable { // 필요하면 데이터를 더 가져올 수 있음
    var login: String
    var name: String
    var avatar_url: String
    var bio: String
    var public_repos: Int
    var updated_at: String
    
    init(login: String, name: String, avatar_url: String, bio: String, public_repos: Int, updated_at: String) {
        self.login = login
        self.name = name
        self.avatar_url = avatar_url
        self.bio = bio
        self.public_repos = public_repos
        self.updated_at = updated_at
    }
}

class UserInfoManager {
    static var tokens: TokenInfo?
    static var user: UserInfo?
    static var delegate: LoginDelegate?
    
    static func parseTokens(_ data: Data) -> TokenInfo? {
        // resultData -> UserInfo
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(TokenInfo.self, from: data)
            return response
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func parseUserInfo(_ data: Data) -> UserInfo? {
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
        delegate?.loginSucceessed()
    }
    
    static func requestInfo(_ request: URLRequest, _ parseType: ParseType) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else { return }
            guard let resultData = data else { return }
            if parseType == .token {
                guard let info = parseTokens(resultData) else { return }
                tokens = info
                
                guard let token = tokens?.access_token else { return }
                print(token)
                guard let url = URL(string: ClientLogin.reqUserInfoUrl) else { return }
                var req = URLRequest(url: url)
                req.setValue("token \(token)", forHTTPHeaderField: ClientLogin.userInfoHeader.0)
                requestInfo(req, .user)
            } else {
                guard let info = parseUserInfo(resultData) else { return }
                user = info
                self.loginSuccessed()
            }
        }
        dataTask.resume()
    }
}

protocol LoginDelegate {
    func loginSucceessed()
}
