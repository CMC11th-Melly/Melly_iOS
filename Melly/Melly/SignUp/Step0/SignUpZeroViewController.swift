//
//  SignUpZeroViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/23.
//

import UIKit
import RxCocoa
import RxSwift
import Then

class SignUpZeroViewController: UIViewController {

    let disposeBag = DisposeBag()
    let vm = SignUpZeroViewModel()
    
    let layoutView1 = UIView()
    let layoutView2 = UIView()
    
    let backBT = BackButton()
    
    let signUpLB = UILabel().then {
        let text = "멜리 서비스 이용을 위해\n동의가 필요해요"
        let attrString = NSMutableAttributedString(string: text)
        let font = UIFont(name: "Pretendard-Bold", size: 26)!
        let color = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attrString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
        attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attrString
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    let allBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "all_notSelect"), for: .normal)
    }
    
    let allLB = UILabel().then {
        $0.text = "모두 동의합니다"
        $0.font = UIFont(name: "Pretendard-Bold", size: 20)
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
    }
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.906, green: 0.93, blue: 0.954, alpha: 1)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
}

extension SignUpZeroViewController {
    
    func setUI() {
        self.view.backgroundColor = .white
        
        safeArea.addSubview(layoutView2)
        safeArea.addSubview(layoutView1)
        
        layoutView2.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        layoutView1.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(layoutView2.snp.top)
        }
        
        layoutView1.addSubview(backBT)
        backBT.snp.makeConstraints{
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(signUpLB)
        signUpLB.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(38)
        }
        
        layoutView1.addSubview(allBT)
        allBT.snp.makeConstraints {
            $0.top.equalTo(signUpLB.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(allLB)
        allLB.snp.makeConstraints {
            $0.top.equalTo(signUpLB.snp.bottom).offset(44)
            $0.leading.equalTo(allBT.snp.trailing).offset(18)
        }
        
        layoutView1.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(allBT.snp.bottom).offset(29)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(1)
        }
        
        
        
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        
    }
    
    func bindOutput() {
        
    }
    
}
