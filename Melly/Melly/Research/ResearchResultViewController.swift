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

    let scrollView = UIScrollView()
    let contentsView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
    }
    
    let titleLB = UILabel().then {
        $0.text = "소피아님에게 딱맞는 메모리 활동은?"
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 22)
    }
    
    let titleImageView = UIImageView(image: UIImage(systemName: "bed.double"))
    
    let mainLB = UILabel().then {
        $0.text = "연인과 성수동 맛집테이블"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 26)
    }
    
    
    let mainBT = CustomButton(title: "추천 장소에서 메모리 쌓으러가기")
    
    let groupSubLb = ResearchComponent("연인과 활동이 잦은 당신에게 추천해요", "Emoji")
    
    let contentsSubLb = ResearchComponent("맛집의 분위기 즐기고 추억도 쌓아보세요", "Emoji")
    
    let locationSubLb = ResearchComponent("성수의 분위기 좋은 ‘성수다락' 추천해요", "Emoji")
    
    let skipButton = UIButton(type: .custom).then {
        let title = "다시하기"
        let attributedString = NSMutableAttributedString(string: title)
        let font = UIFont(name: "Pretendard-SemiBold", size: 16)!
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1), range: NSRange(location: 0, length: title.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let bottomView = UIView()
    
    let nextBT = CustomButton(title: "추천 장소에서 메모리 쌓으러가기")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    

}

extension ResearchResultViewController {
    
    func setUI() {
        
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
        
        
        safeArea.addSubview(scrollView)
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
            $0.top.equalToSuperview().offset(55)
            $0.centerX.equalToSuperview()
        }
        
        contentsView.addSubview(titleImageView)
        titleImageView.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(248)
            $0.height.equalTo(163)
        }
        
        contentsView.addSubview(mainLB)
        mainLB.snp.makeConstraints {
            $0.top.equalTo(titleImageView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        
        contentsView.addSubview(groupSubLb)
        groupSubLb.snp.makeConstraints {
            $0.top.equalTo(mainLB.snp.bottom).offset(35)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentsView.addSubview(contentsSubLb)
        contentsSubLb.snp.makeConstraints {
            $0.top.equalTo(groupSubLb.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentsView.addSubview(locationSubLb)
        locationSubLb.snp.makeConstraints {
            $0.top.equalTo(contentsSubLb.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentsView.addSubview(skipButton)
        skipButton.snp.makeConstraints {
            $0.top.equalTo(locationSubLb.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-11)
        }
        
        
        
    }
    
}
