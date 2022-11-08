//
//  GroupViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/28.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class GroupViewModel {
    
    private let disposeBag = DisposeBag()
    
    static let instance = GroupViewModel()
    
    let input = Input()
    let output = Output()
    
    var group:Group?
    
    var groupName:String = ""
    var groupType:String = ""
    var groupIcon:Int = -1
    
    struct Input {
        let getGroupObserver = PublishRelay<Void>()
        let selectedGroup = PublishRelay<Group>()
        let getGroupDetailObserver = PublishRelay<Group>()
        
        let groupNameObserver = PublishRelay<String>()
        let groupCategoryObserver = PublishRelay<String>()
        let groupIconObserver = PublishRelay<Int>()
        let addGroupObserver = PublishRelay<Void>()
        let connectAddObserver = PublishRelay<Void>()
        let removeObserver = PublishRelay<Void>()
        
        let editGroupObserver = PublishRelay<Void>()
        let connectEditObserver = PublishRelay<Void>()
        
    }
    
    struct Output {
        let groupValue = PublishRelay<[Group]>()
        let errorValue = PublishRelay<String>()
        let groupMemberValue = PublishRelay<[UserInfo]>()
        let groupDetailValue = PublishRelay<Group>()
        let groupAddComplete = PublishRelay<Group>()
        let goToDetailView = PublishRelay<Void>()
        let removeValue = PublishRelay<Void>()
        let editValue = PublishRelay<Void>()
    }
    
    let groupCategoryData = Observable<[String]>.just(["가족", "동료", "연인", "친구"])
    let groupIconData = Observable<[Int]>.just([1,2,3,4,5,6,7,8,9,0])
    
    init() {
        
        input.getGroupObserver
            .flatMap(getMyGroup)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let group = result.success as? [Group]{
                    self.output.groupValue.accept(group)
                }
                
            }).disposed(by: disposeBag)
        
        input.getGroupDetailObserver.subscribe(onNext: { value in
            self.output.groupMemberValue.accept(value.users)
            self.output.groupDetailValue.accept(value)
        }).disposed(by: disposeBag)
        
        input.selectedGroup.subscribe(onNext: { value in
            self.group = value
            self.output.goToDetailView.accept(())
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
        
        input.addGroupObserver
            .map(getHandleError)
            .subscribe(onNext: { value in
                if value == "" {
                    self.input.connectAddObserver.accept(())
                } else {
                    self.output.errorValue.accept(value)
                }
            }).disposed(by: disposeBag)
        
        input.connectAddObserver
            .flatMap(addGroup)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let group = result.success as? Group{
                    self.output.groupAddComplete.accept(group)
                }
                
            }).disposed(by: disposeBag)
        
        input.removeObserver
            .flatMap(deleteGroup)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.group = nil
                    self.output.removeValue.accept(())
                }
            }).disposed(by: disposeBag)
            
        
        input.editGroupObserver
            .map(getHandleError)
            .subscribe(onNext: { value in
                if value == "" {
                    self.input.connectEditObserver.accept(())
                } else {
                    self.output.errorValue.accept(value)
                }
            }).disposed(by: disposeBag)
        
        input.connectEditObserver
            .flatMap(editGroup)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.editValue.accept(())
                }
                
            }).disposed(by: disposeBag)
        
    }
    
    /**
     해당 유저의 그룹을 조회
     - Parameters:None
     - Throws: MellyError
     - Returns:CommentData
     */
    func getMyGroup() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/user/group"
                
                AF.request(url, method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                if json.message == "My 그룹 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["groupInfo"] as Any) {
                                        
                                        if let groups = try? decoder.decode([Group].self, from: data) {
                                            result.success = groups
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
    
    /**
     그룹 추가 및 편집할 떄 사용하는 함수
     - Parameters : None
     - Throws: MellyError
     - Returns:None
     */
    func addGroup() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                
                let parameters:Parameters = ["groupName": self.groupName,
                                             "groupType": self.groupType,
                                             "groupIcon": self.groupIcon]
                
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
    
    /**
     그룹 추가 및 편집할 떄 사용하는 함수
     - Parameters : None
     - Throws: MellyError
     - Returns:None
     */
    func editGroup() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
             if let user = User.loginedUser ,
                      let group = self.group {
                
                let parameters:Parameters = ["groupName": self.groupName,
                                             "groupType": self.groupType,
                                             "groupIcon": self.groupIcon]
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/group/\(group.groupId)", method: .put, parameters: parameters, encoding: JSONEncoding.default , headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "그룹 수정 완료" {
                                    self.group?.groupType = self.groupType
                                    self.group?.groupName = self.groupName
                                    self.group?.groupIcon = self.groupIcon
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
                let error = MellyError(code: 999, msg: "관리자에게 문의 부탁드립니다.")
                result.error = error
                observer.onNext(result)
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
    func deleteGroup() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser,
               let group = self.group {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/group/\(group.groupId)", method: .delete, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "그룹 삭제 완료" {
                                    
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
    
    
    func getHandleError() -> String {
        
        if groupName == "" {
            return "그룹명을 입력해주세요."
        } else if self.groupType == "" {
            return "그룹 카테고리를 선택해주세요."
        } else if self.groupIcon == -1 {
            return "그룹 아이콘을 선택해주세요."
        } else {
            return ""
        }
        
    }
    
   
    
}
