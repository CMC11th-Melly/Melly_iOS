//
//  GroupDetailViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/28.
//

import UIKit
import RxCocoa
import RxSwift

class GroupDetailViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    let vm = GroupViewModel.instance
    
    let headerView = UIView()
    let backBT = BackButton()
    let editBT = UIButton(type: .custom).then {
        let string = "편집"
        let attributedString = NSMutableAttributedString(string: string)
        let font = UIFont(name: "Pretendard-SemiBold", size: 18)!
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let bodyView = UIView()
    
    
    
    
    let bottomView = UIView()
    let saveBT = CustomButton(title: "이 그룹이 쓴 메모리 보기")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
        
    }
    

   

}

extension GroupDetailViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        
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
        
        headerView.addSubview(editBT)
        editBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.trailing.equalToSuperview().offset(-34)
            $0.height.equalTo(29)
        }
        
        safeArea.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        
        bottomView.addSubview(saveBT)
        saveBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.trailing.equalToSuperview().offset(-30)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(56)
        }
        
        safeArea.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.bottom.equalTo(bottomView.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        
        
    }
    
    private func bind() {
        
    }
    
    
    
    
}
