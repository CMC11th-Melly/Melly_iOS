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
    }
    
    struct Output {
        let volumeValue = PublishRelay<String>()
        let logoutValue = PublishRelay<Void>()
        let errorValue = PublishRelay<String>()
    }
    
    init() {
        
        input.volumeObserver
            .flatMap(getUserVolume)
            .subscribe({ event in
                
                switch event {
                case .completed:
                    break
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.errorValue.accept(error.localizedDescription)
                        } else {
                            self.output.errorValue.accept(mellyError.msg)
                        }
                    }
                case .next(let volume):
                    let value = String.formatSize(fileSize: volume)
                    self.output.volumeValue.accept(value)
                }
                
            }).disposed(by: disposeBag)
        
        input.logoutObserver
            .flatMap(logout)
            .subscribe({ event in
                switch event {
                case .completed:
                    break
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.errorValue.accept(error.localizedDescription)
                        } else {
                            self.output.errorValue.accept(mellyError.msg)
                        }
                    }
                case .next(_):
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
    func getUserVolume() -> Observable<Int> {
        
        return Observable.create { observer in
            
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
                                        observer.onNext(volume)
                                    }
                                   
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    observer.onError(error)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                observer.onError(error)
                            }
                            
                            
                        case .failure(let error):
                            observer.onError(error)
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
    func logout() -> Observable<Void> {
        
        return Observable.create { observer in
            
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
                                    observer.onNext(())
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    observer.onError(error)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                observer.onError(error)
                            }
                            
                            
                        case .failure(let error):
                            observer.onError(error)
                        }
                    }
                
            } else {
                
            }
            
            return Disposables.create()
        }
        
    }
    
}
