//
//  SignUpZeroViewModel.swift
//  Melly
//
//  Created by Jun on 2022/09/23.
//

import Foundation
import RxCocoa
import RxSwift

class SignUpZeroViewModel {
    
    private let disposeBag = DisposeBag()
    let user:User
    let input = Input()
    let output = Output()
    var allValue = false
    var subValue = [false, false, false]
    
    
    struct Input {
        let allObserver = PublishRelay<Void>()
        let oneObserver = PublishRelay<Int>()
        let twoObserver = PublishRelay<Int>()
        let threeObserver = PublishRelay<Int>()
        let nextObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let allValue = PublishRelay<Bool>()
        let subValue = PublishRelay<[Bool]>()
        let nextValue = PublishRelay<Bool>()
    }
    
    init(_ user: User) {
        self.user = user
        
        input.allObserver
            .subscribe(onNext: { value in
                self.allValue.toggle()
                if self.allValue {
                    self.subValue = [true, true, true]
                    self.output.subValue.accept(self.subValue)
                } else {
                    self.subValue = [false, false, false]
                    self.output.subValue.accept(self.subValue)
                }
                self.output.allValue.accept(self.allValue)
            }).disposed(by: disposeBag)
        
        input.oneObserver
            .subscribe(onNext: { value in
                self.subValue[value].toggle()
                
                if self.subValue == [true, true, true] {
                    self.allValue = true
                    self.output.allValue.accept(self.allValue)
                } else {
                    self.allValue = false
                    self.output.allValue.accept(self.allValue)
                }
                
                self.output.subValue.accept(self.subValue)
            }).disposed(by: disposeBag)
        
        input.twoObserver
            .subscribe(onNext: { value in
                self.subValue[value].toggle()
                if self.subValue == [true, true, true] {
                    self.allValue = true
                    self.output.allValue.accept(self.allValue)
                } else {
                    self.allValue = false
                    self.output.allValue.accept(self.allValue)
                }
                self.output.subValue.accept(self.subValue)
            }).disposed(by: disposeBag)
        
        input.threeObserver
            .subscribe(onNext: { value in
                self.subValue[value].toggle()
                if self.subValue == [true, true, true] {
                    self.allValue = true
                    self.output.allValue.accept(self.allValue)
                } else {
                    self.allValue = false
                    self.output.allValue.accept(self.allValue)
                }
                self.output.subValue.accept(self.subValue)
            }).disposed(by: disposeBag)
        
        input.nextObserver
            .subscribe(onNext: {
                if self.user.provider == LoginType.Default.rawValue {
                    self.output.nextValue.accept(true)
                } else {
                    self.output.nextValue.accept(false)
                }
            }).disposed(by: disposeBag)
        
        
    }
    
    
    
}
