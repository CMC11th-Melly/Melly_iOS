//
//  LoginViewModel.swift
//  Melly
//
//  Created by Jun on 2022/09/07.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
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
        let errorData = PublishRelay<String>()
    }
    
    init() {
        input.googleLoginObserver.flatMap(googleLogin)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorData.accept(error.msg)
                } else if let token = result.success as? (Bool, User) {
                    self.output.outputData.accept(token)
                }
                
            }).disposed(by: disposeBag)
        
        input.kakaoLoginObserver
            .flatMap(kakaoLogin)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorData.accept(error.msg)
                } else if let token = result.success as? (Bool, User) {
                    self.output.outputData.accept(token)
                }
                
            }).disposed(by: disposeBag)
        
        
        input.naverAppleLoginObserver
            .flatMap { self.checkUser(token: $0.0, type: $0.1) }
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorData.accept(error.msg)
                } else if let token = result.success as? (Bool, User) {
                    self.output.outputData.accept(token)
                }
                
            }).disposed(by: disposeBag)
    }
    
    /**
     구글로 로그인 할 때 실행
     >회원가입 유무 확인 후 회원가입 페이지 or 메인화면으로 이동
     - Parameters:
        - vc: UIViewController
     - Throws: MellyError
     - Returns:User
     */
    func googleLogin(_ vc: UIViewController) -> Observable<Result> {
        
        
        return Observable.create { observer in
            
            var result = Result()
            
            GIDSignIn.sharedInstance.signIn(withPresenting: vc) { user, error in
                if let error = error {
                    let mellyError = MellyError(code: 2, msg: error.localizedDescription)
                    result.error = mellyError
                    observer.onNext(result)
                }
                
                if  let auth = user?.user,
                    let userToken = auth.idToken?.tokenString {
                    self.checkUser(token: userToken, type: .google)
                        .subscribe(onNext: { result in
                            observer.onNext(result)
                        }).disposed(by: self.disposeBag)
                }
            }
            
            return Disposables.create()
        }
    }
    
    /**
     카카오로 로그인 할 때 실행
     >회원가입 유무 확인 후 회원가입 페이지 or 메인화면으로 이동
     - Parameters:None
     - Throws: MellyError
     - Returns:User
     */
    func kakaoLogin() -> Observable<Result> {
        
        
        return Observable.create { observer in
            var result = Result()
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .subscribe { event in
                        switch event {
                        case .next(let token):
                            self.checkUser(token: token.accessToken, type: LoginType.kakao)
                                .subscribe(onNext: { result in
                                    observer.onNext(result)
                                }).disposed(by: self.disposeBag)
                        case .completed:
                            break
                        case .error(_):
                            let error = MellyError(code: 2, msg: "네트워크 상태를 확인해주세요.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
                    .disposed(by: self.disposeBag)
            } else {
                UserApi.shared.rx.loginWithKakaoAccount()
                    .subscribe { event in
                        switch event {
                        case .next(let token):
                            self.checkUser(token: token.accessToken, type: LoginType.kakao)
                                .subscribe(onNext: { result in
                                    observer.onNext(result)
                                }).disposed(by: self.disposeBag)
                        case .completed:
                            break
                        case .error(_):
                            let error = MellyError(code: 2, msg: "네트워크 상태를 확인해주세요.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
                    .disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }
        
        
    }
    
    /**
     회원가입 유무 확인 후 회원가입 페이지 or 메인화면으로 이동
     - Parameters:
        - token : String
        - type: LoginType
     - Throws: MellyError
     - Returns:User
     */
    func checkUser(token: String, type: LoginType) -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            
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
                            if let dic = json.data?["user"] as? [String:Any],
                               let newUser = json.data?["newUser"] as? Bool{
                                if var user = dictionaryToObject(objectType: User.self, dictionary: dic) {
                                    let jwtToken = json.data?["token"] as? String ?? ""
                                    user.jwtToken = jwtToken
                                    user.provider = type.rawValue
                                    result.success = (newUser, user)
                                    observer.onNext(result)
                                }
                            }
                        } else {
                            let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                            result.error = error
                            observer.onNext(result)
                        }
                    case .error(_):
                        let error = MellyError(code: 2, msg: "네트워크 상태를 확인해주세요.")
                        result.error = error
                        observer.onNext(result)
                    case .completed:
                        break
                    }
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    
    
}

