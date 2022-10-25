//
//  MyPageViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/25.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class MyPageViewModel {
    
    static let instance = MyPageViewModel()
    private let disposeBag = DisposeBag()
    var profileData:Data? = nil
    var user = User.loginedUser!
    let genderData = Observable<[String]>.of(["남성", "여성"])
    let ageData = Observable<[String]>.of(["10대", "20대", "30대", "40대", "50대", "60대", "70대 이상"])
    
    
    let input = Input()
    let output = Output()
    
    
    
    struct Input {
        let profileImgObserver = PublishRelay<UIImage?>()
        let genderObserver = PublishRelay<String>()
        let ageObserver = PublishRelay<String>()
        let editObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let imageValue = PublishRelay<UIImage?>()
        let errorValue = PublishRelay<String>()
        let successValue = PublishRelay<Void>()
    }
    
    init() {
        input.ageObserver.subscribe(onNext: { value in
            if value == "남성" {
                self.user.gender = "MALE"
            } else {
                self.user.gender = "FEMALE"
            }
        }).disposed(by: disposeBag)
        
        input.profileImgObserver.subscribe(onNext: { value in
            self.profileData = value?.jpegData(compressionQuality: 1)
            self.output.imageValue.accept(value)
        }).disposed(by: disposeBag)
        
        input.ageObserver.subscribe(onNext: { value in
            switch value {
            case "10대":
                self.user.ageGroup = "ONE"
            case "20대":
                self.user.ageGroup = "TWO"
            case "30대":
                self.user.ageGroup = "THREE"
            case "40대":
                self.user.ageGroup = "FOUR"
            case "50대":
                self.user.ageGroup = "FIVE"
            case "60대":
                self.user.ageGroup = "SIX"
            default:
                self.user.ageGroup = "SEVEN"
            }
        }).disposed(by: disposeBag)
        
        input.editObserver
            .flatMap(signUp)
            .subscribe({ event in
                switch event {
                case .next(_):
                    self.output.successValue.accept(())
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
    회원정보 수정 함수
     - Parameters: None
     - Throws: MellyError
     - Returns:User
     */
    func signUp() -> Observable<Void> {
        
        return Observable.create { observer in
            
            
            if let user = User.loginedUser {
                
                if user == self.user {
                    
                } else {
                    
                    let header:HTTPHeaders = [
                        "Content-Type": "multipart/form-data",
                        "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                    
                    let realUrl = URL(string: "https://api.melly.kr/api/user/profile")
                    let url:Alamofire.URLConvertible = realUrl!
                    let parameters:[String:Any] = [
                        "nickname": self.user.nickname,
                        "gender": self.user.gender,
                        "ageGroup": self.user.ageGroup
                    ]
                    
                    AF.upload(multipartFormData: { multipartFormData in
                        
                        if let profileData = self.profileData {
                            multipartFormData.append(profileData, withName: "profileImage", fileName: "test.jpeg", mimeType: "image/jpeg")
                        }
                        
                        for (key, value) in parameters {
                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                        }
                        
                    }, to: url, method: .put, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let response):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: response) {
                                if json.message == "프로필 수정 완료" {
                                    User.loginedUser?.profileImage = self.user.profileImage
                                    User.loginedUser?.ageGroup = self.user.ageGroup
                                    User.loginedUser?.gender = self.user.gender
                                    User.loginedUser?.nickname = self.user.nickname
                                    observer.onNext(())
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
                
                
            }
            
            return Disposables.create()
        }
        
    }
    
    
}
