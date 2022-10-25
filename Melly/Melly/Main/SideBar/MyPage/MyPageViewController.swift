//
//  MyPageViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/21.
//

import Foundation
import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import Photos
import PhotosUI

class MyPageViewController:UIViewController {
    
    private let disposeBag = DisposeBag()
    
    let backBT = BackButton()
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "마이페이지"
    }
    
    let imageView = UIImageView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    let nicknameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 26)
    }
    
    let emailLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12.6)
    }
    
    let revisedBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "go_profile"), for: .normal)
    }
    
    let oneSt = UIView().then {
        $0.backgroundColor = UIColor(red: 0.971, green: 0.977, blue: 0.983, alpha: 1)
    }
    
    let storeLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setData()
    }
    
}

extension MyPageViewController {
    
    private func setUI() {
        
        view.backgroundColor = .white
        
        safeArea.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(27)
        }
        
        safeArea.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalTo(backBT.snp.trailing).offset(12)
        }
        
        safeArea.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(43)
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(72)
        }
        
        safeArea.addSubview(nicknameLB)
        nicknameLB.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(50)
            $0.leading.equalTo(imageView.snp.trailing).offset(22)
        }
        
        safeArea.addSubview(emailLB)
        emailLB.snp.makeConstraints {
            $0.top.equalTo(nicknameLB.snp.bottom)
            $0.leading.equalTo(imageView.snp.trailing).offset(22)
        }
        
        safeArea.addSubview(revisedBT)
        revisedBT.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(titleLB.snp.bottom).offset(69)
        }
        
        safeArea.addSubview(oneSt)
        oneSt.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(17)
        }
        
        
    }
    
    private func bind() {
        
        backBT.rx.tap.subscribe(onNext: {
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        revisedBT.rx.tap .subscribe(onNext: {
            
            let vc = MyProfileViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }).disposed(by: disposeBag)
        
        
    }
    
    
    private func setData() {
        
        if let user = User.loginedUser {
            
            nicknameLB.text = user.nickname
            emailLB.text = user.email
            
            if let imageUrl = user.profileImage {
                
                let url = URL(string: imageUrl)!
                imageView.kf.setImage(with: url)
                
            }
            
        }
        
    }
    
    
}

