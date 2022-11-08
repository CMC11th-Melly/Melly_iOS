//
//  MyMemoryViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/23.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire



class MyMemoryViewModel {
    
    private let disposeBag = DisposeBag()
    var memories:[Memory] = []
    var ourMemory = OurMemory()
    let input = Input()
    let output = Output()
    
    let url = "https://api.melly.kr/api/user/memory"
    
    struct OurMemory {
        var page:Int = 0
        var isEnd:Bool = false
        var sort:String = "visitedDate,desc"
        var groupType:GroupFilter = .all
    }
    
    
    struct Input {
        let ourMemoryRefresh = PublishRelay<Void>()
        let sortObserver = PublishRelay<String>()
        let groupFilterObserver = PublishRelay<GroupFilter>()
    }
    
    struct Output {
        let ourMemoryValue = PublishRelay<Void>()
        let errorValue = PublishRelay<String>()
        let sortValue = PublishRelay<String>()
        let groupFilterValue = PublishRelay<GroupFilter>()
    }
    
    init() {
        
        input.ourMemoryRefresh
            .flatMap(getOurPlace)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let memories = result.success as? [Memory] {
                    self.memories += memories
                    self.output.ourMemoryValue.accept(())
                }
                
            }).disposed(by: disposeBag)
        
        input.sortObserver
            .subscribe(onNext: { value in
                self.memories = []
                self.ourMemory.sort = value
                self.ourMemory.page = 0
                self.ourMemory.isEnd = false
                self.output.sortValue.accept(value)
                
            }).disposed(by: disposeBag)
        
        input.groupFilterObserver
            .subscribe(onNext: { value in
                self.memories = []
                self.ourMemory.groupType = value
                self.ourMemory.page = 0
                self.ourMemory.isEnd = false
                self.output.groupFilterValue.accept(value)
                
            }).disposed(by: disposeBag)
        
    }
    
    
    /**
     해당 장소에 있는 내 메모리를 보여주는 api 실행
     - Parameters:None
     - Throws: MellyError
     - Returns:[Memory]
     */
    func getOurPlace() -> Observable<Result> {
        
        var result = Result()
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let parameters:Parameters = ["size": 10,
                                             "page": self.ourMemory.page,
                                             "sort": self.ourMemory.sort,
                                             "groupType": self.ourMemory.groupType.rawValue]
                
                AF.request(self.url, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                               
                                if json.message == "유저가 작성한 메모리 조회"{
                                    print(json)
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["memoryInfo"] as Any) {
                                        
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
                                            
                                        } else {
                                            let memories:[Memory] = []
                                            result.success = memories
                                            observer.onNext(result)
                                        }
                                        
                                    }
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    result.error = error
                                    observer.onNext(result)
                                }
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
    
}
