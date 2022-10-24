//
//  MemoryDetailViewModel.swift
//  Melly
//
//  Created by Jun on 2022/10/24.
//

import Foundation
import RxSwift
import RxCocoa

class MemoryDetailViewModel {
    
    private let disposeBag = DisposeBag()
    
    var memory:Memory
    let input = Input()
    let output = Output()
    
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init(_ memory: Memory) {
        self.memory = memory
    }
    
    
    
    
}
