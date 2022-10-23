//
//  MemoryDetailViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/23.
//

import UIKit
import RxSwift
import RxCocoa
import Then

class MemoryDetailViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    let imagePageView = UIScrollView()
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let backBT = BackButton()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    

}

extension MemoryDetailViewController {
    
    private func setUI() {
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
    }
    
    private func bindOutput() {
        
    }
    
}
