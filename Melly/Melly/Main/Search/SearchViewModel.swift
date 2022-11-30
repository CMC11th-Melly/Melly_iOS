//
//  SearchViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/06.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class SearchViewModel {
    
    private let disposeBag = DisposeBag()
    let input = Input()
    let output = Output()
    
    let isSearch:Bool
    
    struct Input {
        let searchObserver = PublishRelay<String>()
        let clickSearchObserver = PublishRelay<Search>()
        let searchTextObserver = PublishRelay<String?>()
        let removeRecentObserver = PublishRelay<Search>()
        let recentCVObserver = PublishRelay<Void>()
        let removeAllObserver = PublishRelay<Void>()
    }
    
    struct Output {
        let recentValue = PublishRelay<[Search]>()
        let searchValue = PublishRelay<[Search]>()
        let switchValue = PublishRelay<Bool>()
        let getPlaceValue = PublishRelay<Place>()
        let goToMemoryValue = PublishRelay<Place>()
        let tfRightViewValue = PublishRelay<Bool>()
        let errorValue = PublishRelay<String>()
    }
    
    init(_ isSearch: Bool) {
        self.isSearch = isSearch
        
        input.recentCVObserver
            .map(getRecentSearch)
            .subscribe(onNext: { value in
                self.output.recentValue.accept(value)
            }).disposed(by: disposeBag)
        
        input.removeAllObserver
            .map(removeAllRecentSearch)
            .subscribe(onNext: { value in
                self.output.recentValue.accept(value)
            }).disposed(by: disposeBag)
        
        input.searchObserver
            .flatMap(search)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let searchs = result.success as? [Search] {
                    self.output.searchValue.accept(searchs)
                    self.output.switchValue.accept(true)
                }
                
                
            }).disposed(by: disposeBag)
        
        input.clickSearchObserver
            .flatMap(transferPlace)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let place = result.success as? Place {
                    print(place)
                    if self.isSearch {
                        self.output.getPlaceValue.accept(place)
                    } else {
                        self.output.goToMemoryValue.accept(place)
                    }
                    
                }
                
            }).disposed(by: disposeBag)
        
        input.searchTextObserver
            .subscribe(onNext: { value in
                if let value = value {
                    if value == "" {
                        self.output.tfRightViewValue.accept(false)
                    } else {
                        self.output.tfRightViewValue.accept(true)
                    }
                } else {
                    self.output.tfRightViewValue.accept(false)
                }
            }).disposed(by: disposeBag)
        
        input.removeRecentObserver
            .flatMap(removeRecentSearch)
            .subscribe(onNext: { value in
                self.output.recentValue.accept(value)
            }).disposed(by: disposeBag)
        
    }
    
    /**
     최근 검색한 내역들을 가져오는 함수
     - Parameters:None
     - Throws: MellyError
     - Returns:[Search]
     */
    func getRecentSearch() -> [Search] {
        
        
        if let user = User.loginedUser {
            
            if let data = UserDefaults.standard.value(forKey: "\(user.email)_recent") as? Data {
                if let recents = try? PropertyListDecoder().decode([Search].self, from: data) {
                    return recents
                } else {
                    return []
                }
            }
        } else {
            return []
        }
        
        return []
    }
    
    
    /**
     메모리 검색과 주소검색을 통합하여 리턴하는 함수
     - Parameters:
        -text: String
     - Throws: MellyError
     - Returns:[Search]
     */
    func search(_ text: String) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            Observable.combineLatest(self.searchNaver(text), self.searchMemory(text))
                .subscribe(onNext: { naver, memory in
                    
                    if let error = naver.error {
                        result.error = error
                    } else if let error = memory.error {
                        result.error = error
                    } else {
                        let searchNaver = naver.success as? [Search] ?? []
                        let searchMemory = memory.success as? [Search] ?? []
                        
                        result.success = searchNaver + searchMemory
                    }
                    
                    
                    observer.onNext(result)
                    
                    
                }).disposed(by: self.disposeBag)
            
            
            return Disposables.create()
        }
        
        
    }
    
    /**
     메모리 검색한 결과를 가져오는 함수
     - Parameters:
        -text: String
     - Throws: MellyError
     - Returns:[Search]
     */
    func searchMemory(_ text:String) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            if let user = User.loginedUser {
                
                let parameters:Parameters = ["memoryName": text]
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                ]
                
                AF.request("https://api.melly.kr/api/memory/search", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                if json.message == "메모리 제목 검색" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["memoryNames"] as Any) {
                                        
                                        if let memories = try? decoder.decode([SearchMemory].self, from: data) {
                                            var searchs:[Search] = []
                                            
                                            for memory in memories {
                                                let search = Search(memory)
                                                searchs.append(search)
                                                
                                            }
                                            result.success = searchs
                                            observer.onNext(result)
                                        } else {
                                            let searchs:[Search] = []
                                            result.success = searchs
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
     장소를 검색한 결과를 가져오는 함수
     - Parameters:
        -text: String
     - Throws: MellyError
     - Returns:[Search]
     */
    func searchNaver(_ text: String) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            let headers:HTTPHeaders = ["Connection": "keep-alive",
                                       "Content-Type": "application/json",
                                       "X-Naver-Client-Id":"jtQc03hW31ZbOhWbv35m",
                                       "X-Naver-Client-Secret": "SabQEJMs1l"]
            
            let parameters:Parameters = ["query": text,
                                         "display": 5,
                                         "sort": "random"]
            
            AF.request("https://openapi.naver.com/v1/search/local.json", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: headers)
                .responseData { response in
                    
                    switch response.result {
                    case .success(let data):
                        
                        let decoder = JSONDecoder()
                        if let json = try? decoder.decode(SearchLocation.self, from: data) {
                            
                            var searchs:[Search] = []
                            
                            for item in json.items {
                                let s = Search(item, type: true)
                                searchs.append(s)
                                
                            }
                            result.success = searchs
                            observer.onNext(result)
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
    
    /**
     검색결과를 Place 모델로 변환하여 리턴
     - Parameters:
        -search: Search
     - Throws: MellyError
     - Returns:Place
     */
    func transferPlace(_ search: Search) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
            
            if let user = User.loginedUser {
                
                if search.placeId == -1 {
                    let parameters:Parameters = ["lat": search.lat,
                                                 "lng": search.lng]
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
                                            
                                            if var place = try? decoder.decode(Place.self, from: data) {
                                                
                                                if place.placeId == -1 {
                                                    place.placeName = search.title
                                                    place.placeCategory = search.category
                                                } else {
                                                    place.placeName = search.title
                                                    place.placeCategory = search.category
                                                }
                                                result.success = place
                                                observer.onNext(result)
                                                self.addRecentSearch(search)
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
                    let header:HTTPHeaders = [
                        "Connection":"keep-alive",
                        "Content-Type":"application/json",
                        "Authorization" : "Bearer \(user.jwtToken)"
                    ]

                    AF.request("https://api.melly.kr/api/place/\(search.placeId)/search", method: .get, headers: header)
                        .responseData { response in
                            switch response.result {
                            case .success(let data):
                                
                                let decoder = JSONDecoder()
                                if let json = try? decoder.decode(ResponseData.self, from: data) {

                                    if json.message == "메모리 제목으로 장소 검색" {

                                        if let data = try? JSONSerialization.data(withJSONObject: json.data?["placeInfo"] as Any) {
                                            if let place = try? decoder.decode(Place.self, from: data) {
                                                result.success = place
                                                observer.onNext(result)
                                                self.addRecentSearch(search)
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
            

            }
                
            
            return Disposables.create()
        }
        
    }
    
    
    /**
     검색을 한 후 최근 검색내역에 저장하는 함수
     - Parameters:
        -search: Search
     - Throws: MellyError
     - Returns:None
     */
    func addRecentSearch(_ search: Search) {
        
        if let user = User.loginedUser {
            var search = search
            search.isRecent = true
            if let data = UserDefaults.standard.value(forKey: "\(user.email)_recent") as? Data {
                if var recents = try? PropertyListDecoder().decode([Search].self, from: data) {
                    
                    if recents.contains(search) {
                        if let index = recents.firstIndex(of: search) {
                            recents.remove(at: index)
                            recents.insert(search, at: 0)
                        }
                    } else {
                        recents.insert(search, at: 0)
                    }
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(recents), forKey: "\(user.email)_recent")
                    
                } else {
                    let recents = [search]
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(recents), forKey: "\(user.email)_recent")
                }
            } else {
                let recents = [search]
                UserDefaults.standard.set(try? PropertyListEncoder().encode(recents), forKey: "\(user.email)_recent")
            }
        }
        
    }
    
    /**
     최근 검색 내역 중 1개의 내역 삭제
     - Parameters:
        -search: Search
     - Throws: MellyError
     - Returns:[Search]
     */
    func removeRecentSearch(_ search: Search) -> Observable<[Search]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                if let data = UserDefaults.standard.value(forKey: "\(user.email)_recent") as? Data {
                    if var recents = try? PropertyListDecoder().decode([Search].self, from: data) {
                        
                        if let index = recents.firstIndex(of: search) {
                            
                            recents.remove(at: index)
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(recents), forKey: "\(user.email)_recent")
                            observer.onNext(recents)
                            
                        }
                        
                    }
                }
                
            }
            
            
            return Disposables.create()
        }
        
    }
    
    /**
     최근 검색내역 모두 삭제
     - Throws: MellyError
     - Returns:[Search]
     */
    func removeAllRecentSearch() -> [Search] {
        
        if let user = User.loginedUser {
            UserDefaults.standard.set(nil, forKey: "\(user.email)_recent")
        }
        
        
        return []
    }
    
    
    
    
}
