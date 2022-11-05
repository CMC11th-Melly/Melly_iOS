//
//  ResearchMainViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/04.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class ResearchMainViewModel {
    
    let disposeBag = DisposeBag()
    let input = Input()
    let output = Output()
    var searchData = ["","",""]
    var currentStep = 1
    var survey: Survey?
    
    static let instance = ResearchMainViewModel()
    
    let oneData = Observable<[String]>.of(["성수", "을지로", "홍대", "강남", "청담", "용산", "이태원", "잠실"])
    let twoData = Observable<[String]>.of(["카페방문", "맛집탐방", "전시회 / 미술관", "액티비티", "취미생활", "자연 / 산책"])
    let threeData = Observable<[String]>.of(["연인", "가족", "친구", "동료"])
    
    struct Input {
        let researchOneObserver = PublishRelay<String>()
        let researchTwoObserver = PublishRelay<String>()
        let researchThreeObserver = PublishRelay<String>()
        let backObserver = PublishRelay<Void>()
        let nextObserver = PublishRelay<Void>()
        let surveyObserver = PublishRelay<Void>()
        let goMainObserver = PublishRelay<Void>()
        let getSurveyObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let buttonValid = PublishRelay<Bool>()
        let nextBackValid = PublishRelay<Int>()
        let errorValue = PublishRelay<String>()
        let surveyValue = PublishRelay<Survey>()
        let goToMainValue = PublishRelay<Void>()
    }
    
    init() {
        
        input.researchOneObserver.subscribe(onNext: { value in
            if self.searchData[0] == value {
                self.searchData[0] = ""
                self.output.buttonValid.accept(false)
            } else {
                self.searchData[0] = value
                self.output.buttonValid.accept(true)
            }
        }).disposed(by: disposeBag)
        
        input.researchTwoObserver.subscribe(onNext: { value in
            if self.searchData[1] == value {
                self.searchData[1] = ""
                self.output.buttonValid.accept(false)
            } else {
                self.searchData[1] = value
                self.output.buttonValid.accept(true)
            }
        }).disposed(by: disposeBag)
        
        input.researchThreeObserver.subscribe(onNext: { value in
            if self.searchData[2] == value {
                self.searchData[2] = ""
                self.output.buttonValid.accept(false)
            } else {
                self.searchData[2] = value
                self.output.buttonValid.accept(true)
            }
        }).disposed(by: disposeBag)
        
        input.backObserver.subscribe(onNext: {
            self.currentStep -= 1
            self.output.nextBackValid.accept(self.currentStep)
        }).disposed(by: disposeBag)
        
        input.nextObserver.subscribe(onNext: {
            self.currentStep += 1
            self.output.nextBackValid.accept(self.currentStep)
        }).disposed(by: disposeBag)
        
        input.surveyObserver
            .flatMap(inputSurvey)
            .subscribe({ event in
                switch event {
                case .next(_):
                    print("설문조사")
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
        
        input.getSurveyObserver
            .flatMap(getSurvey)
            .subscribe({ event in
                switch event {
                case .next(let survey):
                    self.survey = survey
                    self.output.surveyValue.accept(survey)
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
        
        input.goMainObserver
            .flatMap(transferPlace)
            .subscribe({ event in
                switch event {
                case .next(let place):
                    UserDefaults.standard.setValue("no", forKey: "initialUser")
                    MainMapViewModel.instance.output.locationValue.accept(place)
                    self.output.goToMainValue.accept(())
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
     푸시 알림 선택 시 해당 메모리로 이동
     - Parameters:
     -push: Push
     - Throws: MellyError
     - Returns:Memory
     */
    func inputSurvey() -> Observable<Void> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                
                let parameters:Parameters = ["recommendPlace": self.searchData[0],
                                             "recommendActivity": self.searchData[1],
                                             "recommendGroup": GroupFilter.getGroupSurveyValue(self.searchData[2])]
                
                
                let url = "https://api.melly.kr/api/user/survey"
                
                AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                    
                            let decoder = JSONDecoder()
                            
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                print(json)
                                if json.message == "성공" {
                                
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
            
            return Disposables.create()
        }
        
    }
    
    /**
     푸시 알림 선택 시 해당 메모리로 이동
     - Parameters:
     -push: Push
     - Throws: MellyError
     - Returns:Memory
     */
    func getSurvey() -> Observable<Survey> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                let header:HTTPHeaders = [
                    "Content-Type": "application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                let url = "https://api.melly.kr/api/user/survey"
                
                AF.request(url, method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                    
                            let decoder = JSONDecoder()
                            
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                print(json)
                                if json.message == "성공" {
                                
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["surveyRecommend"] as Any) {
                                        
                                        if let survey = try? decoder.decode(Survey.self, from: data) {
                                            
                                            observer.onNext(survey)
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
    
    func transferPlace() -> Observable<Place> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser,
               let survey = self.survey {
                
                let parameters:Parameters = ["lat": survey.position.lat,
                                             "lng": survey.position.lng]
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/place", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "장소 상세 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data as Any) {
                                        
                                        if let place = try? decoder.decode(Place.self, from: data) {
                                            
                                            observer.onNext(place)
                                        }
                                        
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
