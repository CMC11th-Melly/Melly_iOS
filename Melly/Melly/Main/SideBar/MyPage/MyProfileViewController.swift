//
//  MyProfileViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/23.
//

import UIKit
import RxCocoa
import RxSwift

class MyProfileViewController: UIViewController {

    private let disposeBag = DisposeBag()
    let backBT = BackButton()
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "프로필"
    }
    
    let editBT = UIButton(type: .custom).then {
        let string = "편집"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 18)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let profileImgView = UIImageView()
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
    }
    
    let profileLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        $0.text = "기본 정보"
    }
    
    let nameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.text = "닉네임"
    }
    
    let nameValueLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let genderLB = UILabel().then {
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.text = "성별"
    }
    
    let genderValueLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let ageLB = UILabel().then {
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.text = "연령"
    }
    
    let ageValueLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        bind()
    }
    

    

}

extension MyProfileViewController {
    
    private func setUI() {
        safeArea.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalTo(backBT.snp.trailing).offset(12)
        }
        
        safeArea.addSubview(editBT)
        editBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        safeArea.addSubview(profileImgView)
        profileImgView.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(73)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(141)
        }
        
        safeArea.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(profileImgView.snp.bottom).offset(23)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(12)
        }
        
        safeArea.addSubview(profileLB)
        profileLB.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(41)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(nameLB)
        nameLB.snp.makeConstraints {
            $0.top.equalTo(profileLB.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(nameValueLB)
        nameValueLB.snp.makeConstraints {
            $0.top.equalTo(profileLB.snp.bottom).offset(28)
            $0.leading.equalTo(nameLB.snp.trailing).offset(19)
        }
        
        safeArea.addSubview(genderLB)
        genderLB.snp.makeConstraints {
            $0.top.equalTo(nameLB.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(genderValueLB)
        genderValueLB.snp.makeConstraints {
            $0.top.equalTo(nameValueLB.snp.bottom).offset(30)
            $0.leading.equalTo(genderLB.snp.trailing).offset(19)
        }
        
        safeArea.addSubview(ageLB)
        ageLB.snp.makeConstraints {
            $0.top.equalTo(genderLB.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(ageValueLB)
        ageValueLB.snp.makeConstraints {
            $0.top.equalTo(genderValueLB.snp.bottom).offset(30)
            $0.leading.equalTo(ageLB.snp.trailing).offset(19)
        }
        
        
    }
    
    private func bind() {
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        editBT.rx.tap
            .subscribe(onNext: {
                let vc = ProfileEditViewController()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    
}
