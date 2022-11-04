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
            .subscribe({ event in
                switch event {
                case .next(_):
                    self.output.getInitialValue.accept(())
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
        
        input.commentLikeOffObserver
            .flatMap(commentLikePushOff)
            .subscribe({ event in
                switch event {
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.errorValue.accept(error.localizedDescription)
                        } else {
                            self.output.errorValue.accept(mellyError.msg)
                        }
                    }
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        input.commentLikeOnObserver
            .flatMap(commentLikePushOn)
            .subscribe({ event in
                switch event {
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.errorValue.accept(error.localizedDescription)
                        } else {
                            self.output.errorValue.accept(mellyError.msg)
                        }
                    }
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        input.commentPushOnObserver
            .flatMap(commentPushOn)
            .subscribe({ event in
                switch event {
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.errorValue.accept(error.localizedDescription)
                        } else {
                            self.output.errorValue.accept(mellyError.msg)
                        }
                    }
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        input.commentPushOffObserver
            .flatMap(commentPushOff)
            .subscribe({ event in
                switch event {
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.errorValue.accept(error.localizedDescription)
                        } else {
                            self.output.errorValue.accept(mellyError.msg)
                        }
                    }
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
    }
    
    /**
     해당 유저의 푸시알림 설정 유무 조회
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func getMyPushSetting() -> Observable<Void> {
        
        return Observable.create { observer in
            
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
                                
                                if json.message == "성공" {
                                    
                                    if let enableContentLike = json.data?["enableContentLike"] as? Bool,
                                       let enableContent = json.data?["enableContent"] as? Bool {
                                        self.pushInfo = [enableContentLike, enableContent]
                                    }
                                    
                                    observer.onNext(())
                                    
                                    
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
     해당 댓글 알림 수신 On
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func commentPushOn() -> Observable<Void> {
        
        return Observable.create { observer in
            
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
                                print(json)
                                if json.message == "성공" {
                                    
                                    observer.onNext(())
                                    
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
     해당 댓글 알림 수신 Off
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func commentPushOff() -> Observable<Void> {
        
        return Observable.create { observer in
            
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
                                print(json)
                                if json.message == "성공" {
                                    
                                    observer.onNext(())
                                    
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
     해당 댓글 좋아요 수신 Off
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func commentLikePushOff() -> Observable<Void> {
        
        return Observable.create { observer in
            
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
                                print(json)
                                if json.message == "성공" {
                                    
                                    observer.onNext(())
                                    
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
     해당 댓글 좋아요 수신 On
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func commentLikePushOn() -> Observable<Void> {
        
        return Observable.create { observer in
            
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
                                print(json)
                                if json.message == "성공" {
                                    
                                    observer.onNext(())
                                    
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
