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
    var deleteImage = false
    
    let input = Input()
    let output = Output()
    
    struct Input {
        let initialObserver = PublishRelay<Void>()
        let volumeObserver = PublishRelay<Void>()
        let profileImgObserver = PublishRelay<UIImage?>()
        let genderObserver = PublishRelay<String>()
        let nicnameObserver = PublishRelay<String>()
        let ageObserver = PublishRelay<String>()
        let editObserver = PublishRelay<Void>()
        let withdrawObserver = PublishRelay<Void>()
    }
    
    struct Output {
        
        let imageValue = PublishRelay<UIImage?>()
        let errorValue = PublishRelay<String>()
        let successValue = PublishRelay<Void>()
        let volumeValue = PublishRelay<Int>()
        let reloadValue = PublishRelay<Void>()
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
        
        input.volumeObserver
            .flatMap(getUserVolume)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.successValue.accept(())
                }
            }).disposed(by: disposeBag)
        
        input.initialObserver
            .flatMap(getUserData)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.reloadValue.accept(())
                }
            }).disposed(by: disposeBag)
        
        input.withdrawObserver
            .flatMap(withDrawUser)
            .subscribe(onNext: { result in
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    ContainerViewModel.instance.output.withDrawValue.accept(())
                }
            }).disposed(by: disposeBag)
        
        input.nicnameObserver
            .subscribe(onNext: { value in
                self.user.nickname = value
            }).disposed(by: disposeBag)
        
        
    }
    
    /**
     회원정보 수정 함수
     - Parameters: None
     - Throws: MellyError
     - Returns:User
     */
    func signUp() -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            if let user = User.loginedUser {
                
                
                let header:HTTPHeaders = [
                    "Content-Type": "multipart/form-data",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let realUrl = URL(string: "https://api.melly.kr/api/user/profile")
                let url:Alamofire.URLConvertible = realUrl!
                let parameters:[String:Any] = [
                    "nickname": self.user.nickname,
                    "gender": self.user.gender,
                    "ageGroup": self.user.ageGroup,
                    "deleteImage" : self.deleteImage
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
                                observer.onNext(result)
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
     유저의 데이터 용량을 가져오는 함수
     - Parameters:None
     - Throws: MellyError
     - Returns:Int(현재 사용량 바이트 단위)
     */
    func getUserVolume() -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/user/volume", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "유저가 저장한 사진 총 용량" {
                                    
                                    if let volume = json.data?["volume"] as? Int {
                                        result.success = volume
                                        observer.onNext(result)
                                    } else {
                                        result.success = 0
                                        observer.onNext(result)
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
                
            }
            
            return Disposables.create()
        }
        
    }
    
    /**
     유저의 기본정보를 최신화하는 함수
     - Throws: MellyError
     */
    func getUserData() -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/user/profile", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                               
                                if json.message == "유저 프로필 수정을 위한 폼 정보 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["userInfo"] as Any){
                                        
                                        if let userInfo = try? decoder.decode(UserInitial.self, from: data) {
                                            User.loginedUser!.gender = userInfo.gender
                                            User.loginedUser!.ageGroup = userInfo.ageGroup ?? ""
                                            User.loginedUser!.nickname = userInfo.nickname
                                            User.loginedUser!.profileImage = userInfo.profileImage
                                            
                                            UserDefaults.standard.set(try? PropertyListEncoder().encode(User.loginedUser!), forKey: "loginUser")
                                            observer.onNext(result)
                                        } else {
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
                
            }
            
            return Disposables.create()
        }
        
    }
    
    /**
     유저 회원탈퇴
     - Throws: MellyError
     */
    func withDrawUser() -> Observable<Result> {
        
        return Observable.create { observer in
            
            var result = Result()
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/auth/withdraw", method: .delete, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "회원탈퇴 완료" {
                                    
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
    
    
    
}
