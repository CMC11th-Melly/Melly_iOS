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
    
    var memory:Memory? {
        didSet {
            mode = true
            url = "https://api.melly.kr/api/report/memory"
            reportValue = "메모리 신고 완료"
        }
    }
    var comment:Comment? {
        didSet {
            mode = false
            url = "https://api.melly.kr/api/report/comment"
            reportValue = "댓글 신고 완료"
        }
    }
    
    private let disposeBag = DisposeBag()
    
    let data = Observable<[String]>.of(["욕설 또는 비속어를 포함한 메모리", "상업적인 홍보의 목적으로 작성된 메모리", "개인정보 포함 또는 유출 위험이 있는 메모리", "음란성 게시물 또는 청소년에게 부적합한 메모리", "폄하 또는 비방 목적의 메모리", "기타"])
    var resultValue = ""
    var reportValue = ""
    var mode:Bool = false
    
    let input = Input()
    let output = Output()
    var url = ""
    
    
    struct Input {
        let reportTextObserver = PublishRelay<String>()
        let reportObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let textValue = PublishRelay<Bool>()
        let errorValue = PublishRelay<String>()
        let completeValue = PublishRelay<String>()
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
            .flatMap(report)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.completeValue.accept(self.resultValue)
                }
            }).disposed(by: disposeBag)
            
    }
    
    
    /**
     해당 메모리 혹은 댓글을 신고하는 함수
     - Throws: MellyError
     */
    func report() -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            
            if self.reportValue.count < 10 {
                let error = MellyError(code: 999, msg: "사유를 최소 10자 이상 적어주세요")
                result.error = error
                observer.onNext(result)
            } else {
                
                if let user = User.loginedUser {
                    
                    var parameters:Parameters = ["content": self.reportValue]
                    
                    if self.mode { parameters["memoryId"] = self.memory!.memoryId }
                    else { parameters["commentId"] = self.comment!.id }
                    
                    let header:HTTPHeaders = [
                        "Connection":"keep-alive",
                        "Content-Type": "application/json",
                        "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                    
                    AF.request(self.url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                        .responseData { response in
                            switch response.result {
                            case .success(let data):
                                
                                let decoder = JSONDecoder()
                                if let json = try? decoder.decode(ResponseData.self, from: data) {
                                    if json.message == "성공" {
                                        
                                        observer.onNext(result)
                                        
                                    } else {
                                        let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                        result.error = error
                                        observer.onNext(result)
                                    }
                                    
                                } else {
                                    let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                    result.error = error
                                    observer.onNext(result)
                                }
                            case .failure(_):
                                let error = MellyError(code: 2, msg: "네트워크 상태를 확인해주세요.")
                                result.error = error
                                observer.onNext(result)
                            }
                        }
                    
                }
                
            }
            
            return Disposables.create()
        }
        
        
    }
    
    
    
    
}
