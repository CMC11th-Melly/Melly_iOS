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
    
    var place:Place?
    var memory:Memory?
    var memoryData:MemoryData
    
    private let disposeBag = DisposeBag()
    
    let keywordData = ["행복해요", "즐거워요", "재밌어요", "기뻐요", "좋아요", "그냥 그래요"]
    let rxDisclosureData = Observable<[String]>.just(["전체 공개", "선택한 메모리 그룹만 공개", "비공개"])
    let rxKeywordData = Observable<[String]>.just(["행복해요", "즐거워요", "재밌어요", "기뻐요", "좋아요", "그냥 그래요"])
    var starData = [false, false, false, false, false]
    var groupData:[Group] = []
    var dateValue:String = ""
    var timeValue:String = ""
    var images:[Data] = []
    
    let input = Input()
    let output = Output()
    
    
    struct Input {
        let viewWillAppearObserver = PublishRelay<Void>()
        
        let starObserver = PublishRelay<Int>()
        let imagesObserver = PublishRelay<[UIImage]>()
        let keywordObserver = PublishRelay<String>()
        let titleObserver = PublishRelay<String>()
        let contentObserver = PublishRelay<String>()
        let groupObserver = PublishRelay<Group?>()
        let dateObserver = BehaviorRelay<Date>(value: Date())
        let timeObserver = BehaviorRelay<Date>(value: Date())
        let writeObserver = PublishRelay<Void>()
        let registerServerObserver = PublishRelay<Void>()
        let openTypeObserver = PublishRelay<MemoryOpenType>()
        let openTypeCancelObserver = PublishRelay<Void>()
        
        let getPlaceObserver = PublishRelay<Place>()
    }
    
    struct Output {
        let starValue = PublishRelay<[Bool]>()
        let imagesValue = PublishRelay<[UIImage]>()
        let groupValue = PublishRelay<Group?>()
        let errorValue = PublishRelay<String>()
        let successValue = PublishRelay<Void>()
        let placeValue = PublishRelay<Place>()
        let goToDisclosurePanel = PublishRelay<Void>()
        let cancelOpenType = PublishRelay<Void>()
    }
    
    struct MemoryData:Codable {
        var lat:Double = -1
        var lng:Double = -1
        var placeName:String = ""
        var placeCategory:String = ""
        var title:String = ""
        var content:String = ""
        var keyword:[String] = []
        var groupId:Int? = nil
        var visitedDate:String = ""
        var star:Int = 0
        var openType:String = ""
        
        init() {
            
        }
        
        init(_ place:Place) {
            self.lat = place.position.lat
            self.lng = place.position.lng
            self.placeName = place.placeName
            self.placeCategory = place.placeCategory
        }
        
        init(_ place: Place, _ memory: Memory) {
            
            self.lat = place.position.lat
            self.lng = place.position.lng
            self.placeName = place.placeName
            self.placeCategory = place.placeCategory
            
            self.title = memory.title
            self.content = memory.content
            self.keyword = memory.keyword
            self.visitedDate = memory.visitedDate
            self.star = memory.stars
            
        }
        
        
    }
    
    init(_ place: Place? = nil, _ memory: Memory? = nil) {
        self.place = place
        self.memory = memory
        
        if let place = place {
            
            if let memory = memory {
                self.memoryData = MemoryData(place, memory)
            } else {
                self.memoryData = MemoryData(place)
            }
            
        } else {
            self.memoryData = MemoryData()
        }
        
        input.viewWillAppearObserver
            .flatMap(getGroupName)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let data = result.success as? [Group] {
                    self.groupData = data
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
            
            if self.memoryData.keyword.contains(value) {
                
                if let index = self.memoryData.keyword.firstIndex(of: value) {
                    self.memoryData.keyword.remove(at: index)
                }
                
            } else {
                self.memoryData.keyword.append(value)
            }
            
        }).disposed(by: disposeBag)
        
        input.groupObserver.subscribe(onNext: { value in
            if let value = value {
                self.memoryData.groupId = value.groupId
            }
            self.output.groupValue.accept(value)
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
            .map(checkValue)
            .subscribe(onNext: { value in
                if value == "" {
                    self.output.goToDisclosurePanel.accept(())
                } else {
                    self.output.errorValue.accept(value)
                }
            }).disposed(by: disposeBag)
        
        input.registerServerObserver
            .flatMap(writeMemory)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else {
                    self.output.successValue.accept(())
                }
                
            }).disposed(by: disposeBag)
        
        input.openTypeObserver
            .subscribe(onNext: { value in
                self.memoryData.openType = value.rawValue
            }).disposed(by: disposeBag)
        
        input.openTypeCancelObserver
            .subscribe(onNext: {
                self.output.cancelOpenType.accept(())
            }).disposed(by: disposeBag)
        
        input.getPlaceObserver
            .subscribe(onNext: { place in
                self.place = place
                self.memoryData.lat = place.position.lat
                self.memoryData.lng = place.position.lng
                self.memoryData.placeName = place.placeName
                self.memoryData.placeCategory = place.placeCategory
                self.output.placeValue.accept(place)
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
    func getGroupName() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
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
                                
                                if json.message == "성공" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["groupInfo"] as Any) {
                                        
                                        if let groups = try? decoder.decode([Group].self, from: data) {
                                            self.groupData = groups
                                            result.success = groups
                                            observer.onNext(result)
                                        }
                                        
                                    }
                                    
                                } else {
                                    let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
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
    func writeMemory() -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            
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
                                observer.onNext(result)
                            } else {
                                let error = MellyError(code: Int(json.code) ?? 0 , msg: json.message)
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
    
    func checkValue() -> String {
        
        if images.isEmpty {
            return "사진을 등록해주세요"
        } else if memoryData.title == "" {
            return "제목을 입력해주세요"
        } else if memoryData.title.count > 15 {
            return "메모리 이름은 15자이하입니다."
        } else if memoryData.content.count <= 20 {
            return "메모리를 최소 20자 이상 적어주세요"
        } else if memoryData.groupId == nil {
            return "그룹을 선택해주세요"
        } else if memoryData.star == 0 {
            return "별점을 입력해주세요"
        }
        
        return ""
        
    }
    
    
}
