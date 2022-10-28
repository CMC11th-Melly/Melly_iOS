//
//  MemoryWriteViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/14.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class MemoryWriteViewModel {
    
    let place:Place
    
    private let disposeBag = DisposeBag()
    let keywordData = ["행복해요", "즐거워요", "재밌어요", "기뻐요", "좋아요", "그냥 그래요"]
    let rxKeywordData = Observable<[String]>.just(["행복해요", "즐거워요", "재밌어요", "기뻐요", "좋아요", "그냥 그래요"])
    var starData = [false, false, false, false, false]
    var groupData:[String:Int?] = ["전체 공개":nil]
    var dateValue:String = ""
    var timeValue:String = ""
    var images:[Data] = []
    
    let input = Input()
    let output = Output()
    lazy var memoryData = MemoryData(place)
    
    struct Input {
        let starObserver = PublishRelay<Int>()
        let imagesObserver = PublishRelay<[UIImage]>()
        let keywordObserver = PublishRelay<String>()
        let titleObserver = PublishRelay<String>()
        let contentObserver = PublishRelay<String>()
        let groupObserver = PublishRelay<String>()
        let dateObserver = BehaviorRelay<Date>(value: Date())
        let timeObserver = BehaviorRelay<Date>(value: Date())
        let writeObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let starValue = PublishRelay<[Bool]>()
        let imagesValue = PublishRelay<[UIImage]>()
        let groupValue = PublishRelay<[String]>()
        let errorValue = PublishRelay<String>()
        let successValue = PublishRelay<Void>()
    }
    
    struct MemoryData:Codable {
        let lat:Double
        let lng:Double
        let placeName:String
        let placeCategory:String
        var title:String = ""
        var content:String = ""
        var keyword:String = ""
        var groupId:Int? = nil
        var visitedDate:String = ""
        var star:Int = 0
        
        init(_ place:Place) {
            self.lat = place.position.lat
            self.lng = place.position.lng
            self.placeName = place.placeName
            self.placeCategory = place.placeCategory
        }
        
    }
    
    init(_ place: Place) {
        self.place = place
        
        getGroupName().subscribe({ event in
            switch event {
            case .next(let data):
                self.output.groupValue.accept(data)
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
        
        input.titleObserver.subscribe(onNext: { value in
            self.memoryData.title = value
        }).disposed(by: disposeBag)
        
        input.contentObserver.subscribe(onNext: { value in
            self.memoryData.content = value
        }).disposed(by: disposeBag)
        
        input.starObserver.subscribe(onNext: { value in
            self.starData = self.getStarValue(value)
            self.output.starValue.accept(self.starData)
        }).disposed(by: disposeBag)
        
        input.imagesObserver.subscribe(onNext: { value in
            self.images = []
            
            for v in value {
                self.images.append(v.jpegData(compressionQuality: 1) ?? Data())
            }
            
            self.output.imagesValue.accept(value)
        }).disposed(by: disposeBag)
        
        input.keywordObserver.subscribe(onNext: { value in
            
            if self.memoryData.keyword == value {
                self.memoryData.keyword = ""
            } else {
                self.memoryData.keyword = value
            }
            
        }).disposed(by: disposeBag)
        
        input.groupObserver.subscribe(onNext: { value in
            self.memoryData.groupId = self.groupData[value] ?? nil
        }).disposed(by: disposeBag)
        
        input.dateObserver.subscribe(onNext: { value in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            self.dateValue = dateFormatter.string(from: value)
        }).disposed(by: disposeBag)
        
        input.timeObserver.subscribe(onNext: { value in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HHmm"
            self.timeValue = dateFormatter.string(from: value)
        }).disposed(by: disposeBag)
        
        input.writeObserver
            .flatMap(writeMemory)
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
     메모리에 관한 별점을 관리하는 메서드
     - Parameters:
     - index: 별의 점수(Int)
     - Throws: None
     - Returns: [Bool]
     */
    func getStarValue(_ index: Int) -> [Bool] {
        
        if starData[index] {
            return [false, false, false, false, false]
        } else {
            self.memoryData.star = index+1
            var result = [false, false, false, false, false]
            for i in 0..<5 {
                if i <= index {
                    result[i] = true
                } else {
                    result[i] = false
                }
            }
            return result
        }
        
    }
    
    
    /**
     View Model이 생성될 때 사용자가 속한 그룹을 가져와 준다.
     - Parameters:None
     - Throws: MellyError
     - Returns:[String]
     */
    func getGroupName() -> Observable<[String]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/user/group", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                if json.message == "유저가 속해있는 그룹 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["groupInfo"] as Any) {
                                        
                                        if let groups = try? decoder.decode([Group].self, from: data) {
                                            var result:[String] = ["전체 공개"]
                                            
                                            for group in groups {
                                                result.append(group.groupName)
                                                self.groupData[group.groupName] = group.groupId
                                            }
                                            observer.onNext(result)
                                        }
                                        
                                    }
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
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
                
            } else {
                //로그아웃 메서드
            }
            
            
            return Disposables.create()
        }
    }
    
    
    /**
     메모리 쓰기 버튼 클릭시 호출되는 함수(서버에 메모리 등록)
     - Parameters:None
     - Throws: MellyError
     - Returns:None
     */
    func writeMemory() -> Observable<Void> {
        
        return Observable.create { observer in
            
            if self.images.count != 0 {

                if self.memoryData.title != "" {

                    if self.memoryData.content.count >= 20 {

                        if self.memoryData.groupId != -1 {

                            if let user = User.loginedUser {
                                
                                let header:HTTPHeaders = [
                                            "Content-Type": "multipart/form-data",
                                            "Authorization" : "Bearer \(user.jwtToken)"
                                        ]
                                
                                let realUrl = URL(string: "https://api.melly.kr/api/memory")
                                let url:Alamofire.URLConvertible = realUrl!
                                
                                self.memoryData.visitedDate = self.dateValue+self.timeValue
                                
                                AF.upload(multipartFormData: { multipartFormData in
                                    
                                    for image in self.images {
                                        multipartFormData.append(image, withName: "images", fileName: "test.jpeg", mimeType: "image/jpeg")
                                    }
                                    
                                    if let memoryData = try? JSONEncoder().encode(self.memoryData) {
                                        multipartFormData.append(memoryData, withName: "memoryData", mimeType: "application/json")
                                    }
                                    
                                }, to: url, method: .post, headers: header)
                                .responseData { response in
                                    switch response.result {
                                    case .success(let response):
                                        
                                        let decoder = JSONDecoder()
                                        
                                        if let json = try? decoder.decode(ResponseData.self, from: response) {
                                            if json.message == "메모리 저장 완료" {
                                                observer.onNext(())
                                            } else {
                                                let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
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
                            
                        } else {
                            let error = MellyError(code: 888, msg: "그룹을 선택해주세요.")
                            observer.onError(error)
                        }

                    } else {
                        let error = MellyError(code: 888, msg: "메모리를 20자 이상 적어주세요.")
                        observer.onError(error)
                    }

                } else {
                    let error = MellyError(code: 888, msg: "메모리 제목을 입력해주세요.")
                    observer.onError(error)
                }

            } else {
                let error = MellyError(code: 888, msg: "이미지를 등록해주세요.")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
        
    }
    
    
}
