//
//  LoginViewModel.swift
//  Melly
//
//  Created by Jun on 2022/09/07.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import GoogleSignIn
import KakaoSDKUser
import RxKakaoSDKAuth
import KakaoSDKAuth
import RxKakaoSDKUser

class LoginViewModel {
    
    let input = Input()
    let output = Output()
    let disposeBag = DisposeBag()
    
    struct Input {
        let googleLoginObserver = PublishRelay<UIViewController>()
        let kakaoLoginObserver = PublishRelay<Void>()
    }
    
    struct Output {
        
    }
    
    init() {
        input.googleLoginObserver.flatMap(googleLogin)
            .subscribe { event in
                switch event {
                case .next(_):
                    print("next")
                case .error(let error):
                    print(error)
                case .completed:
                    break
                }
            }.disposed(by: disposeBag)
        
        input.kakaoLoginObserver
            .subscribe(onNext: {
                self.kakaoLogin()
            }).disposed(by: disposeBag)
    }
    
    func googleLogin(_ vc: UIViewController) -> Observable<Void> {
        
        return Observable.create { observe in
            
            let clientID = FirebaseApp.app()?.options.clientID ?? ""
            let signInConfig = GIDConfiguration.init(clientID: clientID)
            
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: vc) { user, error in
                if let error = error {
                    print(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func kakaoLogin() {
        
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe { event in
                    switch event {
                    case .next(let token):
                        print(token)
                    case .completed:
                        break
                    case .error(let error):
                        print(error)
                    }
                }
                .disposed(by: disposeBag)
        } else {
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe { event in
                    switch event {
                    case .next(let token):
                        print(token)
                    case .completed:
                        break
                    case .error(let error):
                        print(error)
                    }
                }
                .disposed(by: disposeBag)
        }
        
    }
    
    
}
