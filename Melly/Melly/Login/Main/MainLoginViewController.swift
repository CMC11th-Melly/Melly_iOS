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

class MainLoginViewController: UIViewController {
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    let vm = MainLoginViewModel()
    let disposeBag = DisposeBag()
    
    let welcomeLabel = UILabel().then {
        $0.text = "어서오세요,\n소중한 메모리를 담아보세요!"
        $0.font = UIFont.systemFont(ofSize: 26)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    let logoImageView = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
    
    let loginBT = CustomButton(title: "로그인")
    let signUpBT = CustomButton(title: "회원가입")
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
}

extension MainLoginViewController {
    
    func setUI() {
        
        view.backgroundColor = .white
        
        safeArea.addSubview(welcomeLabel)
        welcomeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(91)
            $0.centerX.equalToSuperview()
        }
        
        safeArea.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(71)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(248)
            $0.height.equalTo(163)
        }
        
        safeArea.addSubview(loginBT)
        loginBT.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(91)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        safeArea.addSubview(signUpBT)
        signUpBT.snp.makeConstraints {
            $0.top.equalTo(loginBT.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        let apiFieldStack = UIStackView(arrangedSubviews: [kakaoLoginBt, naverLoginBt, googleLoginBt, appleLoginBt]).then {
            $0.axis = .horizontal
            $0.spacing = 28
            $0.distribution = .fillEqually
        }

        safeArea.addSubview(apiFieldStack)
        apiFieldStack.snp.makeConstraints {
            $0.top.equalTo(signUpBT.snp.bottom).offset(46)
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
        
        loginBT.rx.tap
            .bind(to: vm.input.defaultLoginObserver)
            .disposed(by: disposeBag)
        
        signUpBT.rx.tap
            .bind(to: vm.input.signupObserver)
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

extension MainLoginViewController: NaverThirdPartyLoginConnectionDelegate {
    
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

extension MainLoginViewController: ASAuthorizationControllerDelegate {
    
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