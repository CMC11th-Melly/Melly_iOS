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
        let isNoData = PublishRelay<Bool>()
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
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let scraps = result.success as? [ScrapCount] {
                    self.output.scrapValue.accept(scraps)
                    self.output.isNoData.accept(scraps.isEmpty)
                }
                
            }).disposed(by: disposeBag)
        
        input.goScrapDetailObserver.subscribe(onNext: { value in
            self.scrapOption.scrapType = value.scrapType
            self.output.goToScrapDetail.accept(())
        }).disposed(by: disposeBag)
        
        input.refreshPlaceObserver
            .flatMap(getGroupDetailPlace)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let place = result.success as? [Place] {
                    self.output.placeValue.accept(place)
                }
                
            }).disposed(by: disposeBag)
        
        input.removeBookmarkObserver
            .flatMap(removeBookmark)
            .subscribe(onNext: { result in
                self.scrapOption.page = 0
                self.scrapOption.isEnd = false
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.removeBookmark.accept(())
                }
        
            }).disposed(by: disposeBag)
        
    }
    
    
    
    /**
     유저가 스크랩한 장소를 조회
     - Parameters: None
     - Throws: MellyError
     - Returns:[Marker]
     */
    func createMarker() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
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
                                            result.success = scrap
                                            observer.onNext(result)
                                        } else {
                                            let data:[ScrapCount] = []
                                            result.success = data
                                            observer.onNext(result)
                                        }
                                        
                                    } else {
                                        let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                        result.error = error
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
                        case .failure(_):
                            let error = MellyError(code: 2, msg: "네트워크 상태를 확인해주세요.")
                            result.error = error
                            observer.onNext(result)
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
    func getGroupDetailPlace() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
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
                               
                                if json.message == "스크랩 타입 별 스크랩 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["scrapPlace"] as Any) {
                                        
                                        if let placeList = try? decoder.decode(PlaceList.self, from: data) {
                                            if !placeList.content.isEmpty {
                                                self.scrapOption.page += 1
                                                
                                                self.scrapOption.isEnd = placeList.last
                                                result.success = placeList.content
                                                observer.onNext(result)
                                            } else {
                                                let data:[Place] = []
                                                result.success = data
                                                observer.onNext(result)
                                            }
                                        } else {
                                            let data:[Place] = []
                                            result.success = data
                                            observer.onNext(result)
                                        }
                                        
                                    } else {
                                        let data:[Place] = []
                                        result.success = data
                                        observer.onNext(result)
                                    }
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                            }
                        case .failure(_):
                            let error = MellyError(code: 2, msg: "네트워크 상태를 확인해주세요.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
            }
            
            return Disposables.create()
        }
        
    }
    
    
    /**
     북마크 제거함수
     - Parameters:
        - place: Place
     - Throws: MellyError
     - Returns:None
     */
    func removeBookmark(_ place: Place) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
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
                                    
                                    observer.onNext(result)
                                    
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
                        case .failure(_):
                            let error = MellyError(code: 2, msg: "네트워크 상태를 확인해주세요.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
                
            }
            
            return Disposables.create()
        }
    }
    
    
}
