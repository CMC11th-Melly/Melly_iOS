//
//  SettingViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/27.
//

import UIKit
import RxSwift
import RxCocoa


class SettingViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    let backBT = BackButton()
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.102, green: 0.118, blue: 0.153, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "설정"
    }
    
    let commentLB = UILabel().then {
        $0.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.text = "내가 선택한 항목만 알림을 받을 수 있어요"
    }
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let mainPushLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        $0.text = "앱 푸쉬"
    }
    
    lazy var mainPushSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        $0.isOn = true
    }

    let commentLikeLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        $0.text = "메모리 댓글 좋아요 수신"
    }
    
    lazy var commentLikeSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        $0.isOn = true
    }
    
    let commentPushLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        $0.text = "메모리 댓글 알림 수신"
    }
    
    lazy var commentPushSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        $0.isOn = true
    }
    
    let scrabPushLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        $0.text = "메모리 스크랩 알림 수신"
    }
    
    lazy var scrabPushSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        $0.isOn = true
    }
    
    let memoryPushLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        $0.text = "그룹원 메모리 기록 요청 알림 수신"
    }
    
    lazy var memoryPushSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        $0.isOn = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
        
    }
    
    
    
    
}

extension SettingViewController {
    
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
        
        safeArea.addSubview(commentLB)
        commentLB.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(commentLB.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-31)
            $0.height.equalTo(1)
        }
        
        safeArea.addSubview(mainPushLB)
        mainPushLB.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(23)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(29)
        }
        
        safeArea.addSubview(mainPushSwitch)
        mainPushSwitch.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(24)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(45)
            $0.height.equalTo(26)
        }
        
        safeArea.addSubview(commentLikeLB)
        commentLikeLB.snp.makeConstraints {
            $0.top.equalTo(mainPushLB.snp.bottom).offset(35)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(29)
        }
        
        safeArea.addSubview(commentLikeSwitch)
        commentLikeSwitch.snp.makeConstraints {
            $0.top.equalTo(mainPushSwitch.snp.bottom).offset(38)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(45)
            $0.height.equalTo(26)
        }
        
        safeArea.addSubview(commentPushLB)
        commentPushLB.snp.makeConstraints {
            $0.top.equalTo(commentLikeLB.snp.bottom).offset(35)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(29)
        }
        
        safeArea.addSubview(commentPushSwitch)
        commentPushSwitch.snp.makeConstraints {
            $0.top.equalTo(commentLikeSwitch.snp.bottom).offset(38)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(45)
            $0.height.equalTo(26)
        }
        
        safeArea.addSubview(scrabPushLB)
        scrabPushLB.snp.makeConstraints {
            $0.top.equalTo(commentPushLB.snp.bottom).offset(35)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(29)
        }
        
        safeArea.addSubview(scrabPushSwitch)
        scrabPushSwitch.snp.makeConstraints {
            $0.top.equalTo(commentPushSwitch.snp.bottom).offset(38)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(45)
            $0.height.equalTo(26)
        }
        
        safeArea.addSubview(memoryPushLB)
        memoryPushLB.snp.makeConstraints {
            $0.top.equalTo(scrabPushLB.snp.bottom).offset(35)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(29)
        }
        
        safeArea.addSubview(memoryPushSwitch)
        memoryPushSwitch.snp.makeConstraints {
            $0.top.equalTo(scrabPushSwitch.snp.bottom).offset(38)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(45)
            $0.height.equalTo(26)
        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        mainPushSwitch.rx.isOn
            .subscribe(onNext: { value in
                
                if value {
                    UIApplication.shared.unregisterForRemoteNotifications()
                } else {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }).disposed(by: disposeBag)
    
        
    }
    
    private func bindOutput() {
        
    }
    
    
}
