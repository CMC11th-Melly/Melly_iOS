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
    var vm:SignUpTwoViewModel

    let headerView = UIView()
    
    let bodyView = UIView()
    
    let bottomView = UIView()

    let backBT = BackButton()

    let signUpLabel = UILabel().then {
        $0.text = "MELLY에서\n사용할 이름은 무엇인가요?"
        $0.font = UIFont(name: "Pretendard-Bold", size: 26)
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }

    let nameTf = CustomTextField(title: "이름을 입력해주세요.")

    let alertView = AlertLabel().then {
        $0.isHidden = true
    }

    let nextBT = CustomButton(title: "다음").then {
        $0.isEnabled = false
    }

    init(vm: SignUpTwoViewModel) {
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension SignUpTwoViewController {

    func setUI() {
        self.view.backgroundColor = .white

        safeArea.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        
        headerView.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(27)
        }
        
        safeArea.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.snp.bottom)
            $0.height.equalTo(105)
        }
        
        bottomView.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        safeArea.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }


        bodyView.addSubview(signUpLabel)
        signUpLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.leading.equalToSuperview().offset(30)
        }


        bodyView.addSubview(nameTf)
        nameTf.snp.makeConstraints {
            $0.top.equalTo(signUpLabel.snp.bottom).offset(62)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }

        safeArea.addSubview(alertView)
        alertView.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top).offset(-10)
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
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)

        nameTf.textField.rx.controlEvent([.editingDidEnd])
            .map { self.nameTf.textField.text ?? "" }
            .bind(to: vm.input.nameObserver)
            .disposed(by: disposeBag)
        
        nextBT.rx.tap
            .bind(to: vm.input.nextObserver)
            .disposed(by: disposeBag)
    }

    func bindOutput() {

        vm.output.nameValid.asDriver(onErrorJustReturn: .serverError).drive(onNext: { valid in
            
            self.alertView.labelView.text = valid.rawValue
            
            switch valid {
            case .correct:
                self.alertView.isHidden = true
                self.nextBT.isEnabled = true
                self.nameTf.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
                self.nameTf.textField.textColor =  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
            default:
                self.alertView.isHidden = false
                self.nextBT.isEnabled = false
                self.nameTf.layer.borderColor = UIColor(red: 0.941, green: 0.259, blue: 0.322, alpha: 1).cgColor
                self.nameTf.textField.textColor = UIColor(red: 0.941, green: 0.259, blue: 0.322, alpha: 1)
            }

        }).disposed(by: disposeBag)

        vm.output.nextEvent.asSignal()
            .emit(onNext: { user in
                let vm = SignUpThreeViewModel(user)
                let vc = SignUpThreeViewController(vm: vm)
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)

    }


}
