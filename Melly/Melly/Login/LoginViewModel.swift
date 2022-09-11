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
import Alamofire
import RxAlamofire

class LoginViewModel {
    
    let input = Input()
    let output = Output()
    let disposeBag = DisposeBag()
    
    struct Input {
        let googleLoginObserver = PublishRelay<UIViewController>()
        let kakaoLoginObserver = PublishRelay<Void>()
        let appleLoginObserver = PublishRelay<Void>()
        let defaultLoginObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let outputData = PublishRelay<String>()
    }
    
    init() {
        input.googleLoginObserver.flatMap(googleLogin)
            .subscribe { event in
                switch event {
                case .next(let token):
                    self.output.outputData.accept(token)
                case .error(let error):
                    print(error)
                case .completed:
                    break
                }
            }.disposed(by: disposeBag)
        
        input.kakaoLoginObserver
            .flatMap(kakaoLogin)
            .subscribe{ event in
                switch event {
                case .next(let token):
                    self.output.outputData.accept(token)
                case .error(let error):
                    print(error)
                case .completed:
                    break
                }
            }.disposed(by: disposeBag)
        
        input.defaultLoginObserver
            .flatMap(checkServer)
            .subscribe { event in
                switch event {
                case .next(let result):
                    self.output.outputData.accept(result)
                case .error(let error):
                    print(error)
                case .completed:
                    break
                }
            }.disposed(by: disposeBag)
        
    }
    
    func googleLogin(_ vc: UIViewController) -> Observable<String> {
        
        return Observable.create { observe in
            
            let clientID = FirebaseApp.app()?.options.clientID ?? ""
            let signInConfig = GIDConfiguration.init(clientID: clientID)
            
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: vc) { user, error in
                if let error = error {
                    observe.onError(error)
                }
                
                if let userToken = user?.authentication.idToken {
                    observe.onNext(userToken)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func kakaoLogin() -> Observable<String> {
        
        
        return Observable.create { observer in
            
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .subscribe { event in
                        switch event {
                        case .next(let token):
                            observer.onNext(token.accessToken)
                        case .completed:
                            break
                        case .error(let error):
                            observer.onError(error)
                        }
                    }
                    .disposed(by: self.disposeBag)
            } else {
                UserApi.shared.rx.loginWithKakaoAccount()
                    .subscribe { event in
                        switch event {
                        case .next(let token):
                            observer.onNext(token.accessToken)
                        case .completed:
                            break
                        case .error(let error):
                            observer.onError(error)
                        }
                    }
                    .disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }
        
        
    }
    
    func checkServer() -> Observable<String> {
        
        return Observable.create { observer in
            
            RxAlamofire.requestData(.get, "http://3.39.218.234/api/health")
                .subscribe(onNext: { response in
                    if let dataStr = String(data: response.1, encoding: .utf8) {
                        observer.onNext(dataStr)
                    }
                }).disposed(by: self.disposeBag)
            
            
            return Disposables.create()
        }
    }
    
    
}
