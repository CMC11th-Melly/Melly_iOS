//
//  AppDelegate.swift
//  Melly
//
//  Created by Jun on 2022/09/06.
//

import UIKit
import Firebase
import GoogleSignIn
import SnapKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import KakaoSDKCommon
import NaverThirdPartyLogin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: "4b564f25ca3c49eb0e187ce3b612f51d")
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        
        instance?.isInAppOauthEnable = true
        instance?.isNaverAppOauthEnable = true
        instance?.serviceUrlScheme = kServiceAppUrlScheme
        instance?.consumerKey = kConsumerKey
        instance?.consumerSecret = kConsumerSecret
        instance?.appName = kServiceAppName
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.rx.handleOpenUrl(url: url)
        }
        
        let naverInstance = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
        
        let googleInstance = GIDSignIn.sharedInstance.handle(url)
        return googleInstance || naverInstance
    }


}

