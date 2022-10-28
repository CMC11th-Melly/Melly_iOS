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
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.text = "그룹명"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
    }
    
    let groupImageView = UIImageView(image: UIImage(named: "profile"))
    
    lazy var groupNameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.text = vm.group?.groupName
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 22)
    }
    
    let stOne = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let memberLB = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.text = "멤버"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
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
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.text = "카테고리"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
    }
    
    lazy var categoryNameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.text = vm.group?.groupType
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        $0.layer.cornerRadius = 10
    }
    
    
    let bottomView = UIView()
    let saveBT = CustomButton(title: "이 그룹이 쓴 메모리 보기")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let group = vm.group {
            vm.input.getGroupDetailObserver.accept(group)
        } else {
            self.dismiss(animated: true)
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
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        editBT.rx.tap
            .subscribe(onNext: {
                let vm = GroupEditViewModel(group: self.vm.group)
                let vc = GroupAddViewController(vm: vm)
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
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
    }
    
    let nameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1)
        $0.text = "소피아"
        $0.lineBreakMode = .byTruncatingMiddle
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 12)
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
            $0.top.leading.trailing.equalToSuperview()
            $0.height.width.equalTo(50)
        }
        
        addSubview(nameLB)
        nameLB.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
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
