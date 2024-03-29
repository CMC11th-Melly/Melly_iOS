//
//  ScrapViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/11.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class PopUpViewModel {
    
    private let disposeBag = DisposeBag()
    static let instance = PopUpViewModel()
    
    var scrap:String? = nil
    
    let input = Input()
    let output = Output()
    
    struct Input {
        let filterObserver = PublishRelay<String?>()
        let bookmarkPopUpObserver = PublishRelay<Place>()
        let hideBookmarkPopUpObserver = PublishRelay<Void>()
        let addBookmarkObserver = PublishRelay<Place>()
    }
    
    struct Output {
        let bookmarkObserver = BehaviorRelay<[GroupFilter]>(value: [.friend, .family, .couple, .company])
        let removeBookmark = PublishRelay<Void>()
        let goToBookmarkView = PublishRelay<Place>()
        let hideBookmarkPopUpView = PublishRelay<Void>()
        let bmButtonEnable = PublishRelay<Bool>()
        let errorValue = PublishRelay<String>()
        let completeBookmark = PublishRelay<Void>()
    }
    
    init() {
        
        input.bookmarkPopUpObserver
            .flatMap(removeBookmark)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let place = result.success as? Place {
                    self.output.goToBookmarkView.accept(place)
                } else {
                    self.output.removeBookmark.accept(())
                }
                
            }).disposed(by: disposeBag)
        
        input.filterObserver.subscribe(onNext: {value in
            self.scrap = value
            if let _ = value {
                self.output.bmButtonEnable.accept(true)
            } else {
                self.output.bmButtonEnable.accept(false)
            }
            
        }).disposed(by: disposeBag)
        
        input.addBookmarkObserver
            .flatMap(addBookMark)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.completeBookmark.accept(())
                }
                
            }).disposed(by: disposeBag)
        
    }
    
    /**
     해당 Place 북마크 제거
     - Parameters:
        -place : Place
     - Throws: MellyError
     - Returns:None
     */
    func removeBookmark(_ place: Place) -> Observable<Result> {
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                
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
                    
                } else {
                    result.success = place
                    observer.onNext(result)
                }
            }
            
            return Disposables.create()
        }
    }
    
    /**
     해당 장소를 북마크하는 함수
     - Parameters:
        -place : Place
     - Throws: MellyError
     - Returns:None
     */
    func addBookMark(_ place:Place) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                
                let parameters:Parameters = [
                    "lat": place.position.lat,
                    "lng": place.position.lng,
                    "scrapType": self.scrap!,
                    "placeName": place.placeName,
                    "placeCategory": place.placeCategory
                ]
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/place/scrap", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                               
                                if json.message == "스크랩 완료" {
                                    
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
