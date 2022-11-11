//
//  SceneDelegate.swift
//  Melly
//
//  Created by Jun on 2022/09/06.
//

import UIKit
import KakaoSDKAuth
import NaverThirdPartyLogin
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
        self.window = window
        
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        //카카오 딥링크 연결
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
        
        //네이버 딥링크 연결
        NaverThirdPartyLoginConnection.getSharedInstance()?.receiveAccessToken(URLContexts.first?.url)
        
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL {
            _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                self.handleDynamicLink(dynamicLink)
            }
        }
    }
    
    
    
    func handleDynamicLink(_ dynamicLink: DynamicLink?) {
        guard let dynamicLink = dynamicLink, let deepLink = dynamicLink.url else {
            return
        }

        
        let components = URLComponents(string: deepLink.absoluteString)?.path
        
        if let components = components {
            
            if components == "/invite_group" {
                let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
                
                let groupId = queryItems?.filter({$0.name == "groupId"}).first?.value ?? ""
                let userId = queryItems?.filter({$0.name == "userId"}).first?.value ?? ""
                
                if let _ = User.loginedUser {
                    NotificationCenter.default.post(name: NSNotification.InviteGroupNotification, object: [groupId, userId])
                } else {
                    UserDefaults.standard.setValue([groupId, userId], forKey: "InviteGroup")
                }
                
                
            } else {
                let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
                
                let memoryId = queryItems?.filter({$0.name == "memoryId"}).first?.value ?? ""
                
                if let _ = User.loginedUser {
                    NotificationCenter.default.post(name: NSNotification.MemoryShareNotification, object: memoryId)
                } else {
                    UserDefaults.standard.setValue(memoryId, forKey: "MemoryShare")
                }
                
            }
            
        }
        
       

        
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


}

