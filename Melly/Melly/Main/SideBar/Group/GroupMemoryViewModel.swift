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
    func getOurPlace() -> Observable<[Memory]> {
        
        return Observable.create { observer in
            
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
                                    print(json)
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data as Any) {
                                        
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
    
    
    
    
    
    
}
