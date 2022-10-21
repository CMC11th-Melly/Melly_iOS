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
import NMapsMap

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //파이어베이스 연결(fcm, google 로그인)
        FirebaseApp.configure()
        
        //카카오 로그인 연결
        KakaoSDK.initSDK(appKey: "4b564f25ca3c49eb0e187ce3b612f51d")
        
        //네이버 로그인 연결
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.isInAppOauthEnable = true
        instance?.isNaverAppOauthEnable = true
        instance?.serviceUrlScheme = "naverlogin"
        instance?.consumerKey = "jtQc03hW31ZbOhWbv35m"
        instance?.consumerSecret = "SabQEJMs1l"
        instance?.appName = "Melly"
        
        //네이버 맵 연결
        NMFAuthManager.shared().clientId = "4f8brsaqzw"
        
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
        
        //카카오 딥링크 연결
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.rx.handleOpenUrl(url: url)
        }
        
        //네이버 딥링크 연결
        let naverInstance = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
        //구글 딥링크 연결
        let googleInstance = GIDSignIn.sharedInstance.handle(url)
        return googleInstance || naverInstance
    }


}

