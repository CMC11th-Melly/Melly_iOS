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
    
    init(_ place: Place) {
        self.place = place
    }
    
}
