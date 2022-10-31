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
    
    static let instance = MyMemoryViewModel()
    
    var ourMemory = OurMemory()
    let input = Input()
    let output = Output()
    
    struct OurMemory {
        var page:Int = 0
        var isEnd:Bool = false
        var sort:String = "visitedDate,desc"
        var groupType:GroupFilter = .all
    }
    
    
    struct Input {
        let ourMemoryRefresh = PublishRelay<Void>()
        let ourMemorySelect = PublishRelay<Memory>()
        let sortObserver = PublishRelay<String>()
        let groupFilterObserver = PublishRelay<GroupFilter>()
    }
    
    struct Output {
        let ourMemoryValue = PublishRelay<[Memory]>()
        let errorValue = PublishRelay<String>()
        let sortValue = PublishRelay<String>()
        let groupFilterValue = PublishRelay<GroupFilter>()
    }
    
    init() {
        
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
        
        input.groupFilterObserver
            .subscribe(onNext: { value in
                
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
    func getOurPlace() -> Observable<[Memory]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/user/memory"
                
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
                               
                                
                                if json.message == "유저가 작성한 메모리 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["memoryInfo"] as Any) {
                                        
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
