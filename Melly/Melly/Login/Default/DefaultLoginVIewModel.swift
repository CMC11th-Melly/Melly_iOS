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
    }
    
    init() {
        
        input.emailObserver
            .subscribe(onNext: { value in
                self.user.email = value
                print(self.user)
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
            .subscribe { event in
                switch event {
                case .next(let str):
                    print(str)
                case .error(let error):
                    print(error.localizedDescription)
                case .completed:
                    break
                }
            }.disposed(by: disposeBag)
        
    }
    
    func login(/*id: String, pw: String*/) -> Observable<String> {
        
        return Observable.create { observer in
            let parameters:Parameters = ["email": self.user.email,
                                         "password": self.user.pw]
            let header:HTTPHeaders = [ "Connection":"close",
                                       "Content-Type":"application/json"]
            
            RxAlamofire.requestData(.post, "http://3.39.218.234/auth/login", parameters: parameters, encoding: JSONEncoding.default, headers: header)
                .subscribe(onNext: { response in
                    if let dataStr = String(data: response.1, encoding: .utf8) {
                        observer.onNext(dataStr)
                    }
                }).disposed(by: self.disposeBag)
            
            
            return Disposables.create()
        }
        
    }
    
}