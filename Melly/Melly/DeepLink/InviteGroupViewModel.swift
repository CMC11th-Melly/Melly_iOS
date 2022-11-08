//
//  InviteGroupViewModel.swift
//  Melly
//
//  Created by Jun on 2022/11/08.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class InviteGroupViewModel {
    
    private let disposeBag = DisposeBag()
    
    let userId:String
    let groupId:String
    
    let input = Input()
    let output = Output()
    
    struct Input {
        let initObserver = PublishRelay<Void>()
        let inviteObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let errorValue = PublishRelay<String>()
        let successValue = PublishRelay<Void>()
    }
    
    init(userId: String, groupId: String) {
        self.userId = userId
        self.groupId = groupId
        
        input.inviteObserver
            .flatMap(inviteGroup)
            .subscribe(onNext: { value in
                if let error = value.error {
                    self.output.errorValue.accept(error.msg)
                    
                } else {
                    self.output.successValue.accept(())
                }
            }).disposed(by: disposeBag)
        
        
    }
    
    
    
    func inviteGroup() -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            
            if let user = User.loginedUser {
                
                let parameters:Parameters = ["groupId": self.groupId]
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/group", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "그룹 추가 완료" {
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["data"] as Any) {
                                        
                                        if let group = try? decoder.decode(Group.self, from: data) {
                                            result.success = group
                                            observer.onNext(result)
                                        }
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
                
            } else {
                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                result.error = error
                observer.onNext(result)
            }
            
            
            return Disposables.create()
        }
        
        
    }
    
    
    
}
