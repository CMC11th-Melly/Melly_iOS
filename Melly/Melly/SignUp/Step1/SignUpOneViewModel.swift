//
//  SignUpViewModel.swift
//  Melly
//
//  Created by Jun on 2022/09/18.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire


class SignUpOneViewModel {
    
    private var disposeBag = DisposeBag()
    
    let input = Input()
    var output = Output()
    var user:User
    
    struct Input {
        let emailObserver = PublishRelay<String>()
        let pwObserver = PublishRelay<String>()
        let pwCheckObserver = PublishRelay<String>()
        let nextObserver = PublishRelay<Void>()
    }
    
    struct Output {
        var nextValid = PublishRelay<Bool>()
        var emailValid = PublishRelay<EmailValid>()
        var pwValid = PublishRelay<Bool>()
        var pwCheckValid = PublishRelay<Bool>()
        let userValue = PublishRelay<User>()
    }
    
    init(_ user: User) {
        self.user = user
        
        input.emailObserver
            .flatMap(checkID)
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
        
        input.pwCheckObserver
            .map { $0 == self.user.pw }
            .subscribe(onNext: { value in
                self.output.pwCheckValid.accept(value)
            }).disposed(by: disposeBag)
        
        PublishRelay.combineLatest(output.emailValid, output.pwValid, output.pwCheckValid)
            .map { $0 == .correct && $1 && $2 }
            .subscribe(onNext: { valid in
                self.output.nextValid.accept(valid)
            }).disposed(by: disposeBag)
        
        input.nextObserver.subscribe(onNext: {
            self.output.userValue.accept(self.user)
        }).disposed(by: disposeBag)
        
        
    }
    
    func checkID(_ email: String) -> Observable<EmailValid> {
        
        return Observable.create { observer in
            self.user.email = email
            if !email.isEmpty && email.contains(".") && email.contains("@") {
                
                let parameters:Parameters = ["email": email]
                let header:HTTPHeaders = [ "Connection":"close",
                                           "Content-Type":"application/json"]
                
                RxAlamofire.requestData(.post, "https://api.melly.kr/auth/email", parameters: parameters, encoding: JSONEncoding.default, headers: header)
                    .subscribe({ event in
                        switch event {
                        case .next(let response):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: response.1) {
                                if json.message == "사용해도 좋은 이메일입니다." {
                                    observer.onNext(.correct)
                                } else {
                                    observer.onNext(.alreadyExsist)
                                }
                            } else {
                                observer.onNext(.serverError)
                            }
                        case .error(_):
                            observer.onNext(.serverError)
                        case .completed:
                            break
                        }
                    })
                    .disposed(by: self.disposeBag)
                
            } else {
                observer.onNext(.notAvailable)
            }
            
            return Disposables.create()
        }
    }
    
}
