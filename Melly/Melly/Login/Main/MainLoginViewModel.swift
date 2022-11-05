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

class MainLoginViewModel {
    
    let input = Input()
    let output = Output()
    let disposeBag = DisposeBag()
    var user = User()
    
    struct Input {
        let googleLoginObserver = PublishRelay<UIViewController>()
        let kakaoLoginObserver = PublishRelay<Void>()
        let naverAppleLoginObserver = PublishRelay<(String, LoginType)>()
    }
    
    struct Output {
        
        let outputData = PublishRelay<(Bool, User)>()
        let errorData = PublishRelay<MellyError>()
    }
    
    init() {
        input.googleLoginObserver.flatMap(googleLogin)
            .subscribe { event in
                switch event {
                case .next(let token):
                    self.output.outputData.accept(token)
                case .error(let error):
                    if var mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            mellyError.msg = error.localizedDescription
                            self.output.errorData.accept(mellyError)
                        } else {
                            self.output.errorData.accept(mellyError)
                        }
                    }
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
                    if var mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            mellyError.msg = error.localizedDescription
                            self.output.errorData.accept(mellyError)
                        } else {
                            self.output.errorData.accept(mellyError)
                        }
                    }
                case .completed:
                    break
                }
            }.disposed(by: disposeBag)
        
        
        input.naverAppleLoginObserver
            .flatMap { self.checkUser(token: $0.0, type: $0.1) }
            .subscribe { event in
                switch event {
                case .next(let value):
                    self.output.outputData.accept(value)
                case .error(let error):
                    if var mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            mellyError.msg = error.localizedDescription
                            self.output.errorData.accept(mellyError)
                        } else {
                            self.output.errorData.accept(mellyError)
                        }
                    }
                case .completed:
                    break
                }
            }.disposed(by: disposeBag)
    }
    
    func googleLogin(_ vc: UIViewController) -> Observable<(Bool, User)> {
        
        return Observable.create { observe in
            
            let clientID = FirebaseApp.app()?.options.clientID ?? ""
            let signInConfig = GIDConfiguration.init(clientID: clientID)
            
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: vc) { user, error in
                if let error = error {
                    observe.onError(error)
                }
                
                if let userToken = user?.authentication.idToken {
                    self.checkUser(token: userToken, type: .google)
                        .subscribe(onNext: { value in
                            observe.onNext(value)
                        }).disposed(by: self.disposeBag)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func kakaoLogin() -> Observable<(Bool, User)> {
        
        
        return Observable.create { observer in
            
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .subscribe { event in
                        switch event {
                        case .next(let token):
                            
                            self.checkUser(token: token.accessToken, type: LoginType.kakao)
                                .subscribe { event in
                                    switch event {
                                    case .next(let user):
                                        observer.onNext(user)
                                    case .completed:
                                        break
                                    case .error(let error):
                                        observer.onError(error)
                                    }
                                }.disposed(by: self.disposeBag)
                            
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
                            self.checkUser(token: token.accessToken, type: LoginType.kakao)
                                .subscribe { event in
                                    switch event {
                                    case .next(let user):
                                        observer.onNext(user)
                                    case .completed:
                                        break
                                    case .error(let error):
                                        observer.onError(error)
                                    }
                                }.disposed(by: self.disposeBag)
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
    
    func checkUser(token: String, type: LoginType) -> Observable<(Bool, User)> {
        
        return Observable.create { observer in
            
            let parameters:Parameters = ["accessToken": token,
                                         "provider": type.rawValue,
                                         "fcmToken" : UserDefaults.standard.string(forKey: "fcmToken") ?? ""]
            
            let header:HTTPHeaders = [ "Connection":"close",
                                       "Content-Type":"application/json"]
            
            
            RxAlamofire.requestData(.post, "https://api.melly.kr/auth/social", parameters: parameters, encoding: JSONEncoding.default, headers: header)
                .subscribe({ event in
                    switch event {
                    case .next(let response):
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(ResponseData.self, from: response.1) {
                            if let dic = json.data?["user"] as? [String:Any] {
                                if var user = dictionaryToObject(objectType: User.self, dictionary: dic) {
                                    user.provider = type.rawValue
                                    let newUser = json.data?["newUser"] as! Bool
                                    observer.onNext((newUser, user))
                                }
                            }
                        } else {
                            let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                            observer.onError(error)
                        }
                    case .error(let error):
                        observer.onError(error)
                    case .completed:
                        break
                    }
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    
}

