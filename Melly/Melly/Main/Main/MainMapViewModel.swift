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
import NMapsMap

class MainMapViewModel {
    
    let disposeBag = DisposeBag()
    let input = Input()
    let output = Output()
    var marker:[Marker] = []
    var filterGroup = GroupFilter.all
    
    struct Input {
        let initMarkerObserver = BehaviorRelay<GroupFilter>(value: .all)
        let touchMarkerObserver = PublishRelay<Int>()
        let filterGroupObserver = PublishRelay<GroupFilter>()
    }
    
    struct Output {
        let markerValue = PublishRelay<[NMFMarker]>()
        let filterValue = PublishRelay<GroupFilter>()
        let locationValue = PublishRelay<Place>()
        let errorValue = PublishRelay<String>()
    }
    
    init() {
        
        input.initMarkerObserver
            .flatMap(createMarker)
            .subscribe({ event in
                switch event {
                case .next(let markers):
                    DispatchQueue.global().async {
                        
                        var totalMarkers = [NMFMarker]()
                        for i in 0..<markers.count {
                            
                            let marker = NMFMarker(position: NMGLatLng(lat: markers[i].position.lat, lng: markers[i].position.lng))
                            marker.iconImage = NMFOverlayImage(image: UIImage(named: "marker")!)
                            marker.captionText = "\(markers[i].memoryCount)"
                            marker.captionAligns = [NMFAlignType.center]
                            marker.captionTextSize = 10
                            marker.captionColor = .white
                            marker.touchHandler = { (overlay) -> Bool in
                                self.input.touchMarkerObserver.accept(markers[i].placeId)
                                return true
                            }
                            totalMarkers.append(marker)
                        }
                        self.output.markerValue.accept(totalMarkers)
                    }
                    
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
        
        input.filterGroupObserver.subscribe(onNext: { value in
            self.filterGroup = self.filterGroup == value ? .all : value
            self.input.initMarkerObserver.accept(self.filterGroup)
        }).disposed(by: disposeBag)
        
        
        
        input.touchMarkerObserver
            .flatMap(clickMarker)
            .subscribe({ event in
                switch event {
                case .next(let place):
                    self.output.locationValue.accept(place)
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
     유저가 저장한 메모리들을 장소별로 분류하여 마커로 보여주는 함수
     - Parameters
        - filter : GroupFilter(그룹별로 필터 설정)
     - Throws: MellyError
     - Returns:[Marker]
     */
    func createMarker(_ filter: GroupFilter) -> Observable<[Marker]> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                let parameters:Parameters = ["groupType": filter.rawValue]
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
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                if json.message == "유저가 메모리 작성한 장소 조회" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["place"] as Any) {
                                        
                                        if let markers = try? decoder.decode([Marker].self, from: data) {
                                            self.marker = markers
                                    
                                            observer.onNext(markers)
                                        } else {
                                            observer.onNext([])
                                        }
                                        
                                    } else {
                                        observer.onNext([])
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
    
    /**
     마커에 저장된 place 기본키를 이용해 장소 데이터를 가져옴
     - Parameters
        - placeID : Int(해당 장소의 id)
     - Throws: MellyError
     - Returns:Place
     */
    func clickMarker(_ placeId: Int) -> Observable<Place> {
        
        return Observable.create { observer in
            
            if let user = User.loginedUser {
                
                let header:HTTPHeaders = [
                    "Connection":"keep-alive",
                    "Content-Type":"application/json",
                    "Authorization" : "Bearer \(user.jwtToken)"
                    ]
                
                AF.request("https://api.melly.kr/api/place/\(placeId)/search", method: .get, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            let decoder = JSONDecoder()
                            
                            if let json = try? decoder.decode(ResponseData.self, from: data) {
                                
                                if json.message == "메모리 제목으로 장소 검색" {
                                    
                                    if let data = try? JSONSerialization.data(withJSONObject: json.data?["placeInfo"] as Any) {
                                        
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
