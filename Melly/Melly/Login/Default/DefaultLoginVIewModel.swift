//
//  DefaultLoginVIewModel.swift
//  Melly
//
//  Created by Jun on 2022/09/16.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

class DefaultLoginViewModel {
    
    private var disposeBag = DisposeBag()
    
    let input = Input()
    var output = Output()
    var user = User()
    
    struct Input {
        let emailObserver = PublishRelay<String>()
        let pwObserver = PublishRelay<String>()
        let loginObserver = PublishRelay<Void>()
    }
    
    struct Output {
        var loginValid = PublishRelay<Bool>()
        var emailValid = PublishRelay<Bool>()
        var pwValid = PublishRelay<Bool>()
        var loginResponse = PublishRelay<MellyError?>()
    }
    
    init() {
        
        input.emailObserver
            .subscribe(onNext: { value in
                self.user.email = value
            }).disposed(by: disposeBag)
        
        input.emailObserver
            .map{!$0.isEmpty && $0.contains(".") && $0.contains("@")}
            .subscribe(onNext: { value in
                self.output.emailValid.accept(value)
            }).disposed(by: disposeBag)
        
        input.pwObserver
            .subscribe(onNext: { value in
                self.user.pw = value
            }).disposed(by: disposeBag)
        
        input.pwObserver
            .map{$0.count >= 8}
            .subscribe(onNext: { value in
                self.output.pwValid.accept(value)
            }).disposed(by: disposeBag)
        
        PublishRelay.combineLatest(output.emailValid, output.pwValid)
            .map { $0 && $1 }
            .subscribe(onNext: { valid in
                self.output.loginValid.accept(valid)
            }).disposed(by: disposeBag)
        
        input.loginObserver
            .flatMap(login)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.loginResponse.accept(error)
                } else if let user = result.success as? User {
                    User.loginedUser = user
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey: "loginUser")
                    UserDefaults.standard.set(user.jwtToken, forKey: "token")
                    self.output.loginResponse.accept(nil)
                }
                
            }).disposed(by: disposeBag)
        
    }
    
    /**
     로그인 메서드
     - Parameters:None
     - Throws: MellyError
     - Returns:User
     */
    func login() -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            
            let parameters:Parameters = ["email": self.user.email,
                                         "password": self.user.pw,
                                         "fcmToken" : UserDefaults.standard.string(forKey: "fcmToken") ?? ""]
            
            let header:HTTPHeaders = [ "Connection":"close",
                                       "Content-Type":"application/json"]
            
            RxAlamofire.requestData(.post, "https://api.melly.kr/auth/login", parameters: parameters, encoding: JSONEncoding.default, headers: header)
                .subscribe({ event in
                    switch event {
                    case .next(let response):
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(ResponseData.self, from: response.1) {
                            if json.message == "로그인 완료" {
                                if let dic = json.data?["user"] as? [String:Any],
                                   let token = json.data?["token"] as? String {
                                 
                                    if var user = dictionaryToObject(objectType: User.self, dictionary: dic) {
                                        user.jwtToken = token
                                        result.success = user
                                        observer.onNext(result)
                                    }
                                }
                            } else {
                                let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                result.error = error
                                observer.onNext(result)
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
