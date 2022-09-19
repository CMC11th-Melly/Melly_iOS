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
    }
    
    struct Output {
        var nameValid = PublishRelay<EmailValid>()
    }
    
    init(_ user: User) {
        self.user = user
        
        input.nameObserver
            .flatMap(checkName)
            .subscribe(onNext: { value in
                self.output.nameValid.accept(value)
            }).disposed(by: disposeBag)
        
        
    }
    
    func checkName(_ name: String) -> Observable<EmailValid> {
        
        return Observable.create { observer in
            self.user.name = name
            if name.count > 3 {
                
                let parameters:Parameters = ["nickname": name]
                let header:HTTPHeaders = [ "Connection":"close",
                                           "Content-Type":"application/json"]
                
                RxAlamofire.requestData(.post, "http://3.39.218.234/auth/nickname", parameters: parameters, encoding: JSONEncoding.default, headers: header)
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
                observer.onNext(.nameNotAvailable)
            }
            
            return Disposables.create()
        }
        
    }
    
}
