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
        let scrapValue = PublishRelay<[ScrapCount]>()
        let errorValue = PublishRelay<String>()
    }
    
    init() {
        input.scrapObserver
            .flatMap(createMarker)
            .subscribe({ event in
                switch event {
                case .next(let counts):
                    self.output.scrapValue.accept(counts)
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
     유저가 스크랩한 장소를 조회
     - Parameters: None
     - Throws: MellyError
     - Returns:[Marker]
     */
    func createMarker() -> Observable<[ScrapCount]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                
                AF.request("https://api.melly.kr/api/user/place/scrap/count", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "스크랩 타입 별 스크랩 개수 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["scrapCount"] as Any) {
                                        
                                        if let scrap = try? decoder.decode([ScrapCount].self, from: data) {
                                    
                                            observer.onNext(scrap)
                                        } else {
                                            let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                            observer.onError(error)
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
                
            }
            
            return Disposables.create()
        }
    }
    
    
}
