//
//  SettingViewModel.swift
//  Melly
//
//  Created by Jun on 2022/11/04.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class SettingViewModel {
    
    private let disposeBag = DisposeBag()
    
    var pushInfo:[Bool] = [false, false]
    
    let input = Input()
    let output = Output()
    struct Input {
        
        let settingObserver = PublishRelay<Void>()
        let commentLikeOnObserver = PublishRelay<Void>()
        let commentLikeOffObserver = PublishRelay<Void>()
        let commentPushOnObserver = PublishRelay<Void>()
        let commentPushOffObserver = PublishRelay<Void>()
        
    }
    
    struct Output {
        let getInitialValue = PublishRelay<Void>()
        let errorValue = PublishRelay<String>()
    }
    
    init() {
        
        input.settingObserver
            .flatMap(getMyPushSetting)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.getInitialValue.accept(())
                }
                
            }).disposed(by: disposeBag)
        
        input.commentLikeOffObserver
            .flatMap(commentLikePushOff)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                }
            }).disposed(by: disposeBag)
        
        input.commentLikeOnObserver
            .flatMap(commentLikePushOn)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                }
            }).disposed(by: disposeBag)
        
        input.commentPushOnObserver
            .flatMap(commentPushOn)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                }
            }).disposed(by: disposeBag)
        
        input.commentPushOffObserver
            .flatMap(commentPushOff)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } 
            }).disposed(by: disposeBag)
        
    }
    
    /**
     ?????? ????????? ???????????? ?????? ?????? ??????
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func getMyPushSetting() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/notification/setting"
                
                AF.request(url, method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                        
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "??????" {
                                    
                                    observer.onNext(result)
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                            }
                        case .failure(_):
                            let error = MellyError(code: 2, msg: "???????????? ????????? ??????????????????.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    /**
     ?????? ?????? ?????? ?????? On
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func commentPushOn() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/notification/setting/comment"
                
                AF.request(url, method: .post, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                        
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "??????" {
                                    
                                    observer.onNext(result)
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                            }
                        case .failure(_):
                            let error = MellyError(code: 2, msg: "???????????? ????????? ??????????????????.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    /**
     ?????? ?????? ?????? ?????? Off
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func commentPushOff() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/notification/setting/comment"
                
                AF.request(url, method: .delete, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                        
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "??????" {
                                    
                                    observer.onNext(result)
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                            }
                        case .failure(_):
                            let error = MellyError(code: 2, msg: "???????????? ????????? ??????????????????.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    /**
     ?????? ?????? ????????? ?????? Off
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func commentLikePushOff() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/notification/setting/comment/like"
                
                AF.request(url, method: .delete, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                        
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "??????" {
                                    
                                    observer.onNext(result)
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                            }
                        case .failure(_):
                            let error = MellyError(code: 2, msg: "???????????? ????????? ??????????????????.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    /**
     ?????? ?????? ????????? ?????? On
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func commentLikePushOn() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/notification/setting/comment/like"
                
                AF.request(url, method: .post, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                        
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "??????" {
                                    
                                    observer.onNext(result)
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                            }
                        case .failure(_):
                            let error = MellyError(code: 2, msg: "???????????? ????????? ??????????????????.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    
    
    
}
