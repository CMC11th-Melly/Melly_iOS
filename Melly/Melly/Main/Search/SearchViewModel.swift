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
        let tfRightViewValue = PublishRelay<Bool>()
        let errorValue = PublishRelay<String>()
    }
    
    init() {
        
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
                    self.output.getPlaceValue.accept(place)
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
     ?????? ????????? ???????????? ???????????? ??????
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
     ????????? ????????? ??????????????? ???????????? ???????????? ??????
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
     ????????? ????????? ????????? ???????????? ??????
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
                                if json.message == "????????? ?????? ??????" {
                                    
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
                                let error = MellyError(code: 999, msg: "??????????????? ?????? ??????????????????.")
                                result.error = error
                                observer.onNext(result)
                            }
                        case .failure(_):
                            let error = MellyError(code: 2, msg: "???????????? ????????? ??????????????????.")
                            result.error = error
                            observer.onNext(result)
                        }
                    }
                
            }
            
            
            return Disposables.create()
        }
        
    }
    
    /**
     ????????? ????????? ????????? ???????????? ??????
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
                        let error = MellyError(code: 2, msg: "???????????? ????????? ??????????????????.")
                        result.error = error
                        observer.onNext(result)
                    }
                    
                }
            
            return Disposables.create()
        }
        
    }
    
    /**
     ??????????????? Place ????????? ???????????? ??????
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
                                    
                                    if json.message == "?????? ?????? ??????" {
                                       
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
                                    let error = MellyError(code: 999, msg: "??????????????? ?????? ??????????????????.")
                                    result.error = error
                                    observer.onNext(result)
                                }
                            case .failure(_):
                                let error = MellyError(code: 2, msg: "???????????? ????????? ??????????????????.")
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

                                    if json.message == "????????? ???????????? ?????? ??????" {

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
                                    let error = MellyError(code: 999, msg: "??????????????? ?????? ??????????????????.")
                                    result.error = error
                                    observer.onNext(result)
                                }
                            case .failure(_):
                                let error = MellyError(code: 2, msg: "???????????? ????????? ??????????????????.")
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
     ????????? ??? ??? ?????? ??????????????? ???????????? ??????
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
     ?????? ?????? ?????? ??? 1?????? ?????? ??????
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
     ?????? ???????????? ?????? ??????
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
