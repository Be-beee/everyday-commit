//
//  SceneDelegate.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            let code = url.absoluteString.split(separator: "=").last?.description ?? ""
            if !code.isEmpty {
                let clientData = ClientData()
                var component = URLComponents(string: clientData.tokenReqUrl)
                let required = [
                    URLQueryItem(name: "client_id", value: clientData.client_id),
                    URLQueryItem(name: "client_secret", value: clientData.client_secret),
                    URLQueryItem(name: "code", value: code)
                ]
                component?.queryItems = required
                
                guard let tokenUrl = component?.url else { return }
                var request = URLRequest(url: tokenUrl)
                request.setValue(clientData.tokenReqHeader["contents"] ?? "", forHTTPHeaderField: clientData.tokenReqHeader["title"] ?? "")
                
                UserInfoManager.requestInfo(request, .token, completion: nil, handlingError: nil)
            }
            // code를 활용해 URLSession 후 UserInfo에 값 입력
        }
    }
}

