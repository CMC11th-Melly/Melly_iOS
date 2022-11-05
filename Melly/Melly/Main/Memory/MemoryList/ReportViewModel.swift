//
//  ReportViewModel.swift
//  Melly
//
//  Created by Jun on 2022/11/05.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

class ReportViewModel {
    
    var memory:Memory?
    var comment:Comment?
    
    private let disposeBag = DisposeBag()
    
    let data = Observable<[String]>.of(["욕설 또는 비속어를 포함한 메모리", "상업적인 홍보의 목적으로 작성된 메모리", "개인정보 포함 또는 유출 위험이 있는 메모리", "음란성 게시물 또는 청소년에게 부적합한 메모리", "폄하 또는 비방 목적의 메모리", "기타"])
    
    var reportValue = ""
    
    let input = Input()
    let output = Output()
    
    struct Input {
        let reportTextObserver = PublishRelay<String>()
        let reportObserver = PublishRelay<Void>()
        
    }
    
    struct Output {
        let textValue = PublishRelay<Bool>()
        let errorValue = PublishRelay<String>()
        let completeValue = PublishRelay<Void>()
    }
    
    init() {
        
        input.reportTextObserver.subscribe(onNext: { value in
            self.reportValue = value
            if value == "기타" {
                self.output.textValue.accept(true)
            } else {
                self.output.textValue.accept(false)
            }
            
        }).disposed(by: disposeBag)
        
        input.reportObserver
            .subscribe(onNext: {
                
                if self.checkCount(self.reportValue) {
                    
                } else {
                    self.output.errorValue.accept("사유를 최소 10자 이상 적어주세요")
                }
                
            }).disposed(by: disposeBag)
            
        
    }
    
    func checkCount(_ text: String) -> Bool {
        if text.count >= 10 {
            return true
        } else {
            return false
        }
    }
    
    
}
