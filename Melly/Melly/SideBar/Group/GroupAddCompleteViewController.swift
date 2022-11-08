//
//  GroupAddCompleteViewController.swift
//  Melly
//
//  Created by Jun on 2022/11/01.
//

import UIKit
import RxCocoa
import RxSwift
import FirebaseDynamicLinks

class GroupAddCompleteViewController: UIViewController {

    let group:Group
    
    private let disposeBag = DisposeBag()
    
    let headerView = UIView()
    
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
        $0.text = "새로운 그룹 생성 완료!"
    }
    
    let imgView = UIImageView(image: UIImage(named: "group_complete")).then {
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var groupTitleLB = UILabel().then {
        $0.text = "우리 오빠는 뭘까 그룹에\n새로운 멤버를 초대해보세요!"
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 21)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    let copyBT = DefaultButton("초대 링크 복사", true)
    
    let skipBT = UIButton(type: .custom).then {
        let string = "다음에 공유하기"
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-Medium", size: 16)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:   UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let rightLabel = RightAlert().then {
        $0.labelView.text = "링크 클립보드 복사"
        $0.alpha = 0
    }
    
    
    init(group: Group) {
        self.group = group
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


extension GroupAddCompleteViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        
        safeArea.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        
        headerView.addSubview(cancelBT)
        cancelBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(28)
        }
        
        safeArea.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(36)
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
            $0.centerX.equalToSuperview()
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
        
        safeArea.addSubview(rightLabel)
        rightLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        
    }
    
    private func bind() {
        
        cancelBT.rx.tap.subscribe(onNext: {
            self.navigationController?.popToRootViewController(animated: true)
        }).disposed(by: disposeBag)
        
        copyBT.rx.tap.asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                self.rightLabel.alpha = 1
                
                self.createDynamicLink()
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 1.5) {
                        self.rightLabel.alpha = 0
                    }
                }
            
        }).disposed(by: disposeBag)
        
        skipBT.rx.tap.subscribe(onNext: {
            self.navigationController?.popToRootViewController(animated: true)
        }).disposed(by: disposeBag)
        
        
        
    }
    
    func createDynamicLink() {
        let link = URL(string: "https://minjuling.notion.site/ff86bf42bbec40c4ac8dc8432c24f0c5?/groupId=\(group.groupId)&userId=\(User.loginedUser!.userSeq)")
        let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://cmc11th.page.link/invite_group")
        
        // iOS 설정
        referralLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.neordinary.CMC11th.Melly")
        referralLink?.iOSParameters?.minimumAppVersion = "1.0.0"
        referralLink?.iOSParameters?.appStoreID = "6444202109"
        referralLink?.iOSParameters?.customScheme = "invite_group"
        
        
        referralLink?.shorten { (shortURL, warnings, error) in
            if let shortURL = shortURL {
                let object = [shortURL]
                let activityVC = UIActivityViewController(activityItems: object, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
            
            
            
        }
    }
    
    
}
