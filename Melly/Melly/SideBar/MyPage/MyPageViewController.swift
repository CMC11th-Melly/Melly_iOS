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
    let vm = MyPageViewModel.instance
    
    let backBT = BackButton()
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.102, green: 0.118, blue: 0.153, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "마이페이지"
    }
    
    let withDrawBT = UIButton(type: .custom).then {
        let string = "탈퇴"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 18)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let imageView = UIImageView(image: UIImage(named: "profile")).then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.contentMode = .scaleAspectFill
    }
    
    let nicknameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 26)
    }
    
    let emailLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12.6)
    }
    
    let revisedBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "go_profile"), for: .normal)
    }
    
    let oneSt = UIView().then {
        $0.backgroundColor = UIColor(red: 0.971, green: 0.977, blue: 0.983, alpha: 1)
    }
    
    let storeLB = UILabel().then {
        $0.text = "저장 용량"
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
    }
    
    let storeView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        $0.layer.cornerRadius = 12
    }
    
    let storeText = UILabel().then {
        let string = "0.01mb / 10mb"
        let attributedString = NSMutableAttributedString(string: string)
        let font =  UIFont(name: "Pretendard-SemiBold", size: 16)!
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.attributedText = attributedString
    }
    
    let progressView = UIProgressView().then {
        $0.trackTintColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
        $0.progressTintColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        $0.layer.cornerRadius = 12
    }
    
    let couponLB = UILabel().then {
        $0.text = "무료 이용권 사용 중"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
    }
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
    }
    
    let currentStoreLB = UILabel().then {
        $0.text = "남은 용량 9.09mb"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
        setNC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        vm.input.initialObserver.accept(())
        vm.input.volumeObserver.accept(())

    }
    
}

extension MyPageViewController {
    
    func setNC() {
        NotificationCenter.default.addObserver(self, selector: #selector(goToInviteGroup), name: NSNotification.InviteGroupNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(shareMemory), name: NSNotification.MemoryShareNotification, object: nil)
    }
    
    @objc func goToInviteGroup(_ notification: Notification) {
        
        if let value = notification.object as? [String] {
            let vm = InviteGroupViewModel(userId: value[1], groupId: value[0])
            let vc = InviteGroupViewController(vm: vm)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        
    }
    
    @objc func shareMemory(_ notification:Notification) {
        
        if let memoryId = notification.object as? String {
            
            ShareMemoryViewModel.getMemory(memoryId)
                .subscribe(onNext: { value in
                    
                    if let error = value.error {
                        self.vm.output.errorValue.accept(error.msg)
                    } else if let memory = value.success as? Memory {
                        let vm = MemoryDetailViewModel(memory)
                        let vc = MemoryDetailViewController(vm: vm)
                        vc.modalTransitionStyle = .coverVertical
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                        
                    }
                    
                }).disposed(by: disposeBag)
            
        }
        
    }
    
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
        
        safeArea.addSubview(withDrawBT)
        withDrawBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.trailing.equalToSuperview().offset(-34)
            $0.height.equalTo(29)
            
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
        
        safeArea.addSubview(storeLB)
        storeLB.snp.makeConstraints {
            $0.top.equalTo(oneSt.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(storeView)
        storeView.snp.makeConstraints {
            $0.top.equalTo(storeLB.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(100)
        }
        
        storeView.addSubview(storeText)
        storeText.snp.makeConstraints{
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(18)
        }
        
        storeView.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.top.equalTo(storeText.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().offset(-18)
            $0.height.equalTo(8)
        }
        
        storeView.addSubview(couponLB)
        couponLB.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(18)
        }
        
        storeView.addSubview(separator)
        separator.snp.makeConstraints{
            $0.top.equalTo(progressView.snp.bottom).offset(17)
            $0.leading.equalTo(couponLB.snp.trailing).offset(8)
            $0.width.equalTo(1)
            $0.height.equalTo(12)
        }
        
        storeView.addSubview(currentStoreLB)
        currentStoreLB.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(14)
            $0.leading.equalTo(separator.snp.trailing).offset(8)
        }
        
        
    }
    
    private func bind() {
        
        backBT.rx.tap.subscribe(onNext: {
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        revisedBT.rx.tap.subscribe(onNext: {
            
            let vc = MyProfileViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }).disposed(by: disposeBag)
        
        withDrawBT.rx.tap
            .subscribe(onNext: {
                
                let alert = UIAlertController(title: "정말 탈퇴 하시겠어요?", message: "탈퇴하면 멜리의 추억이 모두 사라집니다.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                    self.vm.input.withdrawObserver.accept(())
                }
                
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true)
                
            }).disposed(by: disposeBag)
        
        vm.output.volumeValue.asDriver(onErrorJustReturn: 0)
            .drive(onNext: { value in
                DispatchQueue.main.async {
                    let volume = Float(value) / Float(1.0737e+9 * 3)
                    self.progressView.setProgress(volume, animated: true)
                    
                    let currentSize = "\(String.formatSize(fileSize: value)) / 3GB"
                    let attributedString = NSMutableAttributedString(string: currentSize)
                    let font =  UIFont(name: "Pretendard-SemiBold", size: 16)!
                    attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: currentSize.count))
                    attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1), range: NSRange(location: 0, length: currentSize.count))
                    attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1), range: (currentSize as NSString).range(of: "\(String.formatSize(fileSize: value))"))
                    self.storeText.attributedText = attributedString
                    
                    let lastSize = String.formatSize(fileSize: Int(1.0737e+9 * 3) - value)
                    self.currentStoreLB.text = "남은 용량 \(lastSize)"
                }
            }).disposed(by: disposeBag)
        
        vm.output.reloadValue.subscribe(onNext: {
            self.setData()
        }).disposed(by: disposeBag)
        
    }
    
    
    private func setData() {
        
        if let user = User.loginedUser {
            
            nicknameLB.text = user.nickname
            emailLB.text = user.email
            
            if let imageUrl = user.profileImage {
                
                let url = URL(string: imageUrl)!
                imageView.kf.setImage(with: url)
                
            } else {
                imageView.image = UIImage(named: "profile")
            }
            
            
            
        }
        
    }
    
    
}

