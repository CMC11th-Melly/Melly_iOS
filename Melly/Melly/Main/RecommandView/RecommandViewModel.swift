//
//  RecommandViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/01.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class RecommandViewModel {
    
    private let disposeBag = DisposeBag()
    let input = Input()
    let output = Output()
    
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init() {
        
        Observable.combineLatest(getHotPlace(), getTrendsPlace())
            .subscribe({ event in
                switch event {
                case .next((let hot, let trends)):
                    print(hot)
                    print(trends)
                case .error(let error):
                    print(error)
                case .completed:
                    break
                }
            }).disposed(by: disposeBag)
        
        
    }
    
    func getTrendsPlace() -> Observable<[ItLocation]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/trend", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                if json.message == "핫한 장소" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["trend"] as Any) {
                                        
                                        if let locations = try? decoder.decode([ItLocation].self, from: data) {
                                    
                                            observer.onNext(locations)
                                        } else {
                                            observer.onNext([])
                                        }
                                        
                                    } else {
                                        observer.onNext([])
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
                //로그아웃 메서드
            }
            
            
            return Disposables.create()
        }
        
        
    }
    
    func getHotPlace() -> Observable<[ItLocation]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/recommend", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                if json.message == "핫한 장소" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["trend"] as Any) {
                                        
                                        if let locations = try? decoder.decode([ItLocation].self, from: data) {
                                    
                                            observer.onNext(locations)
                                        } else {
                                            observer.onNext([])
                                        }
                                        
                                    } else {
                                        observer.onNext([])
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
                //로그아웃 메서드
            }
            
            
            return Disposables.create()
        }
        
        
    }
    
    
}
