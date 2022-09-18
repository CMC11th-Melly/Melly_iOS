//
//  SignUpTwoViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/18.
//

import UIKit
import Then
import RxSwift
import RxCocoa

class SignUpTwoViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    var vm = SignUpOneViewModel()
    
    let layoutView1 = UIView()
    let layoutView2 = UIView()
    
    let backBT = BackButton()
    
    let signUpLabel = UILabel().then {
        $0.text = "MELLY에서\n사용할 이름은 무엇인가요?"
        $0.font = UIFont.systemFont(ofSize: 26)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    
    let nameTf = CustomTetField(title: "이름을 입력해주세요.")
    
    
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

extension SignUpTwoViewController {
    
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
        
        layoutView1.addSubview(signUpLabel)
        signUpLabel.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(56)
            $0.leading.equalToSuperview().offset(30)
        }
        
        
        layoutView1.addSubview(nameTf)
        nameTf.snp.makeConstraints {
            $0.top.equalTo(signUpLabel.snp.bottom).offset(62)
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
