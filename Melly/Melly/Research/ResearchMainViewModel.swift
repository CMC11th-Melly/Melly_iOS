//
//  ResearchMainViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/04.
//

import Foundation
import RxCocoa
import RxSwift


class ResearchMainViewModel {
    
    let disposeBag = DisposeBag()
    let input = Input()
    let output = Output()
    var searchData = ["","",""]
    var currentStep = 1
    
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
    }
    
    struct Output {
        let buttonValid = PublishRelay<Bool>()
        let nextBackValid = PublishRelay<Int>()
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
        
        
        
    }
    
    
}
