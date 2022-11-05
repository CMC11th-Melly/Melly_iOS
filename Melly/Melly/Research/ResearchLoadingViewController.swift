//
//  ResearchLoadingViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/05.
//

import UIKit
import RxSwift
import RxCocoa

class ResearchLoadingViewController: UIViewController {
    
    let vm = ResearchMainViewModel.instance
    let disposeBag = DisposeBag()
    
    lazy var mainLB = UILabel().then {
        $0.textColor = UIColor(red: 0.059, green: 0.053, blue: 0.363, alpha: 1)
        $0.text = "\(User.loginedUser!.nickname)님을 분석중이에요"
        $0.font = UIFont(name: "Pretendard-Bold", size: 26)
    }
    
    let subLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 20)
        $0.text = "조금만 기다려주세요!"
    }
    
    let logoImageView = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.surveyObserver.accept(())
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let vc = ResearchResultViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func setUI() {
        view.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        
        safeArea.addSubview(mainLB)
        mainLB.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(88)
            $0.height.equalTo(36)
        }
        
        safeArea.addSubview(subLB)
        subLB.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(mainLB.snp.bottom).offset(33)
            $0.height.equalTo(28)
        }
        
        safeArea.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(subLB.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(350)
        }
        
    }
    
    
    
}
