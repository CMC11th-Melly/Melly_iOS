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
    let vm:SignUpZeroViewModel
    
    
    let layoutView1 = UIView()
    let layoutView2 = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
    let contentView = UIView()
    
    let layoutView3 = UIView()
    
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
        $0.textAlignment = .left
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
    
    let subOneView = TermsNAgreeView("이용약관 (필수)")
    
    let subOneTextView = UITextView().then {
        $0.text = TermsandConditions
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 12)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        $0.isHidden = true
    }
    
    let subTwoView = TermsNAgreeView("개인정보 수집 및 이용 동의 (필수)")
    
    let subTwoTextView = UITextView().then {
        $0.text = CollectPersonalInformation
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 12)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        $0.isHidden = true
    }
    
    let subThreeView = TermsNAgreeView("위치기반 서비스 이용약관 (필수)")
    
    let subThreeTextView = UITextView().then {
        $0.text = LocationTerm
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 12)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        $0.isHidden = true
    }
    
    let nextBT = CustomButton(title: "완료").then {
        $0.isEnabled = false
    }
    
    init(vm: SignUpZeroViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
}

extension SignUpZeroViewController {
    
    func setUI() {
        self.view.backgroundColor = .white
        
        safeArea.addSubview(layoutView2)
        safeArea.addSubview(layoutView1)
        safeArea.addSubview(layoutView3)
        
        layoutView3.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        layoutView1.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(250)
        }
        
        layoutView2.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(layoutView1.snp.bottom)
            $0.bottom.equalTo(layoutView3.snp.top)
        }
        
        layoutView1.addSubview(backBT)
        backBT.snp.makeConstraints{
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(signUpLB)
        signUpLB.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(38)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(allBT)
        allBT.snp.makeConstraints {
            $0.top.equalTo(signUpLB.snp.bottom).offset(39)
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
        
        layoutView2.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(subOneView)
        subOneView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(safeArea.snp.trailing).offset(-30)
            $0.height.equalTo(34)
        }
        
        contentView.addSubview(subOneTextView)
        
        contentView.addSubview(subTwoView)
        subTwoView.snp.makeConstraints {
            $0.top.equalTo(subOneView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(safeArea.snp.trailing).offset(-30)
            $0.height.equalTo(34)
        }
        
        contentView.addSubview(subTwoTextView)
        
        contentView.addSubview(subThreeView)
        subThreeView.snp.makeConstraints {
            $0.top.equalTo(subTwoView.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(safeArea.snp.trailing).offset(-30)
            $0.height.equalTo(34)
        }
        
        contentView.addSubview(subThreeTextView)
        subThreeTextView.snp.makeConstraints {
            $0.top.equalTo(subThreeView.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(safeArea.snp.trailing).offset(-30)
            $0.height.equalTo(122)
            $0.bottom.equalToSuperview()
        }
        
        
        
        layoutView3.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        
        
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        allBT.rx.tap
            .bind(to: vm.input.allObserver)
            .disposed(by: disposeBag)
        
        subOneView.subOneBT.rx.tap
            .map { 0 }
            .bind(to: vm.input.oneObserver)
            .disposed(by: disposeBag)
        
        subOneView.subOneSlideBT.rx.tap
            .subscribe(onNext: {
                
                self.subOneTextView.isHidden.toggle()
                
                if self.subOneTextView.isHidden {
                    self.subOneView.subOneSlideBT.setImage(UIImage(named: "close_terms"), for: .normal)
                    
                    UIView.animate(withDuration: 0.5) {
                        self.subTwoView.snp.remakeConstraints {
                            $0.top.equalTo(self.subOneView.snp.bottom).offset(16)
                            $0.leading.equalToSuperview().offset(30)
                            $0.trailing.equalTo(self.safeArea.snp.trailing).offset(-30)
                            $0.height.equalTo(34)
                        }
                    }
                    
                } else {
                    self.subOneView.subOneSlideBT.setImage(UIImage(named: "open_terms"), for: .normal)
                    
                    UIView.animate(withDuration: 0.5) {
                        self.subOneTextView.snp.remakeConstraints {
                            $0.top.equalTo(self.subOneView.snp.bottom).offset(16)
                            $0.leading.equalToSuperview().offset(30)
                            $0.trailing.equalTo(self.safeArea.snp.trailing).offset(-30)
                            $0.height.equalTo(122)
                        }
                        
                        self.subTwoView.snp.remakeConstraints {
                            $0.top.equalTo(self.subOneTextView.snp.bottom).offset(16)
                            $0.leading.equalToSuperview().offset(30)
                            $0.trailing.equalTo(self.safeArea.snp.trailing).offset(-30)
                            $0.height.equalTo(34)
                        }
                    }
                    
                    
                }
                
            }).disposed(by: disposeBag)
        
        subTwoView.subOneBT.rx.tap
            .map { 1 }
            .bind(to: vm.input.twoObserver)
            .disposed(by: disposeBag)
        
        subTwoView.subOneSlideBT.rx.tap
            .subscribe(onNext: {
                self.subTwoTextView.isHidden.toggle()
                
                if self.subTwoTextView.isHidden {
                    self.subTwoView.subOneSlideBT.setImage(UIImage(named: "close_terms"), for: .normal)
                    
                    UIView.animate(withDuration: 0.5) {
                        self.subThreeView.snp.remakeConstraints {
                            $0.top.equalTo(self.subTwoView.snp.bottom).offset(16)
                            $0.leading.equalToSuperview().offset(30)
                            $0.trailing.equalTo(self.safeArea.snp.trailing).offset(-30)
                            $0.height.equalTo(34)
                        }
                    }
                    
                } else {
                    self.subTwoView.subOneSlideBT.setImage(UIImage(named: "open_terms"), for: .normal)
                    
                    UIView.animate(withDuration: 0.5) {
                        self.subTwoTextView.snp.remakeConstraints {
                            $0.top.equalTo(self.subTwoView.snp.bottom).offset(16)
                            $0.leading.equalToSuperview().offset(30)
                            $0.trailing.equalTo(self.safeArea.snp.trailing).offset(-30)
                            $0.height.equalTo(122)
                        }
                        
                        self.subThreeView.snp.remakeConstraints {
                            $0.top.equalTo(self.subTwoTextView.snp.bottom).offset(16)
                            $0.leading.equalToSuperview().offset(30)
                            $0.trailing.equalTo(self.safeArea.snp.trailing).offset(-30)
                            $0.height.equalTo(34)
                        }
                    }
                    
                    
                }
            }).disposed(by: disposeBag)
        
        subThreeView.subOneBT.rx.tap
            .map { 2 }
            .bind(to: vm.input.threeObserver)
            .disposed(by: disposeBag)
        
        subThreeView.subOneSlideBT.rx.tap
            .subscribe(onNext: {
                self.subThreeTextView.isHidden.toggle()
                
                if self.subThreeTextView.isHidden {
                    self.subThreeView.subOneSlideBT.setImage(UIImage(named: "close_terms"), for: .normal)
                    
                } else {
                    self.subThreeView.subOneSlideBT.setImage(UIImage(named: "open_terms"), for: .normal)
                    
                    UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.2, options: .curveEaseIn) {
                        self.subThreeTextView.snp.remakeConstraints {
                            $0.top.equalTo(self.subThreeView.snp.bottom).offset(16)
                            $0.leading.equalToSuperview().offset(30)
                            $0.trailing.equalTo(self.safeArea.snp.trailing).offset(-30)
                            $0.height.equalTo(122)
                            $0.bottom.equalToSuperview()
                        }
        
                    }
                    
                    
                }
            }).disposed(by: disposeBag)
        
        nextBT.rx.tap
            .bind(to: vm.input.nextObserver)
            .disposed(by: disposeBag)
        
        
    }
    
    func bindOutput() {
        
        vm.output.allValue.asDriver(onErrorJustReturn: false)
            .drive(onNext: { value in
                if value {
                    self.allBT.setImage(UIImage(named: "all_select"), for: .normal)
                    self.nextBT.isEnabled = true
                } else {
                    self.allBT.setImage(UIImage(named: "all_notSelect"), for: .normal)
                    self.nextBT.isEnabled = false
                }
            }).disposed(by: disposeBag)
        
        vm.output.subValue.asDriver(onErrorJustReturn: [false, false, false])
            .drive(onNext: { value in
                
                if value[0] {
                    self.subOneView.subOneBT.setImage(UIImage(named: "agree_terms"), for: .normal)
                } else {
                    self.subOneView.subOneBT.setImage(UIImage(named: "disagree_terms"), for: .normal)
                }
                
                if value[1] {
                    self.subTwoView.subOneBT.setImage(UIImage(named: "agree_terms"), for: .normal)
                } else {
                    self.subTwoView.subOneBT.setImage(UIImage(named: "disagree_terms"), for: .normal)
                }
                
                if value[2] {
                    self.subThreeView.subOneBT.setImage(UIImage(named: "agree_terms"), for: .normal)
                } else {
                    self.subThreeView.subOneBT.setImage(UIImage(named: "disagree_terms"), for: .normal)
                }
                
            }).disposed(by: disposeBag)
        
        
        vm.output.nextValue.asDriver(onErrorJustReturn: false)
            .drive(onNext: { value in
                if value {
                    let vm = SignUpOneViewModel(self.vm.user)
                    let vc = SignUpOneViewController(vm: vm)
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vm = SignUpTwoViewModel(self.vm.user)
                    let vc = SignUpTwoViewController(vm: vm)
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }).disposed(by: disposeBag)
        
    }
    
}
