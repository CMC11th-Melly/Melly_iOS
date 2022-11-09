//
//  SideBarViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/21.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class ContainerViewModel {
    
    static let instance = ContainerViewModel()
    private let disposeBag = DisposeBag()
    
    let output = Output()
    let input = Input()
    
    struct Input {
        let logoutObserver = PublishRelay<Void>()
        let volumeObserver = PublishRelay<Void>()
        let getUserObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let volumeValue = PublishRelay<String>()
        let logoutValue = PublishRelay<Void>()
        let errorValue = PublishRelay<String>()
        let withDrawValue = PublishRelay<Void>()
        let userValue = PublishRelay<Void>()
    }
    
    init() {
        
        input.getUserObserver
            .flatMap(getUserData)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.userValue.accept(())
                }
            }).disposed(by: disposeBag)
        
        input.volumeObserver
            .flatMap(getUserVolume)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let volume = result.success as? Int{
                    let value = String.formatSize(fileSize: volume)
                    self.output.volumeValue.accept(value)
                }
                
            }).disposed(by: disposeBag)
        
        input.logoutObserver
            .flatMap(logout)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.logoutValue.accept(())
                }
            }).disposed(by: disposeBag)
        
    }
    
    /**
     유저의 데이터 용량을 가져오는 함수
     - Parameters:None
     - Throws: MellyError
     - Returns:Int(현재 사용량 바이트 단위)
     */
    func getUserVolume() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                
                AF.request("https://api.melly.kr/api/user/volume", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                            
                                if json.message == "유저가 저장한 사진 총 용량" {
                                    
                                    if let volume = json.data?["volume"] as? Int {
                                        result.success = volume
                                        observer.onNext(result)
                                    }
                                   
                                } else {
                                    let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                    result.error = error
                                    observer.onNext(result)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                result.error = error
                                observer.onNext(result)
                            }
                            
                            
                        case .failure(let error):
                            let mellyError = MellyError(code: 2, msg: error.localizedDescription)
                            result.error = mellyError
                            observer.onNext(result)
                        }
                    }
                
            } else {
                
            }
            
            return Disposables.create()
        }
        
    }
    
    /**
     로그아웃 함수
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func logout() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                
                AF.request("https://api.melly.kr/auth/logout", method: .delete, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "로그아웃 완료" {
                                    
                                    UserDefaults.standard.set(nil, forKey: "loginUser")
                                    UserDefaults.standard.set(nil, forKey: "token")
                                    User.loginedUser = nil
                                    observer.onNext(result)
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                    observer.onNext(result)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                result.error = error
                                observer.onNext(result)
                            }
                            
                            
                        case .failure(let error):
                            let mellyError = MellyError(code: 2, msg: error.localizedDescription)
                            result.error = mellyError
                            observer.onNext(result)
                        }
                    }
                
            } else {
                
            }
            
            return Disposables.create()
        }
        
    }
    
    func getUserData() -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/user/profile", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "유저 프로필 수정을 위한 폼 정보 조회" {
                                    
                                    if let data = json.data?["userInfo"] as? [String:String] {
                                        
                                        User.loginedUser!.gender = data["gender"]!
                                        User.loginedUser!.ageGroup = data["ageGroup"]!
                                        User.loginedUser!.nickname = data["nickname"]!
                                        User.loginedUser!.profileImage = data["profileImage"]!
                                        UserDefaults.standard.set(try? PropertyListEncoder().encode(User.loginedUser!), forKey: "loginUser")
                                        observer.onNext(result)
                                    }
                                    
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
