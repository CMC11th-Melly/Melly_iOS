//
//  MemoryListViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/12.
//

import UIKit
import RxCocoa
import RxSwift

class MemoryListViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    let scrollView = UIScrollView()
    
    let contentView = UIView()
    
    let bottomView = UIView()
    
    let locationTitleLB = UILabel().then {
        $0.text = "성수동"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 20)
    }
    
    let locationCategoryLB = UILabel().then {
        $0.text = "거리"
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let bmButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "bookmark"), for: .normal)
    }
    
    let closeButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_x"), for: .normal)
    }
    
    let locationImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let memorySegmentedControl = UnderlineSegmentedControl(items: ["나의 메모리", "이 장소 메모리"]).then {
        $0.selectedSegmentIndex = 0
        
    }
    
    
    
    let writeMemoryBT = CustomButton(title: "이 장소에 메모리 쓰기")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    

}

extension MemoryListViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        safeArea.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        bottomView.addSubview(writeMemoryBT)
        writeMemoryBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        safeArea.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(locationTitleLB)
        locationTitleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(34)
        }
        
        contentView.addSubview(locationCategoryLB)
        locationCategoryLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalTo(locationTitleLB.snp.trailing).offset(6)
        }
        
        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(24)
        }
        
        contentView.addSubview(bmButton)
        bmButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-6)
        }
        
        contentView.addSubview(locationImageView)
        locationImageView.snp.makeConstraints {
            $0.top.equalTo(locationTitleLB.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(183)
        }
        
        contentView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(locationImageView.snp.bottom).offset(62)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        contentView.addSubview(memorySegmentedControl)
        memorySegmentedControl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(locationImageView.snp.bottom).offset(17)
            $0.height.equalTo(45)
        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        
        
        
        memorySegmentedControl.rx.controlEvent([.valueChanged])
            .subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
        
    }
    
    private func bindOutput() {
        
    }
}

