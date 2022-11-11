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
        let initialObserver = PublishRelay<Void>()
        let selectNoticeObserver = PublishRelay<Push>()
        
    }
    
    struct Output {
        let noticeData = PublishRelay<[Push]>()
        let selectMemory = PublishRelay<Memory>()
        let isNoData = PublishRelay<Bool>()
        let errorValue = PublishRelay<String>()
    }
    
    init() {
        
        input.initialObserver
            .flatMap(getNotices)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let push = result.success as? [Push] {
                    self.output.noticeData.accept(push)
                    self.output.isNoData.accept(push.isEmpty)
                }
                
            }).disposed(by: disposeBag)
        
        input.selectNoticeObserver
            .flatMap(selectNotice)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let memory = result.success as? Memory {
                    self.output.selectMemory.accept(memory)
                }
                
            }).disposed(by: disposeBag)
        
        
    }
    
    
    /**
     푸시 알림 선택 시 해당 메모리로 이동
     - Parameters:
        -push: Push
     - Throws: MellyError
     - Returns:Memory
     */
    func selectNotice(_ push: Push) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let parameters:Parameters = ["notificationId": push.notificationId]
                
                let url = "https://api.melly.kr/api/notification/check"
                
                AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                        
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "성공" {
                                    result.success = push.memory
                                    observer.onNext(result)
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                            }
                        case .failure(let error):
                            let mellyError = MellyError(code: 2, msg: error.localizedDescription)
                            result.error = mellyError
                            observer.onNext(result)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    /**
     푸시 알림 리스트 호춯
     - Parameters:None
     - Throws: MellyError
     - Returns : [Push]
     */
    func getNotices() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                
                let url = "https://api.melly.kr/api/notification"
                
                AF.request(url, method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                        
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "알림 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["data"] as Any) {
                                        
                                        if let pushs = try? decoder.decode([Push].self, from: data) {
                                            result.success = pushs
                                            observer.onNext(result)
                                        }
                                    }
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                            }
                        case .failure(let error):
                            let mellyError = MellyError(code: 2, msg: error.localizedDescription)
                            result.error = mellyError
                            observer.onNext(result)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    
    
    
    
    
    
}
