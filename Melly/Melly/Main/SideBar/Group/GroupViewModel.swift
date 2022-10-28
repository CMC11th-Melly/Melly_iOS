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
    
    struct Input {
        let getGroupObserver = PublishRelay<Void>()
        let selectedGroup = PublishRelay<Group>()
        let getGroupDetailObserver = PublishRelay<Group>()
    }
    
    struct Output {
        let groupValue = PublishRelay<[Group]>()
        let errorValue = PublishRelay<String>()
        let groupMemberValue = PublishRelay<[UserInfo]>()
        let groupDetailValue = PublishRelay<Group>()
        let goToDetailView = PublishRelay<Void>()
    }
    
    init() {
        input.getGroupObserver
            .flatMap(getMyGroup)
            .subscribe({ event in
                switch event {
                case .next(let group):
                    self.output.groupValue.accept(group)
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
        
        input.getGroupDetailObserver.subscribe(onNext: { value in
            self.output.groupMemberValue.accept(value.users)
            self.output.groupDetailValue.accept(value)
        }).disposed(by: disposeBag)
        
        input.selectedGroup.subscribe(onNext: { value in
            self.group = value
            self.output.goToDetailView.accept(())
        }).disposed(by: disposeBag)
        
    }
    
    /**
     해당 유저의 그룹을 조회
     - Parameters:None
     - Throws: MellyError
     - Returns:CommentData
     */
    func getMyGroup() -> Observable<[Group]> {
        
        return Observable.create { observer in
            
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
                                print(json)
                                if json.message == "My 그룹 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["groupInfo"] as Any) {
                                        
                                        if let groups = try? decoder.decode([Group].self, from: data) {
                                    
                                            observer.onNext(groups)
                                        }
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
