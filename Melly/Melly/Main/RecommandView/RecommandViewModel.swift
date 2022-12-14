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
    
    static let instance = RecommandViewModel()
    
    var hotDatas:[ItLocation] = []
    var recommendData:[ItLocation] = []
    
    private let disposeBag = DisposeBag()
    let input = Input()
    let output = Output()
    
    struct Input {
        let placeObserver = PublishRelay<PlaceInfo>()
        let viewAppearObserver = PublishRelay<Void>()
        let bookmarkAddObserver = PublishRelay<PlaceInfo>()
        let bookmarkRemoveObserver = PublishRelay<PlaceInfo>()
    }
    
    struct Output {
        let successValue = PublishRelay<Void>()
        let goToPlace = PublishRelay<Place>()
        let errorValue = PublishRelay<String>()
        let goToMemory = PublishRelay<Memory>()
    }
    
    init() {
        
        input.viewAppearObserver
            .subscribe(onNext: {
                Observable.combineLatest(self.getHotPlace(), self.getTrendsPlace())
                    .subscribe(onNext: { hotResult, trendResult in
                        if let error = hotResult.error {
                            self.output.errorValue.accept(error.msg)
                        } else if let error = trendResult.error {
                            self.output.errorValue.accept(error.msg)
                        } else {
                            if let hot = hotResult.success as? [ItLocation] {
                                self.hotDatas = hot
                            }
                            if let trends = trendResult.success as? [ItLocation] {
                                self.recommendData = trends
                            }
                            self.output.successValue.accept(())
                        }
                        
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
        input.bookmarkAddObserver
            .flatMap(getPlace)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let place = result.success as? Place {
                    
                    PopUpViewModel.instance.output.goToBookmarkView.accept(place)
                }
                
            }).disposed(by: disposeBag)
        
        input.bookmarkRemoveObserver
            .flatMap(getPlace)
            .flatMap(removeBookmark)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                }
            }).disposed(by: disposeBag)
        
        input.placeObserver
            .flatMap(getPlace)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let place = result.success as? Place {
                    self.output.goToPlace.accept(place)
                }
                    
            }).disposed(by: disposeBag)
        
    }
    
    /**
     ?????? ?????? ????????? ?????? ????????? ???????????? ????????????
     - Parameters:None
     - Throws: MellyError
     - Returns:[ItLocation]
     */
    func getTrendsPlace() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
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
                                
                                if json.message == "?????? ??????" {
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["trend"] as Any) {
                                        
                                        if let locations = try? decoder.decode([ItLocation].self, from: data) {
                                    
                                            result.success = locations
                                            observer.onNext(result)
                                        } else {
                                            let locations:[ItLocation] = []
                                            result.success = locations
                                            observer.onNext(result)
                                        }
                                        
                                    } else {
                                        let locations:[ItLocation] = []
                                        result.success = locations
                                        observer.onNext(result)
                                    }
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "??????????????? ?????? ??????????????????.")
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
                //???????????? ?????????
            }
            
            
            return Disposables.create()
        }
        
        
    }
    
    /**
     ??????????????? ???????????? ????????? ?????? ????????? ???????????? ????????????
     - Parameters:None
     - Throws: MellyError
     - Returns:[ItLocation]
     */
    func getHotPlace() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
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
                                
                                if json.message == "?????? ??????" {
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["recommend"] as Any) {
                                        
                                        if let locations = try? decoder.decode([ItLocation].self, from: data) {
                                    
                                            result.success = locations
                                            observer.onNext(result)
                                        } else {
                                            let locations:[ItLocation] = []
                                            result.success = locations
                                            observer.onNext(result)
                                        }
                                        
                                    } else {
                                        let locations:[ItLocation] = []
                                        result.success = locations
                                        observer.onNext(result)
                                    }
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "??????????????? ?????? ??????????????????.")
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
                //???????????? ?????????
            }
            
            return Disposables.create()
        }
        
    }
    
    /**
     ???????????? ????????? ?????? ????????? ???????????? ?????? ?????? Model??? ????????????
     - Parameters:
        -placeInfo: PlaceInfo
     - Throws: MellyError
     - Returns: Place
     */
    func getPlace(_ placeInfo: PlaceInfo) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                
                AF.request("https://api.melly.kr/api/place/\(placeInfo.placeId)/search", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "????????? ???????????? ?????? ??????" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["placeInfo"] as Any) {
                                        
                                        if let place = try? decoder.decode(Place.self, from: data) {
                                            result.success = place
                                            observer.onNext(result)
                                        }
                                        
                                    }
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "??????????????? ?????? ??????????????????.")
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
    
    /**
     ????????? ?????? ??????
     - Parameters:
        -place: Place
     - Throws: MellyError
     - Returns: None
     */
    func removeBookmark(_ nextValue: Result) -> Observable<Result> {
        return Observable.create { observer in
            
            var result = Result()
            
            if let user = User.loginedUser,
               let place = nextValue.success as? Place {
                
                if place.isScraped {
                    
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
                                    
                                    if json.message == "????????? ?????? ??????" {
                                        
                                        observer.onNext(result)
                                        
                                    } else {
                                        let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                        result.error = error
                                        observer.onNext(result)
                                    }
                                    
                                } else {
                                    let error = MellyError(code: 999, msg: "??????????????? ?????? ??????????????????.")
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
            }
            
            return Disposables.create()
        }
    }
    
    
}
