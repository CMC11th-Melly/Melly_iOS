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
    
    static let instance = MainMapViewModel()
    
    let disposeBag = DisposeBag()
    let input = Input()
    let output = Output()
    var marker:[Marker] = []
    var filterGroup = GroupFilter.all
    var totalMarkers = [NMFMarker]()
    
    struct Input {
        let initMarkerObserver = PublishRelay<GroupFilter>()
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
            .map(removeMarker)
            .flatMap(createMarker)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let markers = result.success as? [Marker] {
                    DispatchQueue.global().async {
                        
                        
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
                            self.totalMarkers.append(marker)
                        }
                        self.output.markerValue.accept(self.totalMarkers)
                    }
                    
                }
                
                
            }).disposed(by: disposeBag)
        
        input.filterGroupObserver.subscribe(onNext: { value in
            self.filterGroup = self.filterGroup == value ? .all : value
            self.input.initMarkerObserver.accept(self.filterGroup)
        }).disposed(by: disposeBag)
        
        
        
        input.touchMarkerObserver
            .flatMap(clickMarker)
            .subscribe(onNext: { result in
                
                if let error = result.error {
                    self.output.errorValue.accept(error.msg)
                } else if let place = result.success as? Place {
                    self.output.locationValue.accept(place)
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
    func createMarker(_ filter: GroupFilter) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
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
                                            result.success = markers
                                            observer.onNext(result)
                                        } else {
                                            let data:[Marker] = []
                                            result.success = data
                                            observer.onNext(result)
                                        }
                                        
                                    } else {
                                        let data:[Marker] = []
                                        result.success = data
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
     마커에 저장된 place 기본키를 이용해 장소 데이터를 가져옴
     - Parameters
        - placeID : Int(해당 장소의 id)
     - Throws: MellyError
     - Returns:Place
     */
    func clickMarker(_ placeId: Int) -> Observable<Result> {
        
        return Observable.create { observer in
            var result = Result()
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
                                            result.success = place
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
    
    func removeMarker(_ filter: GroupFilter) -> GroupFilter {
        
        for marker in totalMarkers {
            marker.mapView = nil
        }
        
        totalMarkers = []
        
        return filter
    }
    
}
