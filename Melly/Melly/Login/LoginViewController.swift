//
//  LoginViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/07.
//

import UIKit
import Then
import RxSwift
import RxCocoa
import Firebase
import GoogleSignIn
import RxKakaoSDKAuth
import KakaoSDKAuth
import NaverThirdPartyLogin
import AuthenticationServices

class LoginViewController: UIViewController {
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    let vm = LoginViewModel()
    let disposeBag = DisposeBag()
    
    let googleLoginBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "googleLogo"), for: .normal)
    }
    
    let kakaoLoginBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "kakaoLogo"), for: .normal)
    }
    
    let naverLoginBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "naverLogo"), for: .normal)
    }
    
    let appleLoginBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "appleLogo"), for: .normal)
    }
    
    let loginBt = UIButton(type: .custom).then {
        $0.setTitle("통신확인", for: .normal)
        $0.setTitleColor(UIColor.black, for: .normal)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
}

extension LoginViewController {
    
    func setUI() {
        
        view.backgroundColor = .white
        
        let apiFieldStack = UIStackView(arrangedSubviews: [kakaoLoginBt, naverLoginBt, googleLoginBt, appleLoginBt]).then {
            $0.axis = .horizontal
            $0.spacing = 10
            $0.distribution = .fillEqually
        }
        
        safeArea.addSubview(apiFieldStack)
        apiFieldStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        safeArea.addSubview(loginBt)
        loginBt.snp.makeConstraints {
            $0.top.equalTo(apiFieldStack.snp.bottom).offset(30)
            $0.width.equalTo(100)
            $0.height.equalTo(100)
            $0.centerX.equalToSuperview()
        }
        
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        googleLoginBt.rx.tap
            .map { self }
            .bind(to: vm.input.googleLoginObserver)
            .disposed(by: disposeBag)
        
        kakaoLoginBt.rx.tap
            .bind(to: vm.input.kakaoLoginObserver)
            .disposed(by: disposeBag)
        
        naverLoginBt.rx.tap
            .subscribe(onNext: {
                self.naverLoginInstance?.delegate = self
                self.naverLoginInstance?.requestThirdPartyLogin()
            }).disposed(by: disposeBag)
        
        appleLoginBt.rx.tap
            .subscribe(onNext: {
                self.appleLogin()
            }).disposed(by: disposeBag)
        
        loginBt.rx.tap
            .bind(to: vm.input.defaultLoginObserver)
            .disposed(by: disposeBag)
        
    }
    
    func bindOutput() {
        vm.output.outputData.asSignal()
            .emit(onNext: { value in
                let alertController = UIAlertController(title: "통신", message: value, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self.present(alertController, animated: true)
            }).disposed(by: disposeBag)
    }
    
    
}

extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
    
    private func getNaverInfo() {
        
        guard let isValidAccessToken = naverLoginInstance?.isValidAccessTokenExpireTimeNow() else { return }
        if !isValidAccessToken { return }
        guard let accessToken = naverLoginInstance?.accessToken else { return }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "통신", message: accessToken, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            self.present(alertController, animated: true)
        }
        
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("네아로 로그인")
        self.getNaverInfo()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("tap")
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        naverLoginInstance?.requestDeleteToken()
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error] : ", error.localizedDescription)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func appleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let user = credential.user
            print("👨‍🍳 \(user)")
            if let email = credential.email {
                print("✉️ \(email)")
            }
            if let token = String(data: credential.identityToken ?? Data(), encoding: .utf8) {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "통신", message: token, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error \(error)")
    }
    
    
}
