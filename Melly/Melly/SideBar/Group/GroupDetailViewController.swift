//
//  GroupDetailViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/28.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher
import FirebaseDynamicLinks

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
    
    let groupLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.text = "그룹명"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    lazy var groupImageView = UIImageView().then {
        if let group = vm.group {
            $0.image = UIImage(named: "group_icon_\(group.groupIcon)")
        }
    }
    
    lazy var groupNameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.text = vm.group?.groupName
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 22)
    }
    
    let stOne = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let memberLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.text = "멤버"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let memberAddBT = UIButton(type: .custom).then {
        let string = "+ 멤버추가"
        let attributedString = NSMutableAttributedString(string: string)
        let font = UIFont(name: "Pretendard-Medium", size: 14)!
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let memberCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = true
        collectionView.allowsMultipleSelection = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let stTwo = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let categoryLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.text = "카테고리"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let categoryNameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.984, alpha: 1)
        $0.layer.cornerRadius = 10
        $0.textAlignment = .center
        $0.clipsToBounds = true
    }
    
    
    let bottomView = UIView()
    
    let saveBT = CustomButton(title: "이 그룹이 쓴 메모리 보기").then {
        $0.isEnabled = true
    }
    
    let rightLabel = RightAlert().then {
        $0.labelView.text = "메모리 수정 완료"
        $0.alpha = 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let group = vm.group {
            groupImageView.image = UIImage(named: "group_icon_\(group.groupIcon)")
            groupNameLB.text = group.groupName
            categoryNameLB.text = GroupFilter.getGroupValue(group.groupType)
            vm.output.groupMemberValue.accept(group.users)
        }
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
        
        bodyView.addSubview(groupLB)
        groupLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(29)
            
            $0.height.equalTo(17)
        }
        
        bodyView.addSubview(groupImageView)
        groupImageView.snp.makeConstraints {
            $0.top.equalTo(groupLB.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(50)
        }
        
        bodyView.addSubview(groupNameLB)
        groupNameLB.snp.makeConstraints {
            $0.top.equalTo(groupLB.snp.bottom).offset(24)
            $0.height.equalTo(34)
            $0.leading.equalTo(groupImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        bodyView.addSubview(stOne)
        stOne.snp.makeConstraints {
            $0.top.equalTo(groupImageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-31)
            $0.height.equalTo(1)
        }
        
        bodyView.addSubview(memberLB)
        memberLB.snp.makeConstraints {
            $0.top.equalTo(stOne.snp.bottom).offset(29)
            $0.leading.equalToSuperview().offset(29)
            $0.height.equalTo(17)
        }
        
        bodyView.addSubview(memberAddBT)
        memberAddBT.snp.makeConstraints {
            $0.top.equalTo(stOne.snp.bottom).offset(28)
            $0.height.equalTo(20)
            $0.trailing.equalToSuperview().offset(-34)
        }
        
        bodyView.addSubview(memberCV)
        memberCV.snp.makeConstraints {
            $0.top.equalTo(memberLB.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(84)
        }
        
        bodyView.addSubview(stTwo)
        stTwo.snp.makeConstraints {
            $0.top.equalTo(memberCV.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-31)
            $0.height.equalTo(1)
        }
        
        bodyView.addSubview(categoryLB)
        categoryLB.snp.makeConstraints {
            $0.top.equalTo(stTwo.snp.bottom).offset(29)
            $0.leading.equalToSuperview().offset(29)
            $0.height.equalTo(17)
        }
        
        bodyView.addSubview(categoryNameLB)
        categoryNameLB.snp.makeConstraints {
            $0.top.equalTo(categoryLB.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(33)
            $0.width.equalTo(55)
        }
        
        safeArea.addSubview(rightLabel)
        rightLabel.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top).offset(-10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        memberCV.delegate = nil
        memberCV.dataSource = nil
        memberCV.rx.setDelegate(self).disposed(by: disposeBag)
        memberCV.register(MemberCell.self, forCellWithReuseIdentifier: "cell")
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        editBT.rx.tap
            .subscribe(onNext: { [self] in
                vm.groupIcon = vm.group!.groupIcon
                vm.groupName = vm.group!.groupName
                vm.groupType = vm.group!.groupType
                let vc = GroupAddViewController()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        saveBT.rx.tap
            .subscribe(onNext: {
                let vm = GroupMemoryViewModel(group: self.vm.group!)
                let vc = GroupMemoryViewController(vm)
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        memberAddBT.rx.tap
            .subscribe(onNext: {
                self.rightLabel.labelView.text = "초대 링크 복사 완료"
                self.rightLabel.alpha = 1
                
                self.createDynamicLink()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 1.5) {
                        self.rightLabel.alpha = 0
                    }
                }
            }).disposed(by: disposeBag)
        
        
    }
    
    
    
    private func bindOutput() {
        
        vm.output.groupDetailValue.subscribe(onNext: { value in
            
            //아이콘 추가
            self.categoryNameLB.text = GroupFilter.getGroupValue(value.groupType)
            self.groupNameLB.text = value.groupName
            
        }).disposed(by: disposeBag)
        
        vm.output.groupMemberValue
            .bind(to: memberCV.rx.items(cellIdentifier: "cell", cellType: MemberCell.self)) { row, element, cell in
                cell.configure(userInfo: element)
            }.disposed(by: disposeBag)
        
        vm.output.editValue
            .subscribe(onNext: {
                self.rightLabel.labelView.text = "메모리 수정 완료"
                self.rightLabel.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 1.5) {
                        self.rightLabel.alpha = 0
                    }
                }
            }).disposed(by: disposeBag)
        
        
        
    }
    
    func createDynamicLink() {
        
        if let user = User.loginedUser,
           let group = vm.group {
            let link = URL(string: "https://cmc11th.page.link/invite_group?groupId=\(group.groupId)&userId=\(user.userSeq)")
            let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://cmc11th.page.link")
            
            // iOS 설정
            referralLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.neordinary.CMC11th.Melly")
            referralLink?.iOSParameters?.minimumAppVersion = "1.0.0"
            referralLink?.iOSParameters?.appStoreID = "6444202109"
            
            referralLink?.shorten { (shortURL, warnings, error) in
                
                if let error = error {
                    print(error)
                }
                
                if let shortURL = shortURL {
                    let object = [shortURL]
                    let activityVC = UIActivityViewController(activityItems: object, applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = self.view
                    self.present(activityVC, animated: true, completion: nil)
                }
                
            }
        }
        
        
    }
    
    
    
}

extension GroupDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 12
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 57, height: 84)
    
    }
    
    
    
    
}

final class MemberCell: UICollectionViewCell {
    
    let profileImageView = UIImageView(image: UIImage(named: "profile")).then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.contentMode = .scaleAspectFill
    }
    
    let nameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 12)
        $0.text = "소피아"
        $0.lineBreakMode = .byTruncatingMiddle
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(50)
        }
        
        addSubview(nameLB)
        nameLB.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(26)
            $0.width.equalTo(57)
        }
        
        
    }
    
    func configure(userInfo: UserInfo) {
        
        if let profileImage = userInfo.profileImage {
            let url = URL(string: profileImage)!
            profileImageView.kf.setImage(with: url)
        }
        
        nameLB.text = userInfo.isLoginUser ? "\(userInfo.nickname)(나)" : userInfo.nickname
        
    }
    
    
    
}
