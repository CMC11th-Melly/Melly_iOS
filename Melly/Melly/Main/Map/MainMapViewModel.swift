//
//  MainMapViewModel.swift
//  Melly
//
//  Created by Jun on 2022/09/29.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift
import RxAlamofire

class MainMapViewModel {
    
    let disposeBag = DisposeBag()
    let input = Input()
    let output = Output()
    
    struct Input {
        let initMarkerObserver = BehaviorRelay<Void>(value: ())
    }
    
    struct Output {
        let markerValue = PublishRelay<[Marker]>()
    }
    
    init() {
        
        
        input.initMarkerObserver
            .flatMap(createMarker)
            .subscribe({ event in
                switch event {
                case .next(let marker):
                    self.output.markerValue.accept(marker)
                case .error(let error):
                    print(error)
                case .completed:
                    break
                }
            }).disposed(by: disposeBag)
        
    }
    
    
    func createMarker() -> Observable<[Marker]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                let parameters:Parameters = ["groupType": ""]
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                
                AF.request("https://api.melly.kr/api/place/list", method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            if let json = try? decoder.decode([Marker].self, from: data) {
                                observer.onNext(json)
                            } else {
                                //에러처리
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
