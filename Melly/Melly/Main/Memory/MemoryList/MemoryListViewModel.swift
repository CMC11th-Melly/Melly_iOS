//
//  MemoryListViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/13.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class MemoryListViewModel {
    
    var place:Place?
    
    static let instance = MemoryListViewModel()
    
    private let disposeBag = DisposeBag()
    
    let input = Input()
    let output = Output()
    
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init() {
        
    }
    
    
    
}
