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
    var vm:SignUpOneViewModel
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.layoutIfNeeded()
    }
    let contentView = UIView()
    
    let backBT = BackButton()
    
    let loginLabel = UILabel().then {
        $0.text = "회원가입"
        $0.font =  UIFont(name: "Pretendard-Bold", size: 26)
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
    }
    
    let emailLabel = UILabel().then {
        $0.text = "이메일 *"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
    }
    
    let emailTf = CustomTextField(title: "이메일 주소를 입력해주세요.")
    
    let pwLabel = UILabel().then {
        $0.text = "비밀번호 *"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
    }
    
    let pwTf = CustomTextField(title: "비밀번호를 입력해주세요.", isSecure: true)
    
    let pwCheckLabel = UILabel().then {
        $0.text = "비밀번호 확인 *"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
    }
    
    let pwCheckTf = CustomTextField(title: "비밀번호를 입력해주세요.", isSecure: true)
    
    let alertView = AlertLabel().then {
        $0.isHidden = true
    }
    
    let nextBT = CustomButton(title: "다음").then {
        $0.isEnabled = false
    }
    
    init(vm: SignUpOneViewModel) {
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
        setSV()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension SignUpOneViewController: UIScrollViewDelegate {
    
    func setUI() {
        self.view.backgroundColor = .white
        scrollView.delegate = self
        safeArea.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo(22)
            $0.height.equalTo(20)
        }
        
        contentView.addSubview(loginLabel)
        loginLabel.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(56)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(emailLabel)
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(loginLabel.snp.bottom).offset(46)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(emailTf)
        emailTf.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(pwLabel)
        pwLabel.snp.makeConstraints {
            $0.top.equalTo(emailTf.snp.bottom).offset(48)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(pwTf)
        pwTf.snp.makeConstraints {
            $0.top.equalTo(pwLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(pwCheckLabel)
        pwCheckLabel.snp.makeConstraints {
            $0.top.equalTo(pwTf.snp.bottom).offset(48)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(pwCheckTf)
        pwCheckTf.snp.makeConstraints {
            $0.top.equalTo(pwCheckLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        
        contentView.addSubview(alertView)
        alertView.snp.makeConstraints {
            $0.top.equalTo(pwCheckTf.snp.bottom).offset(129)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.top.equalTo(alertView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview()
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
        
        vm.output.emailValid.asDriver(onErrorJustReturn: .notAvailable).drive(onNext: { valid in
            self.alertView.labelView.text = valid.rawValue
            switch valid {
            case .correct:
                self.alertView.isHidden = true
            default:
                self.alertView.isHidden = false
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
        
        vm.output.userValue.asSignal()
            .emit(onNext: { user in
                let vm = SignUpTwoViewModel(user)
                let vc = SignUpTwoViewController(vm: vm)
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    func setSV() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapMethod))
        
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        
        singleTapGestureRecognizer.isEnabled = true
        
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidShow(notification:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidHide(notification:)),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func myTapMethod(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: Methods to manage keybaord
    @objc func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo
        let keyBoardSize = info![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            self.view.endEditing(true)
    }
    
}
