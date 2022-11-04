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
        let errorValue = PublishRelay<String>()
    }
    
    init() {
        
        input.initialObserver
            .flatMap(getNotices)
            .subscribe({ event in
                switch event {
                case .next(let push):
                    self.output.noticeData.accept(push)
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.errorValue.accept(error.localizedDescription)
                        } else {
                            self.output.errorValue.accept(mellyError.msg)
                        }
                    }
                case .completed:
                    break
                }
            }).disposed(by: disposeBag)
        
        input.selectNoticeObserver
            .flatMap(selectNotice)
            .subscribe({ event in
                switch event {
                case .next(let memory):
                    self.output.selectMemory.accept(memory)
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.errorValue.accept(error.localizedDescription)
                        } else {
                            self.output.errorValue.accept(mellyError.msg)
                        }
                    }
                case .completed:
                    break
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
    func selectNotice(_ push: Push) -> Observable<Memory> {
        
        return Observable.create { observer in
            
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
                                print(json)
                                if json.message == "성공" {
                                    
                                    observer.onNext(push.memory)
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    observer.onError(error)
                                }
                            }
                        case .failure(let error):
                            observer.onError(error)
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
    func getNotices() -> Observable<[Push]> {
        
        return Observable.create { observer in
            
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
                                print(json)
                                if json.message == "알림 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["data"] as Any) {
                                        
                                        if let pushs = try? decoder.decode([Push].self, from: data) {
                                            
                                            observer.onNext(pushs)
                                        }
                                    }
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    observer.onError(error)
                                }
                            }
                        case .failure(let error):
                            observer.onError(error)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    
    
    
    
    
    
}
