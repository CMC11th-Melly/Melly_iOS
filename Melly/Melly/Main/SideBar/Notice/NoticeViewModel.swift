//
//  NoticeViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/28.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class NoticeViewModel {
    
    private let disposeBag = DisposeBag()
    
    let input = Input()
    let output = Output()
    
    struct Input {
        
    }
    
    struct Output {
        let noticeData = BehaviorRelay(value: ["", "", "", ""])
    }
    
    
}
