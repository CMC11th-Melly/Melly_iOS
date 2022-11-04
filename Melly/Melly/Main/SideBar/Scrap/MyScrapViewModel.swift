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
    
    static let instance = MyScrapViewModel()
    
    private let disposeBag = DisposeBag()
    
    
    
    let input = Input()
    let output = Output()
    
    var scrapCount: ScrapCount?
    
    var scrapOption = ScrapOption()
    
    struct Input {
        let scrapObserver = PublishRelay<Void>()
        let goScrapDetailObserver = PublishRelay<ScrapCount>()
        let refreshPlaceObserver = PublishRelay<Void>()
        let removeBookmarkObserver = PublishRelay<Place>()
    }
    
    struct Output {
        let scrapValue = PublishRelay<[ScrapCount]>()
        let errorValue = PublishRelay<String>()
        let goToScrapDetail = PublishRelay<Void>()
        let placeValue = PublishRelay<[Place]>()
        let removeBookmark = PublishRelay<Void>()
    }
    
    struct ScrapOption {
        var page:Int = 0
        let size:Int = 10
        var scrapType:String = "ALL"
        var isEnd:Bool = false
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
        
        input.goScrapDetailObserver.subscribe(onNext: { value in
            self.scrapOption.scrapType = value.scrapType
            self.output.goToScrapDetail.accept(())
        }).disposed(by: disposeBag)
        
        input.refreshPlaceObserver
            .flatMap(getGroupDetailPlace)
            .subscribe(onNext: { value in
                self.output.placeValue.accept(value)
            }).disposed(by: disposeBag)
        
        input.removeBookmarkObserver
            .flatMap(removeBookmark)
            .subscribe({ event in
                switch event {
                case .next(_):
                    self.output.removeBookmark.accept(())
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
    
    /**
     그룹 별로 스크랩한 장소를 조회
     - Parameters:None
     - Throws: MellyError
     - Returns:[Place]
     */
    func getGroupDetailPlace() -> Observable<[Place]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let parameters:Parameters = ["size": 10,
                                             "page": self.scrapOption.page,
                                             "scrapType": self.scrapOption.scrapType]
                
                AF.request("https://api.melly.kr/api/user/place/scrap", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                print(json)
                                if json.message == "스크랩 타입 별 스크랩 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["scrapPlace"] as Any) {
                                        
                                        if let result = try? decoder.decode(PlaceList.self, from: data) {
                                            if !result.content.isEmpty {
                                                self.scrapOption.page += 1
                                                
                                                self.scrapOption.isEnd = result.last
                                                observer.onNext(result.content)
                                            } else {
                                                observer.onNext([])
                                            }
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
                            }
                        case .failure(let error):
                            observer.onError(error)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    func removeBookmark(_ place: Place) -> Observable<Void> {
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                
                
                let parameters:Parameters = [
                    "lat": place.position.lat,
                    "lng": place.position.lng
                ]
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/place/scrap", method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                if json.message == "스크랩 삭제 완료" {
                                    
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
                
            }
            
            return Disposables.create()
        }
    }
    
    
}
