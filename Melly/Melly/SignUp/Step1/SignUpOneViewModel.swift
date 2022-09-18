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
    var user = User()
    
    struct Input {
        let emailObserver = PublishRelay<String>()
        let pwObserver = PublishRelay<String>()
        let pwCheckObserver = PublishRelay<String>()
        let nextObserver = PublishRelay<Void>()
    }
    
    struct Output {
        var nextValid = PublishRelay<Bool>()
        var emailValid = PublishRelay<Bool>()
        var pwValid = PublishRelay<Bool>()
        var pwCheckValid = PublishRelay<Bool>()
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
        
        input.pwCheckObserver
            .map { $0 == self.user.pw }
            .subscribe(onNext: { value in
                self.output.pwCheckValid.accept(value)
            }).disposed(by: disposeBag)
        
        PublishRelay.combineLatest(output.emailValid, output.pwValid, output.pwCheckValid)
            .map { $0 && $1 && $2 }
            .subscribe(onNext: { valid in
                self.output.nextValid.accept(valid)
            }).disposed(by: disposeBag)
        
        
    }
    
    
}
