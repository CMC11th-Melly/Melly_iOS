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
        var nameValid = PublishRelay<Bool>()
    }
    
    init(_ user: User) {
        self.user = user
        
    }
    
    
}
