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
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let memories = result.success as? [Memory] {
                    self.output.ourMemoryValue.accept(memories)
                }
                
            }).disposed(by: disposeBag)
        
        input.otherMemoryRefresh
            .flatMap(getOtherPlace)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let memories = result.success as? [Memory] {
                    self.output.otherMemoryValue.accept(memories)
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
        
        input.otherAllObserver.subscribe(onNext: { value in
            
            if value {
                self.otherUrl = "https://api.melly.kr/api/memory/other/place/\(self.place.placeId)"
            } else {
                self.otherUrl = "https://api.melly.kr/api/memory/group/place/\(self.place.placeId)"
            }
            self.output.otherAllValue.accept(value)
        }).disposed(by: disposeBag)
        
    }
    
    
    /**
     해당 장소에 있는 내 메모리를 보여주는 api 실행
     - Parameters:None
     - Throws: MellyError
     - Returns:[Memory]
     */
    func getOurPlace() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
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
                                        
                                        if let memories = try? decoder.decode(MemoryList.self, from: data) {
                                            if !memories.content.isEmpty {
                                                self.ourMemory.page += 1
                                                self.ourMemory.isEnd = memories.last
                                                
                                                result.success = memories.content
                                                
                                                observer.onNext(result)
                                            } else {
                                                let memories:[Memory] = []
                                                result.success = memories
                                                observer.onNext(result)
                                        
                                            }
                                        }
                                        
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
     해당 장소에 있는 다른사람의 메모리를 보여주는 api 실행
     - Parameters:None
     - Throws: MellyError
     - Returns:[Memory]
     */
    func getOtherPlace() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let parameters:Parameters = ["size": 10,
                                             "page": self.otherMemory.page,
                                             "sort": self.otherMemory.sort,
                                             "groupType": self.otherMemory.groupType.rawValue]
                
                AF.request(self.otherUrl, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                if json.message == "성공" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["memoryList"] as Any) {
                                        
                                        if let memories = try? decoder.decode(MemoryList.self, from: data) {
                                            if !memories.content.isEmpty {
                                                self.otherMemory.page += 1
                                                self.otherMemory.isEnd = memories.last
                                                
                                                result.success = memories.content
                                                
                                                observer.onNext(result)
                                            } else {
                                                let memories:[Memory] = []
                                                result.success = memories
                                                observer.onNext(result)
                                        
                                            }
                                        }
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
    
    
}
