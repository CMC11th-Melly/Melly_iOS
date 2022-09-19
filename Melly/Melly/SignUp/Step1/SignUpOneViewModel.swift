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

enum EmailValid:String {
    case notAvailable = "올바른 이메일 형식이 아닙니다."
    case alreadyExsist = "이미 존재하는 아이디입니다."
    case serverError = "네트워크 상태를 확인해주세요."
    case correct = ""
    case nameNotAvailable = "이름은 한글, 영어만 입력 가능해요."
}

class SignUpOneViewModel {
    
    private var disposeBag = DisposeBag()
    
    let input = Input()
    var output = Output()
    var user = User()
    
    struct Input {
        let emailObserver = PublishRelay<String>()
        let pwObserver = PublishRelay<String>()
        let pwCheckObserver = PublishRelay<String>()
    }
    
    struct Output {
        var nextValid = PublishRelay<Bool>()
        var emailValid = PublishRelay<EmailValid>()
        var pwValid = PublishRelay<Bool>()
        var pwCheckValid = PublishRelay<Bool>()
    }
    
    init() {
        
        
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
        
        
    }
    
    func checkID(_ email: String) -> Observable<EmailValid> {
        
        return Observable.create { observer in
            self.user.email = email
            if !email.isEmpty && email.contains(".") && email.contains("@") {
                
                let parameters:Parameters = ["email": email]
                let header:HTTPHeaders = [ "Connection":"close",
                                           "Content-Type":"application/json"]
                
                RxAlamofire.requestData(.post, "http://3.39.218.234/auth/email", parameters: parameters, encoding: JSONEncoding.default, headers: header)
                    .subscribe({ event in
                        switch event {
                        case .next(let response):
                            if let json = try? JSONSerialization.jsonObject(with: response.1, options: []) as? [String:Any] {
                                if let isTrue = json["duplicated"] as? Bool {
                                    observer.onNext(isTrue ? .alreadyExsist : .correct)
                                } else {
                                    observer.onNext(.serverError)
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
