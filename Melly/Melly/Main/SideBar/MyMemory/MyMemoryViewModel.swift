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
    
    var ourMemory = OurMemory()
    let input = Input()
    let output = Output()
    
    struct OurMemory {
        var lastId:Int = -1
        var isEnd:Bool = false
        var visitedDate:String = ""
        var keyword:String = ""
        var groupType:GroupFilter = .all
    }
    
    
    struct Input {
        let ourMemoryRefresh = PublishRelay<Void>()
        let ourMemorySelect = PublishRelay<Memory>()
    }
    
    struct Output {
        let ourMemoryValue = PublishRelay<[Memory]>()
        let errorValue = PublishRelay<String>()
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
                                             "lastId": self.ourMemory.lastId,
                                             "keyword": self.ourMemory.keyword,
                                             "visitedDate": self.ourMemory.visitedDate,
                                             "groupType": self.ourMemory.groupType.rawValue]
                AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "내가 작성한 메모리 전체 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data! as Any) {
                                        
                                        if let result = try? decoder.decode(MemoryData.self, from: data) {
                                            if !result.memoryList.content.isEmpty {
                                                self.ourMemory.lastId = result.memoryList.content[result.memoryList.content.count - 1].memoryId
                                                self.ourMemory.isEnd = result.memoryList.last
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
