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
    var images:[UIImage] = []
    let input = Input()
    let output = Output()
    
    struct Input {
        let starObserver = PublishRelay<Int>()
        let imagesObserver = PublishRelay<[UIImage]>()
        let keywordObserver = PublishRelay<String>()
    }
    
    struct Output {
        let starValue = PublishRelay<[Bool]>()
        let imagesValue = PublishRelay<[UIImage]>()
    }
    
    init(_ place: Place) {
        self.place = place
        
        getGroupName().subscribe({ event in
            switch event {
            case .next(let data):
                print(data)
            case .error(let error):
                print(error.localizedDescription)
            case .completed:
                break
            }
        }).disposed(by: disposeBag)
        
        
        input.starObserver.subscribe(onNext: { value in
            self.starData = self.getStarValue(value)
            self.output.starValue.accept(self.starData)
        }).disposed(by: disposeBag)
        
        input.imagesObserver.subscribe(onNext: { value in
            self.images = value
            self.output.imagesValue.accept(self.images)
        }).disposed(by: disposeBag)
        
    }
    
    
    func getStarValue(_ index: Int) -> [Bool] {
        
        if starData[index] {
            return [false, false, false, false, false]
        } else {
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
                                print(json)
                                
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
    
    
}
