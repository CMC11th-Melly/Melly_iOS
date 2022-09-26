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
    
    struct Input {
        let genderObserver = PublishRelay<String>()
        let ageObserver = PublishRelay<String>()
        let profileImgObserver = PublishRelay<UIImage?>()
        let signUpObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let imageValue = PublishRelay<UIImage?>()
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
            self.profileData = value?.pngData()
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
            .subscribe(onNext: { value in
                
            }).disposed(by: disposeBag)
        
    }
    
    func signUp() -> Observable<String> {
        
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
            }
            
            AF.upload(multipartFormData: { multipartFormData in
                
                if let profileData = self.profileData {
                    multipartFormData.append(profileData, withName: "image", fileName: "test.png", mimeType: "image/png")
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
                            print(json)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }
        
    }
}
