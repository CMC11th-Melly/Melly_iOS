//
//  SignUpViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/18.
//

import UIKit
import Then
import RxSwift
import RxCocoa

class SignUpOneViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    var vm = SignUpOneViewModel()
    
    let layoutView1 = UIView()
    let layoutView2 = UIView()
    
    let backBT = BackButton()
    
    let loginLabel = UILabel().then {
        $0.text = "회원가입"
        $0.font = UIFont.systemFont(ofSize: 26)
        $0.textColor = .black
    }
    
    let emailLabel = UILabel().then {
        $0.text = "아이디"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let emailTf = CustomTetField(title: "이메일 주소를 입력해주세요.")
    
    let pwLabel = UILabel().then {
        $0.text = "비밀번호"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
        
    }
    
    let pwTf = CustomTetField(title: "비밀번호를 입력해주세요.").then {
        $0.isSecureTextEntry = true
    }
    
    let pwCheckLabel = UILabel().then {
        $0.text = "비밀번호 확인"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
        
    }
    
    let pwCheckTf = CustomTetField(title: "비밀번호를 입력해주세요.").then {
        $0.isSecureTextEntry = true
    }
    
    let alertView = AlertLabel().then {
        $0.isHidden = true
    }
    
    let nextBT = CustomButton(title: "다음").then {
        $0.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension SignUpOneViewController {
    
    func setUI() {
        self.view.backgroundColor = .white
        
        safeArea.addSubview(layoutView2)
        safeArea.addSubview(layoutView1)
        layoutView2.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(130)
        }
        layoutView1.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(layoutView2.snp.top)
        }
        
        layoutView1.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo(22)
            $0.height.equalTo(20)
        }
        
        layoutView1.addSubview(loginLabel)
        loginLabel.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(56)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(emailLabel)
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(loginLabel.snp.bottom).offset(46)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(emailTf)
        emailTf.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        layoutView1.addSubview(pwLabel)
        pwLabel.snp.makeConstraints {
            $0.top.equalTo(emailTf.snp.bottom).offset(48)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(pwTf)
        pwTf.snp.makeConstraints {
            $0.top.equalTo(pwLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        layoutView1.addSubview(pwCheckLabel)
        pwCheckLabel.snp.makeConstraints {
            $0.top.equalTo(pwTf.snp.bottom).offset(48)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(pwCheckTf)
        pwCheckTf.snp.makeConstraints {
            $0.top.equalTo(pwCheckLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        
        layoutView2.addSubview(alertView)
        alertView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        layoutView2.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.top.equalTo(alertView.snp.bottom).offset(8)
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
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        emailTf.rx.controlEvent([.editingDidEnd])
            .map { self.emailTf.text ?? "" }
            .bind(to: vm.input.emailObserver)
            .disposed(by: disposeBag)
        
        pwTf.rx.controlEvent([.editingDidEnd])
            .map { self.pwTf.text ?? "" }
            .bind(to: vm.input.pwObserver)
            .disposed(by: disposeBag)
        
        pwCheckTf.rx.controlEvent([.editingDidEnd])
            .map { self.pwCheckTf.text ?? "" }
            .bind(to: vm.input.pwCheckObserver)
            .disposed(by: disposeBag)
        
        nextBT.rx.tap
            .bind(to: vm.input.nextObserver)
            .disposed(by: disposeBag)
    }
    
    func bindOutput() {
        
        vm.output.emailValid.asDriver(onErrorJustReturn: false).drive(onNext: { valid in
            
            if valid {
                self.alertView.isHidden = true
                self.alertView.labelView.text = ""
            } else {
                self.alertView.isHidden = false
                self.alertView.labelView.text = "아이디를 정확히 입력해주세요."
            }
            
        }).disposed(by: disposeBag)
        
        vm.output.pwValid.asDriver(onErrorJustReturn: false)
            .drive(onNext: { valid in
                
                if valid {
                    self.alertView.isHidden = true
                    self.alertView.labelView.text = ""
                } else {
                    self.alertView.isHidden = false
                    self.alertView.labelView.text = "비밀번호는 8자리 이상이여야합니다."
                }
                
            }).disposed(by: disposeBag)
        
        vm.output.pwCheckValid.asDriver(onErrorJustReturn: false)
            .drive(onNext: { valid in
                if valid {
                    self.alertView.isHidden = true
                    self.alertView.labelView.text = ""
                } else {
                    self.alertView.isHidden = false
                    self.alertView.labelView.text = "비밀번호가 일치하지 않습니다."
                }
            }).disposed(by: disposeBag)
        
        
        vm.output.nextValid.asDriver(onErrorJustReturn: false)
            .drive(onNext: { valid in
                if valid {
                    self.nextBT.isEnabled = true
                    self.nextBT.backgroundColor = .orange
                } else {
                    self.nextBT.isEnabled = false
                    self.nextBT.backgroundColor = .gray
                }
            }).disposed(by: disposeBag)
        
    }
    
    
}
