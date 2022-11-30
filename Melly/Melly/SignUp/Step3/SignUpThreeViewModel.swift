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
        let signUpObserver = PublishSubject<Void>()
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
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.userValue.accept(error.msg)
                    
                } else {
                    if let user = result.success as? User {
                        User.loginedUser = user
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey: "loginUser")
                        UserDefaults.standard.setValue(user.jwtToken, forKey: "token")
                        UserDefaults.standard.setValue("yes", forKey: "initialUser")
                        self.output.userValue.accept(nil)
                    }
                }
            }).disposed(by: disposeBag)
        
    }
    
    
    /**
    회원가입 함수
     - Parameters: None
     - Throws: MellyError
     - Returns:User
     */
    func signUp() -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            
            let header:HTTPHeaders = [
                "Content-Type": "multipart/form-data"
            ]
            
            let str = self.user.provider == LoginType.Default.rawValue ? "/auth/signup" : "/auth/social/signup"
            let realUrl = URL(string: "https://api.melly.kr\(str)")
            let url:Alamofire.URLConvertible = realUrl!
            var parameters:[String:Any] = [
                "nickname": self.user.nickname,
                "gender": self.user.gender,
                "ageGroup": self.user.ageGroup,
                "fcmToken" : UserDefaults.standard.string(forKey: "fcmToken") ?? ""
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
                        if json.message == "회원가입 완료" || json.message == "로그인 완료" {
                            
                            if let dic = json.data?["user"] as? [String:Any] {
                                if var user = dictionaryToObject(objectType: User.self, dictionary: dic),
                                   let token = json.data?["token"] as? String{
                                    user.jwtToken = token
                                    result.success = user
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
            return Disposables.create()
        }
        
    }
}
