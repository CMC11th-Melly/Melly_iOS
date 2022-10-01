//
//  MainTabViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/11.
//

import Foundation
import UIKit
import Then

class SideBarViewController: UIViewController {

    
    
    
    
    let contentView = UIView()
    
    let profileImage = UIImageView(image: UIImage(named: "profile")).then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    let userNameLb = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 26)
        $0.text = "소피아"
    }
    
    let myPageBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "right_arrow"), for: .normal)
    }
    
    let userSizeLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 12.6)
        $0.text = "0.01mb / 10mb"
    }
    
    let separatorOne = UIView().then {
        $0.backgroundColor = UIColor(red: 0.906, green: 0.93, blue: 0.954, alpha: 1)
    }
    
    let memoryBT = UIButton(type: .custom).then {
        $0.setTitle("MY메모리", for: .normal)
        $0.titleLabel?.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 18)
    }
    
    let groupBT = UIButton(type: .custom).then {
        $0.setTitle("MY그룹", for: .normal)
        $0.titleLabel?.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 18)
    }
    
    let scrapBT = UIButton(type: .custom).then {
        $0.setTitle("스크랩", for: .normal)
        $0.titleLabel?.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 18)
    }
    
    
    let separatorTwo = UIView().then {
        $0.backgroundColor = UIColor(red: 0.906, green: 0.93, blue: 0.954, alpha: 1)
    }
    
    let noticeBT = UIButton(type: .custom).then {
        $0.setTitle("공지사항", for: .normal)
        $0.titleLabel?.textColor = UIColor(red: 0.49, green: 0.519, blue: 0.554, alpha: 1)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    let settingBT = UIButton(type: .custom).then {
        $0.setTitle("설정", for: .normal)
        $0.titleLabel?.textColor = UIColor(red: 0.49, green: 0.519, blue: 0.554, alpha: 1)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    let termsBT = UIButton(type: .custom).then {
        $0.setTitle("이용약관 및 정책", for: .normal)
        $0.titleLabel?.textColor = UIColor(red: 0.49, green: 0.519, blue: 0.554, alpha: 1)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    let logoutBT = UIButton(type: .custom).then {
        $0.setTitle("로그아웃", for: .normal)
        $0.titleLabel?.textColor = UIColor(red: 0.49, green: 0.519, blue: 0.554, alpha: 1)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.size.width, height: view.bounds.size.height)
    }
    
    
}

extension SideBarViewController {
    func setUI() {
        view.backgroundColor = .white
        view.addSubview(contentView)
        
        contentView.addSubview(profileImage)
        profileImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(76)
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(50)
        }
        
        contentView.addSubview(userNameLb)
        userNameLb.snp.makeConstraints {
            $0.leading.equalTo(profileImage.snp.trailing).offset(15)
            $0.top.equalToSuperview().offset(71)
        }
        
        contentView.addSubview(myPageBT)
        myPageBT.snp.makeConstraints {
            $0.leading.equalTo(userNameLb.snp.trailing).offset(2)
            $0.top.equalToSuperview().offset(78)
        }
        
        contentView.addSubview(userSizeLB)
        userSizeLB.snp.makeConstraints {
            $0.top.equalTo(userNameLb.snp.bottom)
            $0.leading.equalTo(profileImage.snp.trailing).offset(15)
        }
        
        contentView.addSubview(separatorOne)
        separatorOne.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(42)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(1)
        }
        
        contentView.addSubview(memoryBT)
        memoryBT.snp.makeConstraints {
            $0.top.equalTo(separatorOne.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(groupBT)
        groupBT.snp.makeConstraints {
            $0.top.equalTo(memoryBT.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(scrapBT)
        scrapBT.snp.makeConstraints {
            $0.top.equalTo(groupBT.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(separatorTwo)
        separatorTwo.snp.makeConstraints {
            $0.top.equalTo(scrapBT.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(1)
        }
        
        contentView.addSubview(noticeBT)
        noticeBT.snp.makeConstraints {
            $0.top.equalTo(separatorTwo.snp.bottom).offset(36.5)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(settingBT)
        settingBT.snp.makeConstraints {
            $0.top.equalTo(noticeBT.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(termsBT)
        termsBT.snp.makeConstraints {
            $0.top.equalTo(settingBT.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(logoutBT)
        logoutBT.snp.makeConstraints {
            $0.top.equalTo(termsBT.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
        }
    }
}
