//
//  GroupEditViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/28.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

class GroupMemoryViewModel {
    
    private let disposeBag = DisposeBag()
    var ourMemory = OurMemory()
    let input = Input()
    let output = Output()
    
    let url:String
    var group:Group
    
    struct OurMemory {
        var page:Int = 0
        var isEnd:Bool = false
        var sort:String = "visitedDate,desc"
        var userId:Int = -1
    }
    
    struct Input {
        let ourMemoryRefresh = PublishRelay<Void>()
        let ourMemorySelect = PublishRelay<Memory>()
        let sortObserver = PublishRelay<String>()
        let userFilterObserver = PublishRelay<UserInfo?>()
    }
    
    struct Output {
        let ourMemoryValue = PublishRelay<[Memory]>()
        let errorValue = PublishRelay<String>()
        let sortValue = PublishRelay<String>()
        let userFilterValue = PublishRelay<UserInfo?>()
    }
   
    
    init(group:Group) {
        self.group = group
        self.url = "https://api.melly.kr/api/user/group/\(group.groupId)/memory"
        
        input.ourMemoryRefresh
            .flatMap(getOurPlace)
            .subscribe(onNext: { value in
                
                if let error = value.error {
                    self.output.errorValue.accept(error.msg)
                } else if let memories = value.success as? [Memory] {
                    self.output.ourMemoryValue.accept(memories)
                }
                
            }).disposed(by: disposeBag)
        
        input.sortObserver
            .subscribe(onNext: { value in
                
                self.ourMemory.sort = value
                self.ourMemory.page = 0
                self.ourMemory.isEnd = false
                self.output.sortValue.accept(value)
                
            }).disposed(by: disposeBag)
        
        input.userFilterObserver
            .subscribe(onNext: { value in
                
                if let value = value {
                    self.ourMemory.userId = value.userID
                } else {
                    self.ourMemory.userId = -1
                }
                
                self.ourMemory.page = 0
                self.ourMemory.isEnd = false
                self.output.userFilterValue.accept(value)
                
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
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let parameters:Parameters = ["size": 10,
                                             "page": self.ourMemory.page,
                                             "sort": self.ourMemory.sort,
                                             "userId": self.ourMemory.userId]
                
                
                AF.request(self.url, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "유저가 속해있는 그룹의 메모리 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data as Any) {
                                        
                                        if let memories = try? decoder.decode(MemoryList.self, from: data) {
                                            if !memories.content.isEmpty {
                                                self.ourMemory.page += 1
                                                self.ourMemory.isEnd = memories.last
                                                result.success = memories.content
                                                observer.onNext(result)
                                            } else {
                                                let contents:[Memory] = []
                                                result.success = contents
                                                observer.onNext(result)
                                            }
                                        } else {
                                            let contents:[Memory] = []
                                            result.success = contents
                                            observer.onNext(result)
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
