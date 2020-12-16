//
//  Common.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/09.
//

import UIKit

struct ClientData: Codable {
    var client_id: String
    var client_secret: String
    var scope: String
    var reqAuthUrl: String
    var tokenReqUrl: String
    var reqUserInfoUrl: String
    var tokenReqHeader: [String: String]
    var userInfoHeader: [String: String]
    
    init() {
        let path = Bundle.main.path(forResource: "OAuthData", ofType: "plist")!
        let xml = FileManager.default.contents(atPath: path)!
        let clientData = try! PropertyListDecoder().decode(ClientData.self,from: xml)
        
        client_id = clientData.client_id
        client_secret = clientData.client_secret
        scope = clientData.scope
        reqAuthUrl = clientData.reqAuthUrl
        tokenReqUrl = clientData.tokenReqUrl
        reqUserInfoUrl = clientData.reqUserInfoUrl
        tokenReqHeader = clientData.tokenReqHeader
        userInfoHeader = clientData.userInfoHeader
    }
}

extension UserDefaults {
    static var shared: UserDefaults? {
        let shared = UserDefaults(suiteName: "group.com.sbk.todaycommit")
        return shared
    }
}

enum ParseType {
    case token, user, repo
}

struct TokenInfo: Codable {
    var access_token: String
    var scope: String
    var token_type: String
    
    init(access_token: String, scope: String, token_type: String) {
        self.access_token = access_token
        self.scope = scope
        self.token_type = token_type
    }
}

struct UserInfo: Codable {
    var login: String
    var name: String?
    var avatar_url: String?
    var bio: String?
    var company: String?
    var location: String?
    var email: String?
    var blog: String?
    var twitter_username: String?
}

class UserInfoManager {
    static var tokens: TokenInfo?
    static var user: UserInfo?
    static var delegate: LoginDelegate?
    
    static var clientData = ClientData()
    
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
    
    static func requestInfo(_ request: URLRequest, _ parseType: ParseType, completion: (() -> Void)?, handlingError: (() -> Void)?) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else {
                DispatchQueue.main.async {
                    handlingError?()
                }
                return
            }
            guard let resultData = data else { return }
            if parseType == .token {
                guard let info = parseTokens(resultData) else { return }
                tokens = info
                
                guard let token = tokens?.access_token else { return }
                UserDefaults.shared?.set(token, forKey: "token")
                guard let url = URL(string: clientData.reqUserInfoUrl) else { return }
                var req = URLRequest(url: url)
                req.setValue("token \(token)", forHTTPHeaderField: clientData.userInfoHeader["title"] ?? "Authorization")
                requestInfo(req, .user, completion: nil, handlingError: nil)
            } else if parseType == .user {
                guard let info = parseUserInfo(resultData) else { return }
                user = info
                if let userDefault = UserDefaults.shared, userDefault.string(forKey: "userID") == nil {
                    userDefault.set(user?.login, forKey: "userID")
                }
                DispatchQueue.main.async {
                    completion?()
                }
                self.loginSuccessed()
            }
        }
        dataTask.resume()
    }
}

//typealias UserCommitData = (date: String, count: Int)
struct UserCommitData {
    var date: String = "yyyy-MM-dd"
    var count = 0
    var score = 0
}
struct UserContributions {
    var total: Int = 0
    var commitHistory: [UserCommitData] = []
}

enum Tag {
    case h2, rect, none
}

class ContributionsParser: NSObject, XMLParserDelegate {
    var userContributions = UserContributions()
    var tag: Tag = .none
    var totalString = ""
    override init() {
        super.init()
    }
    
    init(data: Data) {
        super.init()
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        getTotal()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "h2" {
            tag = .h2
        } else if elementName == "rect" {
            tag = .rect
            if let date = attributeDict["data-date"], let count = attributeDict["data-count"], let score = attributeDict["fill"] {
                var commitData = UserCommitData(date: date, count: Int(count) ?? 0, score: 0)
                if score.contains("L1") {
                    commitData.score = 1
                } else if score.contains("L2") {
                    commitData.score = 2
                } else if score.contains("L3") || score.contains("L4") {
                    commitData.score = 3
                }
                userContributions.commitHistory.insert(commitData, at: 0)
            }
        } else {
            tag = .none
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if tag == .h2 {
            totalString += string
        }
    }
    
    func getTotal() {
        let tmp = totalString.components(separatedBy: " ").filter{ $0 != "" && $0 != "\n" }
        userContributions.total = Int(tmp[0]) ?? 0
    }
}

extension UIViewController {
    func setLightModeOnly() {
        overrideUserInterfaceStyle = .light
    }
}


protocol LoginDelegate {
    func loginSucceessed()
}
