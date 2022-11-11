//
//  InviteGroupViewController.swift
//  Melly
//
//  Created by Jun on 2022/11/08.
//

import UIKit
import RxCocoa
import RxSwift

class InviteGroupViewController: UIViewController {

    let vm:InviteGroupViewModel
    
    private let disposeBag = DisposeBag()
    
    
    let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
    let contentView = UIView()
    
    let cancelBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_x"), for: .normal)
    }
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.059, green: 0.053, blue: 0.363, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 26)
        $0.text = "소피아님이 애인님을\n그룹에 초대하셨어요"
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let imgView = UIImageView(image: UIImage(named: "group_complete")).then {
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var groupTitleLB = UILabel().then {
        $0.text = "우리 오빠는 뭘까 그룹에\n새로운 멤버를 초대해보세요!"
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 21)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let copyBT = DefaultButton("초대 수락하기", true)
    
    let skipBT = UIButton(type: .custom).then {
        let string = "다음에 초대받을게요"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 16)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:   UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    init(vm: InviteGroupViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.initObserver.accept(())
    }

}

extension InviteGroupViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        
        safeArea.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(270)
        }
        
        contentView.addSubview(groupTitleLB)
        groupTitleLB.snp.makeConstraints {
            $0.top.equalTo(imgView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(64)
        }
        
        contentView.addSubview(copyBT)
        copyBT.snp.makeConstraints {
            $0.top.equalTo(groupTitleLB.snp.bottom).offset(59)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(skipBT)
        skipBT.snp.makeConstraints {
            $0.top.equalTo(copyBT.snp.bottom).offset(38)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(19)
            $0.bottom.equalToSuperview()
        }
        
        
    }
    
    private func bind() {
        UserDefaults.standard.setValue(nil, forKey: "InviteGroup")
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        skipBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        copyBT.rx.tap
            .bind(to: vm.input.inviteObserver)
            .disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        
        vm.output.errorValue.subscribe(onNext: { value in
            
            let alert = UIAlertController(title: "에러", message: value, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "확인", style: .cancel)
            
            alert.addAction(alertAction)
            self.present(alert, animated: true)
            
        }).disposed(by: disposeBag)
        
        vm.output.successValue
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.getInitial
            .subscribe(onNext: {value in
                
                self.setData(value: value)
                
            }).disposed(by: disposeBag)
        
    }
    
    private func setData(value: [String]) {
        
        if let user = User.loginedUser {
            
            titleLB.text =  "\(value[0])님이 \(user.nickname)님을\n그룹에 초대하셨어요"
            groupTitleLB.text = "\(value[1]) 그룹에\n새로운 멤버를 초대해보세요!"
            
        }
        
    }
    
}
