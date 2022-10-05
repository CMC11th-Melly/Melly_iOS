//
//  ResearchLoadingViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/05.
//

import UIKit

class ResearchLoadingViewController: UIViewController {

    let backBT = BackButton()
    
    let mainLB = UILabel().then {
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        $0.text = "소피아님을 분석중이에요"
        $0.font = UIFont(name: "Pretendard-Bold", size: 22)
    }
    
    let subLB = UILabel().then {
        $0.textColor = UIColor(red: 0.427, green: 0.459, blue: 0.506, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "조금만 기다려주세요!"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    private func setUI() {
        view.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        
        safeArea.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(mainLB)
        mainLB.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(backBT.snp.bottom).offset(55)
        }
        
        safeArea.addSubview(subLB)
        subLB.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(mainLB.snp.bottom).offset(35)
        }
        
    }
    
}
