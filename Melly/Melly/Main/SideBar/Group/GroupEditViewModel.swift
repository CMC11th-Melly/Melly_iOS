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

class GroupEditViewModel {
    
    var group:Group?
    
    let url:String
    var groupName:String = ""
    var groupType:String = ""
    var groupIcon:Int = 0
    let method:HTTPMethod
    
    let input = Input()
    let output = Output()
    
    struct Input {
        let groupInitialObserver = PublishRelay<Void>()
        let groupNameObserver = PublishRelay<String>()
        let groupCategoryObserver = PublishRelay<String>()
        let groupIconObserver = PublishRelay<Int>()
        let addGroupObserver = PublishRelay<Void>()
        let removeObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let editMode = PublishRelay<Group>()
    }
    
    
    let groupCategoryData = Observable<[String]>.just(["가족", "동료", "연인", "친구"])
    let groupIconData = Observable<[Int]>.just([1,2,3,4,5,6,7,8,9,10])
    private let disposeBag = DisposeBag()
    
    init(group:Group? = nil) {
        self.group = group
        
        if let group = self.group {
            self.url = "https://api.melly.kr/api/group/\(group.groupId)"
            self.groupName = group.groupName
            self.groupType = group.groupType
            self.groupIcon = group.groupIcon
            self.method = .put
            self.output.editMode.accept(group)
        } else {
            self.url = "https://api.melly.kr/api/group"
            self.method = .post
        }
        
        input.addGroupObserver
            .flatMap(addNEditGroup)
            .subscribe({ event in
                
            }).disposed(by: disposeBag)
        
        input.groupNameObserver.subscribe(onNext: { value in
            self.groupName = value
        }).disposed(by: disposeBag)
        
        input.groupIconObserver.subscribe(onNext: { value in
            self.groupIcon = value
        }).disposed(by: disposeBag)
        
        input.groupCategoryObserver.subscribe(onNext: { value in
            self.groupType = value
        }).disposed(by: disposeBag)
        
        
    }
    
    
    
    /**
     그룹 추가 및 편집할 떄 사용하는 함수
     - Parameters : None
     - Throws: MellyError
     - Returns:None
     */
    func addNEditGroup() -> Observable<Void> {
        
        return Observable.create { observer in
            
            if self.groupName == "" {
                let error = MellyError(code: 0, msg: "그룹명을 입력해주세요.")
                observer.onError(error)
            }
            
            
            
            if let user = User.loginedUser {
                
                let parameters:Parameters = ["groupName": self.groupName,
                                             "groupType": self.groupType,
                                             "groupIcon": self.groupIcon]
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request(self.url, method: self.method, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                print(json)
                                
                                if json.message == "유저가 메모리 작성한 장소 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["place"] as Any) {
                                        
                                        
                                        
                                    }
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    observer.onError(error)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                observer.onError(error)
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
     그룹 삭제하는 함수
     - Parameters : None
     - Throws: MellyError
     - Returns:None
     */
    func deleteGroup() -> Observable<Void> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request(self.url, method: .delete, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                print(json)
                                
                                if json.message == "유저가 메모리 작성한 장소 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["place"] as Any) {
                                        
                                        
                                        
                                    }
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0, msg: json.message)
                                    observer.onError(error)
                                }
                                
                            } else {
                                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                                observer.onError(error)
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
