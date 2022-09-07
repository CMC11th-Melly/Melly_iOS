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
        
    }
    
    func bindOutput() {
        
    }
    
    
}

extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        guard let isValidAccessToken = naverLoginInstance?.isValidAccessTokenExpireTimeNow() else { return }
        if !isValidAccessToken { return }
        guard let accessToken = naverLoginInstance?.accessToken else { return }
        print(accessToken)
        //getJWT(accessToken, provider: "naver")
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
