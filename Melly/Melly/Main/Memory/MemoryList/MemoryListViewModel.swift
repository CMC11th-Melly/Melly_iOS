//
//  MemoryListViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/13.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class MemoryListViewModel {
    
    var place:Place
    
    private let disposeBag = DisposeBag()
    
    var ourMemory = OurMemory()
    var otherMemory = OtherMemory()
    let input = Input()
    let output = Output()
    
   lazy var otherUrl = "https://api.melly.kr/api/memory/group/place/\(place.placeId)"
    
    struct OurMemory {
        var page:Int = 0
        var isEnd:Bool = false
        var sort:String = "visitedDate,desc"
        var groupType:GroupFilter = .all
    }
    
    struct OtherMemory {
        var page:Int = 0
        var isEnd:Bool = false
        var sort:String = "visitedDate,desc"
        var groupType:GroupFilter = .all
        var isAll = false
    }
    
    struct Input {
        let ourMemoryRefresh = PublishRelay<Void>()
        let memorySelect = PublishRelay<Memory>()
        let otherMemoryRefresh = PublishRelay<Void>()
        
        let ourSortObserver = PublishRelay<String>()
        let ourGroupFilterObserver = PublishRelay<GroupFilter>()
        
        let otherSortObserver = PublishRelay<String>()
        let otherGroupFilterObserver = PublishRelay<GroupFilter>()
        let otherAllObserver = PublishRelay<Bool>()
        
    }
    
    struct Output {
        let ourMemoryValue = PublishRelay<[Memory]>()
        let otherMemoryValue = PublishRelay<[Memory]>()
        let errorValue = PublishRelay<String>()
        let selectMemoryValue = PublishRelay<Memory>()
        
        //OurMemory
        let ourSortValue = PublishRelay<String>()
        let ourGroupFilterValue = PublishRelay<GroupFilter>()
        let goToOurSortVC = PublishRelay<Void>()
        let goToOurFilterVC = PublishRelay<Void>()
        
        //OurMemory
        let otherSortValue = PublishRelay<String>()
        let otherGroupFilterValue = PublishRelay<GroupFilter>()
        let otherAllValue = PublishRelay<Bool>()
        let goToOtherSortVC = PublishRelay<Void>()
        let goToOtherFilterVC = PublishRelay<Void>()
        let goToOtherAllVC = PublishRelay<Void>()
        
        
        
    }
    
    init(place: Place) {
        
        self.place = place
        
        input.ourMemoryRefresh
            .flatMap(getOurPlace)
            .subscribe({ event in
                switch event {
                case .next(let memories):
                    self.output.ourMemoryValue.accept(memories)
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
        
        input.otherMemoryRefresh
            .flatMap(getOtherPlace)
            .subscribe({ event in
                switch event {
                case .next(let memories):
                    self.output.otherMemoryValue.accept(memories)
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
        
        input.memorySelect.subscribe(onNext: { value in
            self.output.selectMemoryValue.accept(value)
        }).disposed(by: disposeBag)
        
        input.ourSortObserver
            .subscribe(onNext: { value in
                
                self.ourMemory.sort = value
                self.ourMemory.page = 0
                self.ourMemory.isEnd = false
                self.output.ourSortValue.accept(value)
                
            }).disposed(by: disposeBag)
        
        input.ourGroupFilterObserver
            .subscribe(onNext: { value in
                
                self.ourMemory.groupType = value
                self.ourMemory.page = 0
                self.ourMemory.isEnd = false
                self.output.ourGroupFilterValue.accept(value)
                
            }).disposed(by: disposeBag)
        
        input.otherSortObserver
            .subscribe(onNext: { value in
                
                self.otherMemory.sort = value
                self.otherMemory.page = 0
                self.otherMemory.isEnd = false
                self.output.otherSortValue.accept(value)
                
            }).disposed(by: disposeBag)
        
        input.otherGroupFilterObserver
            .subscribe(onNext: { value in
                
                self.otherMemory.groupType = value
                self.otherMemory.page = 0
                self.otherMemory.isEnd = false
                self.output.otherGroupFilterValue.accept(value)
                
            }).disposed(by: disposeBag)
        
    }
    
    
    /**
     해당 장소에 있는 내 메모리를 보여주는 api 실행
     - Parameters:None
     - Throws: MellyError
     - Returns:[Memory]
     */
    func getOurPlace() -> Observable<[Memory]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/memory/user/place/\(self.place.placeId)"
                
                let parameters:Parameters = ["size": 10,
                                             "page": self.ourMemory.page,
                                             "sort": self.ourMemory.sort,
                                             "groupType": self.ourMemory.groupType.rawValue]
                
                AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                print(json)
                                if json.message == "내가 작성한 메모리 전체 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["memoryList"] as Any) {
                                        
                                        if let result = try? decoder.decode(MemoryList.self, from: data) {
                                            if !result.content.isEmpty {
                                                self.ourMemory.page += 1
                                                self.ourMemory.isEnd = result.last
                                                observer.onNext(result.content)
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
    
    
    /**
     해당 장소에 있는 다른사람의 메모리를 보여주는 api 실행
     - Parameters:None
     - Throws: MellyError
     - Returns:[Memory]
     */
    func getOtherPlace() -> Observable<[Memory]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let parameters:Parameters = ["size": 10,
                                             "page": self.ourMemory.page,
                                             "sort": self.ourMemory.sort,
                                             "groupType": self.ourMemory.groupType.rawValue]
                
                AF.request(self.otherUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                print(json)
                                if json.message == "다른 유저가 전체 공개로 올린 메모리 조회" || json.message == "내 그룹의 메모리 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data! as Any) {
                                        
                                        if let result = try? decoder.decode(MemoryData.self, from: data) {
                                            if !result.memoryList.content.isEmpty {
                                                self.otherMemory.page += 1
                                                
                                                self.otherMemory.isEnd = result.memoryList.last
                                                observer.onNext(result.memoryList.content)
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
    
    
}
