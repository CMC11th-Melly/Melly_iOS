//
//  ResearchResultViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/05.
//

import UIKit
import Then
import RxSwift
import RxCocoa

class ResearchResultViewController: UIViewController {

    private let disposeBag = DisposeBag()
    let vm = ResearchMainViewModel.instance

    let scrollView = UIScrollView()
    let contentsView = UIView()
    
    lazy var titleLB = UILabel().then {
        $0.text = "\(User.loginedUser!.nickname)님에게 딱맞는 메모리 활동은?"
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 22)
    }
    
    let titleImageView = UIImageView(image: UIImage(systemName: "bed.double"))
    
    let mainLB = UILabel().then {
        $0.text = "연인과 성수동 맛집테이블"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 26)
    }
    
    let groupSubLb = ResearchComponent("연인과 활동이 잦은 당신에게 추천해요")
    
    let contentsSubLb = ResearchComponent("맛집의 분위기 즐기고 추억도 쌓아보세요")
    
    let locationSubLb = ResearchComponent("성수의 분위기 좋은 ‘성수다락' 추천해요")
    
    let reloadBT = UIButton(type: .custom).then {
        let title = "다시하기"
        let attributedString = NSMutableAttributedString(string: title)
        let font = UIFont(name: "Pretendard-SemiBold", size: 16)!
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1), range: NSRange(location: 0, length: title.count))
        $0.setAttributedTitle(attributedString, for: .normal)
        $0.setImage(UIImage(named: "research_reload"), for: .normal)
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -6)
    }
    
    let bottomView = UIView()
    
    let nextBT = CustomButton(title: "추천 장소에서 메모리 쌓으러가기").then {
        $0.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.getSurveyObserver.accept(())
    }
    

}

extension ResearchResultViewController {
    
    private func setUI() {
        view.backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        
        safeArea.addSubview(scrollView)
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(172)
        }
        
        bottomView.addSubview(reloadBT)
        reloadBT.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        bottomView.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.top.equalTo(reloadBT.snp.bottom).offset(11)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        scrollView.addSubview(contentsView)
        contentsView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentsView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(73)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(31)
        }
        
        contentsView.addSubview(titleImageView)
        titleImageView.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(330)
            $0.height.equalTo(210)
        }
        
        contentsView.addSubview(mainLB)
        mainLB.snp.makeConstraints {
            $0.top.equalTo(titleImageView.snp.bottom).offset(10)
            $0.height.equalTo(36)
            $0.centerX.equalToSuperview()
        }
        
        contentsView.addSubview(groupSubLb)
        groupSubLb.snp.makeConstraints {
            $0.top.equalTo(mainLB.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.height.equalTo(56)
        }
        
        contentsView.addSubview(contentsSubLb)
        contentsSubLb.snp.makeConstraints {
            $0.top.equalTo(groupSubLb.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.height.equalTo(56)
        }
        
        contentsView.addSubview(locationSubLb)
        locationSubLb.snp.makeConstraints {
            $0.top.equalTo(contentsSubLb.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    private func bind() {
        
        nextBT.rx.tap
            .bind(to: vm.input.goMainObserver)
            .disposed(by: disposeBag)
        
        reloadBT.rx.tap.subscribe(onNext: {
            self.navigationController?.popToRootViewController(animated: true)
        }).disposed(by: disposeBag)
        
        vm.output.goToMainValue
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.surveyValue.subscribe(onNext: { survey in
            self.mainLB.text = survey.words[0]
            self.groupSubLb.label.text = survey.words[1]
            self.contentsSubLb.label.text = survey.words[2]
            self.locationSubLb.label.text = survey.words[3]
        }).disposed(by: disposeBag)
        
    }
    
    
}
