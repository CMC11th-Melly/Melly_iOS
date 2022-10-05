//
//  LocationViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/05.
//

import UIKit
import RxSwift
import RxCocoa

protocol LocationViewControllerDelegate:AnyObject {
    func didDismissButton()
}

class LocationViewController: UIViewController {

    let contentView = UIView()
    let disposeBag = DisposeBag()
    weak var delegate: LocationViewControllerDelegate?
    let locationLB = UILabel().then {
        $0.text = "상수동 거리"
    }
    
    let backBT = BackButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentView)
        contentView.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        backBT.rx.tap.subscribe(onNext: {
            self.delegate?.didDismissButton()
        }).disposed(by: disposeBag)
        
    }
    
    
    
}
