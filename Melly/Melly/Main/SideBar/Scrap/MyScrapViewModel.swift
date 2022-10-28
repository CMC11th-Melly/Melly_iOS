//
//  MyScrapViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/29.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift

class MyScrapViewModel {
    
    private let disposeBag = DisposeBag()
    
    let input = Input()
    let output = Output()
    
    
    
    struct Input {
        let scrapObserver = PublishRelay<Void>()
    }
    
    struct Output {
        
    }
    
    init() {
        input.scrapObserver
            .flatMap(createMarker)
            .subscribe({ event in
                
            }).disposed(by: disposeBag)
    }
    
    
    /**
     유저가 스크랩한 장소를 조회
     - Parameters: None
     - Throws: MellyError
     - Returns:[Marker]
     */
    func createMarker() -> Observable<[Marker]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                
                AF.request("https://api.melly.kr/api/user/place/scrap", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                print(json)
                                if json.message == "유저가 메모리 작성한 장소 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["place"] as Any) {
                                        
                                        
                                        
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
                
            }
            
            return Disposables.create()
        }
    }
    
    
}
