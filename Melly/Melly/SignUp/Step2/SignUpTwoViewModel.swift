//
//  SignUpTwoViewModel.swift
//  Melly
//
//  Created by Jun on 2022/09/18.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

class SignUpTwoViewModel {
    
    private var disposeBag = DisposeBag()
    
    let input = Input()
    var output = Output()
    var user:User
    
    struct Input {
        let nameObserver = PublishRelay<String>()
        let nextObserver = PublishRelay<Void>()
    }
    
    struct Output {
        var nameValid = PublishRelay<EmailValid>()
        let nextEvent = PublishRelay<User>()
    }
    
    init(_ user: User) {
        self.user = user
        
        input.nameObserver
            .flatMap(checkName)
            .subscribe(onNext: { value in
                self.output.nameValid.accept(value)
            }).disposed(by: disposeBag)
        
        input.nextObserver.subscribe(onNext: {
            self.output.nextEvent.accept(self.user)
        }).disposed(by: disposeBag)
        
        
    }
    
    func isValidName(_ name: String) -> Bool {
        let nickRegEx = "[가-힣A-Za-z0-9]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", nickRegEx)
        return pred.evaluate(with: name)
    }
    
    func checkName(_ name: String) -> Observable<EmailValid> {
        
        return Observable.create { observer in
            self.user.nickname = name
            if name.count > 1 {
                
                if self.isValidName(name) {
                    let parameters:Parameters = ["nickname": name]
                    let header:HTTPHeaders = [ "Connection":"close",
                                               "Content-Type":"application/json"]
                    
                    RxAlamofire.requestData(.post, "https://api.melly.kr/auth/nickname", parameters: parameters, encoding: JSONEncoding.default, headers: header)
                        .subscribe({ event in
                            switch event {
                            case .next(let response):
                                let decoder = JSONDecoder()
                                if let json = try? decoder.decode(ResponseData.self, from: response.1) {
                                    print(json)
                                    if json.message == "사용해도 좋은 닉네임입니다." {
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
                    observer.onNext(.nameNotAvailable)
                }
                
            } else {
                observer.onNext(.nameCountNotAvailable)
            }
            
            return Disposables.create()
        }
        
    }
    
}
