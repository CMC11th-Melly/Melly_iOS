//
//  ResearchLaunchViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/04.
//

import UIKit
import RxSwift
import RxCocoa

class ResearchLaunchViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    let titleLB = UILabel().then {
        $0.text = "안녕하세요, 소피아님!"
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 26)
    }
    
    let subLB = UILabel().then {
        $0.text = "소피아님의 소중한 메모리 작성을 위해\n간단히 몇가지 물어볼게 있어요!"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    let logoImageView = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
    
    let bottomView = UIView()
    
    let nextBT = CustomButton(title: "다음으로").then {
        $0.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    func setUI() {
        
        view.backgroundColor = .white
        
        safeArea.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(88)
            $0.centerX.equalToSuperview()
        }
        
        safeArea.addSubview(subLB)
        subLB.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
        }
        
        safeArea.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(subLB.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-31)
            $0.height.equalTo(350)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(105)
        }
        
        bottomView.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
    }
    
    func bind() {
        nextBT.rx.tap
            .subscribe(onNext: {
                let vc = ResearchMainViewController()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        
    }
    

}
