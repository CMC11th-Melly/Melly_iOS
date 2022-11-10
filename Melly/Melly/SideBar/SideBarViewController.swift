//
//  MainTabViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/11.
//

import Foundation
import UIKit
import Then
import Kingfisher
import RxSwift
import RxCocoa

class SideBarViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    let vm = ContainerViewModel.instance
    let contentView = UIView()
    
    let profileImage = UIImageView(image: UIImage(named: "profile")).then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    let userNameLb = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 26)
    }
    
    let myPageBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "right_arrow"), for: .normal)
    }
    
    let userSizeLB = UILabel().then {
        $0.textColor = UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 12.6)
        $0.text = "0.01mb / 10mb"
    }
    
    let separatorOne = UIView().then {
        $0.backgroundColor = UIColor(red: 0.906, green: 0.93, blue: 0.954, alpha: 1)
    }
    
    let memoryBT = UIButton(type: .custom).then {
        
        let string = "MY메모리"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 18)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let groupBT = UIButton(type: .custom).then {
        let string = "MY그룹"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 18)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let scrapBT = UIButton(type: .custom).then {
        let string = "스크랩"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 18)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    
    let separatorTwo = UIView().then {
        $0.backgroundColor = UIColor(red: 0.906, green: 0.93, blue: 0.954, alpha: 1)
    }
    
    let noticeBT = UIButton(type: .custom).then {
        let string = "공지사항"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 16)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:  UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
        
    }
    
    let pushBT = UIButton(type: .custom).then {
        let string = "알림"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 16)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:  UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
        
    }
    
    let settingBT = UIButton(type: .custom).then {
        let string = "설정"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 16)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:  UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let termsBT = UIButton(type: .custom).then {
        let string = "이용약관 및 정책"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 16)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:  UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let logoutBT = UIButton(type: .custom).then {
        let string = "로그아웃"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 16)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:  UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.volumeObserver.accept(())
        vm.input.getUserObserver.accept(())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.size.width, height: view.bounds.size.height)
    }
    
    
}

extension SideBarViewController {
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(contentView)
        
        contentView.addSubview(profileImage)
        profileImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(46)
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(50)
        }
        
        contentView.addSubview(userNameLb)
        userNameLb.snp.makeConstraints {
            $0.leading.equalTo(profileImage.snp.trailing).offset(15)
            $0.height.equalTo(38)
            $0.top.equalToSuperview().offset(41)
        }
        
        contentView.addSubview(myPageBT)
        myPageBT.snp.makeConstraints {
            $0.leading.equalTo(userNameLb.snp.trailing).offset(2)
            $0.top.equalToSuperview().offset(48)
        }
        
        contentView.addSubview(userSizeLB)
        userSizeLB.snp.makeConstraints {
            $0.top.equalTo(userNameLb.snp.bottom)
            $0.leading.equalTo(profileImage.snp.trailing).offset(15)
            $0.height.equalTo(18)
        }
        
        contentView.addSubview(separatorOne)
        separatorOne.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(42)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo(self.view.frame.size.width - 160)
            $0.height.equalTo(1)
        }
        
        contentView.addSubview(memoryBT)
        memoryBT.snp.makeConstraints {
            $0.top.equalTo(separatorOne.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(22)
        }
        
        contentView.addSubview(groupBT)
        groupBT.snp.makeConstraints {
            $0.top.equalTo(memoryBT.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(22)
        }
        
        contentView.addSubview(scrapBT)
        scrapBT.snp.makeConstraints {
            $0.top.equalTo(groupBT.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(22)
        }
        
        contentView.addSubview(separatorTwo)
        separatorTwo.snp.makeConstraints {
            $0.top.equalTo(scrapBT.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo(self.view.frame.size.width - 160)
            $0.height.equalTo(1)
        }
        
        contentView.addSubview(noticeBT)
        noticeBT.snp.makeConstraints {
            $0.top.equalTo(separatorTwo.snp.bottom).offset(36.5)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(19)
        }
        
        contentView.addSubview(pushBT)
        pushBT.snp.makeConstraints {
            $0.top.equalTo(noticeBT.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(19)
        }
        
        contentView.addSubview(settingBT)
        settingBT.snp.makeConstraints {
            $0.top.equalTo(pushBT.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(19)
        }
        
        contentView.addSubview(termsBT)
        termsBT.snp.makeConstraints {
            $0.top.equalTo(settingBT.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(19)
        }
        
        contentView.addSubview(logoutBT)
        logoutBT.snp.makeConstraints {
            $0.top.equalTo(termsBT.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(19)
        }
    }
    
    private func setData() {
        if let user = User.loginedUser {
            userNameLb.text = user.nickname
            if let image = user.profileImage {
                let url = URL(string: image)!
                profileImage.kf.setImage(with: url)
            }
            
        }
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindOutput() {
        
        vm.output.volumeValue.asDriver(onErrorJustReturn: "")
            .drive(onNext: { value in
                self.userSizeLB.text = "\(value) / 3GB"
            }).disposed(by: disposeBag)
        
        vm.output.userValue.asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                self.setData()
            }).disposed(by: disposeBag)
        
        
    }
    
    private func bindInput() {
        
        myPageBT.rx.tap.subscribe(onNext: {
            
            let vc = MyPageViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }).disposed(by: disposeBag)
        
        memoryBT.rx.tap.subscribe(onNext: {
            let vc = MyMemoryViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }).disposed(by: disposeBag)
        
        groupBT.rx.tap.subscribe(onNext: {
            let vc = GroupViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalTransitionStyle = .crossDissolve
            nav.modalPresentationStyle = .fullScreen
            nav.isNavigationBarHidden = true
            self.present(nav, animated: true)
        }).disposed(by: disposeBag)
        
        scrapBT.rx.tap.subscribe(onNext: {
            let vc = MyScrapViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalTransitionStyle = .crossDissolve
            nav.modalPresentationStyle = .fullScreen
            nav.isNavigationBarHidden = true
            self.present(nav, animated: true)
        }).disposed(by: disposeBag)
        
        noticeBT.rx.tap.subscribe(onNext: {
            if let url = URL(string: "https://minjuling.notion.site/1aae3484826f4e64a831e623a6a905d6") {
                UIApplication.shared.open(url)
            }
        }).disposed(by: disposeBag)
        
        pushBT.rx.tap.subscribe(onNext: {
            let vc = NoticeViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }).disposed(by: disposeBag)
        
        settingBT.rx.tap.subscribe(onNext: {
            let vc = SettingViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }).disposed(by: disposeBag)
        
        termsBT.rx.tap.subscribe(onNext: {
            if let url = URL(string: "https://minjuling.notion.site/ff86bf42bbec40c4ac8dc8432c24f0c5") {
                UIApplication.shared.open(url)
            }
        }).disposed(by: disposeBag)
        
        logoutBT.rx.tap.subscribe(onNext: {
            
            let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.vm.input.logoutObserver.accept(())
            }
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true)
            
        }).disposed(by: disposeBag)
        
    }
    
    
    
    
    
}
