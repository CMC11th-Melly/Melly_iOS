//
//  SignUpThreeViewModel.swift
//  Melly
//
//  Created by Jun on 2022/09/19.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

class SignUpThreeViewModel {
    var user: User
    var profileData:Data? = nil
    private var disposeBag = DisposeBag()
    let input = Input()
    let output = Output()
    
    let genderData = Observable<[String]>.of(["남성", "여성"])
    let ageData = Observable<[String]>.of(["10대", "20대", "30대", "40대", "50대", "60대", "70대 이상"])
    
    struct Input {
        let genderObserver = PublishRelay<String>()
        let ageObserver = PublishRelay<String>()
        let profileImgObserver = PublishRelay<UIImage?>()
        let signUpObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let imageValue = PublishRelay<UIImage?>()
        let userValue = PublishRelay<String?>()
    }
    
    init(_ user: User) {
        self.user = user
        
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
        
        input.signUpObserver
            .flatMap(signUp)
            .subscribe({ event in
                switch event {
                case .completed:
                    break
                case .error(let error):
                    if let mellyError = error as? MellyError {
                        if mellyError.msg == "" {
                            self.output.userValue.accept(error.localizedDescription)
                        } else {
                            self.output.userValue.accept(mellyError.msg)
                        }
                    }
                case .next(let user):
                    User.loginedUser = user
                    self.output.userValue.accept(nil)
                }
            }).disposed(by: disposeBag)
        
    }
    
    func signUp() -> Observable<User> {
        
        return Observable.create { observer in
            
            let header:HTTPHeaders = [
                        "Content-Type": "multipart/form-data"
                    ]
            
            let str = self.user.provider == LoginType.Default.rawValue ? "/auth/signup" : "/auth/social/signup"
            let realUrl = URL(string: "https://api.melly.kr\(str)")
            let url:Alamofire.URLConvertible = realUrl!
            var parameters:[String:Any] = [
                "nickname": self.user.nickname,
                "gender": self.user.gender,
                "ageGroup": self.user.ageGroup
            ]
            
            if self.user.provider == LoginType.Default.rawValue {
                parameters["email"] = self.user.email
                parameters["password"] = self.user.pw
            } else {
                parameters["uid"] = self.user.uid
            }
                        
            AF.upload(multipartFormData: { multipartFormData in
                
                if let profileData = self.profileData {
                    multipartFormData.append(profileData, withName: "profileImage", fileName: "test.jpeg", mimeType: "image/jpeg")
                }
                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
                
            }, to: url, method: .post, headers: header)
                .responseData { response in
                    switch response.result {
                    case .success(let response):
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(ResponseData.self, from: response) {
                            if json.message == "로그인 완료" {
                                if let dic = json.data?["user"] as? [String:Any] {
                                    if let user = dictionaryToObject(objectType: User.self, dictionary: dic) {
                                        observer.onNext(user)
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
            return Disposables.create()
        }
        
    }
}
