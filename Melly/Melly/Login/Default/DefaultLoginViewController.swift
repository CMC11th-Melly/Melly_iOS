//
//  DefaultLoginViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/14.
//

import UIKit
import Then
import RxSwift
import RxCocoa

class DefaultLoginViewController: UIViewController {

    private var disposeBag = DisposeBag()
    var vm = DefaultLoginViewModel()
    
    let layoutView1 = UIView()
    let layoutView2 = UIView()
    
    let backBT = BackButton()
    
    let loginLabel = UILabel().then {
        $0.text = "로그인"
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
    
    let findEmailBT = UIButton(type: .custom).then {
        $0.setTitle("아이디 찾기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    let separator = UIView().then {
        $0.backgroundColor = .gray
    }
    
    let findPwBT = UIButton(type: .custom).then {
        $0.setTitle("비밀번호 찾기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    let alertView = AlertLabel().then {
        $0.isHidden = true
    }
    
    let loginBT = CustomButton(title: "로그인").then {
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

extension DefaultLoginViewController {
    
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
        
        layoutView1.addSubview(separator)
        separator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(pwTf.snp.bottom).offset(76)
            $0.width.equalTo(2)
            $0.height.equalTo(12)
        }
        
        layoutView1.addSubview(findEmailBT)
        findEmailBT.snp.makeConstraints {
            $0.top.equalTo(pwTf.snp.bottom).offset(67)
            $0.trailing.equalTo(separator.snp.leading).offset(-13)
        }
        
        layoutView1.addSubview(findPwBT)
        findPwBT.snp.makeConstraints {
            $0.top.equalTo(pwTf.snp.bottom).offset(67)
            $0.leading.equalTo(separator.snp.trailing).offset(13)
        }
        
        layoutView2.addSubview(alertView)
        alertView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        layoutView2.addSubview(loginBT)
        loginBT.snp.makeConstraints {
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
        
        loginBT.rx.tap
            .bind(to: vm.input.loginObserver)
            .disposed(by: disposeBag)
    }
    
    func bindOutput() {
        
        vm.output.emailValid.asDriver(onErrorJustReturn: false).drive(onNext: { valid in
            
            DispatchQueue.main.async {
                if valid {
                    self.alertView.isHidden = true
                    self.alertView.labelView.text = ""
                } else {
                    self.alertView.isHidden = false
                    self.alertView.labelView.text = "아이디를 정확히 입력해주세요."
                }
            }
            
        }).disposed(by: disposeBag)
        
        vm.output.pwValid.asDriver(onErrorJustReturn: false)
            .drive(onNext: { valid in
            
            DispatchQueue.main.async {
                if valid {
                    self.alertView.isHidden = true
                    self.alertView.labelView.text = ""
                } else {
                    self.alertView.isHidden = false
                    self.alertView.labelView.text = "비밀번호를 정확히 입력해주세요."
                }
            }
            
        }).disposed(by: disposeBag)
        
        vm.output.loginValid.asDriver(onErrorJustReturn: false)
            .drive(onNext: { valid in
                if valid {
                    self.loginBT.isEnabled = true
                    self.loginBT.backgroundColor = .orange
                } else {
                    self.loginBT.isEnabled = false
                    self.loginBT.backgroundColor = .gray
                }
            }).disposed(by: disposeBag)
        
    }
    
    
}
