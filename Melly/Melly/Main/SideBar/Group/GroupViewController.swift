//
//  GroupViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/28.
//

import UIKit
import RxSwift
import RxCocoa


class GroupViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    let vm = GroupViewModel.instance
    
    let backBT = BackButton()
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "MY그룹"
    }
    
    let addBT = UIButton(type: .custom).then {
        let string = "추가"
        let attributedString = NSMutableAttributedString(string: string)
        let font = UIFont(name: "Pretendard-SemiBold", size: 18)!
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let headerView = UIView()
    
    let noDataView = UIView()
    
    let cancelImg = UIImageView(image: UIImage(named: "group_cancel"))
    
    let noDataLB = UILabel().then {
        $0.textColor = UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1)
        $0.text = "내가 만든 그룹이 없습니다."
        $0.font = UIFont(name: "Pretendard-Medium", size: 22)
    }
    
    let noDataAddBT = UIButton(type: .custom).then {
        let string = "새 그룹 만들기"
        let attributedString = NSMutableAttributedString(string: string)
        let font = UIFont(name: "Pretendard-SemiBold", size: 16)!
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
        $0.backgroundColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.layer.cornerRadius = 12
    }
    
    let dataView = UIView().then {
        $0.isHidden = true
    }
    
    let dataCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        vm.input.getGroupObserver.accept(())
    }

}

extension GroupViewController {
    
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
        
        headerView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.height.equalTo(24)
            $0.leading.equalTo(backBT.snp.trailing).offset(12)
        }
        
        headerView.addSubview(addBT)
        addBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.trailing.equalToSuperview().offset(-34)
            $0.height.equalTo(29)
        }
        
        safeArea.addSubview(noDataView)
        noDataView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        noDataView.addSubview(cancelImg)
        cancelImg.snp.makeConstraints {
            $0.top.equalToSuperview().offset(226)
            $0.centerX.equalToSuperview()
        }
        
        noDataView.addSubview(noDataLB)
        noDataLB.snp.makeConstraints {
            $0.top.equalTo(cancelImg.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(33)
        }
        
        noDataView.addSubview(noDataAddBT)
        noDataAddBT.snp.makeConstraints {
            $0.top.equalTo(noDataLB.snp.bottom).offset(43)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(56)
        }
        
        safeArea.addSubview(dataView)
        dataView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        dataView.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-30)
        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        dataCV.delegate = nil
        dataCV.dataSource = nil
        dataCV.rx.setDelegate(self).disposed(by: disposeBag)
        dataCV.register(GroupCell.self, forCellWithReuseIdentifier: "cell")
       
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        addBT.rx.tap
            .subscribe(onNext: {
                let vm = GroupEditViewModel()
                let vc = GroupAddViewController(vm: vm)
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
        noDataAddBT.rx.tap
            .subscribe(onNext: {
                let vm = GroupEditViewModel()
                let vc = GroupAddViewController(vm: vm)
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
        dataCV.rx.itemSelected
            .map ({ index in
                let cell = self.dataCV.cellForItem(at: index) as? GroupCell
                return cell!.group!
            }).bind(to: vm.input.selectedGroup)
            .disposed(by: disposeBag)
        
        
    }
    
    private func bindOutput() {
        vm.output.groupValue.asDriver(onErrorJustReturn: [])
            .drive(onNext: { value in
                if value.isEmpty {
                    self.noDataView.isHidden = false
                    self.dataView.isHidden = true
                } else {
                    self.noDataView.isHidden = true
                    self.dataView.isHidden = false
                }
            }).disposed(by: disposeBag)
        
        vm.output.groupValue
            .bind(to: dataCV.rx.items(cellIdentifier: "cell", cellType: GroupCell.self)) { row, element, cell in
                cell.group = element
            }.disposed(by: disposeBag)
        
        vm.output.goToDetailView
            .subscribe(onNext: {
                let vc = GroupDetailViewController()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
}

extension GroupViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: self.view.frame.width-60, height: 76)
    }
    
    
    
}


final class GroupCell: UICollectionViewCell {
    
    var group:Group? {
        didSet {
            setData()
        }
    }
    
    let imageView = UIImageView(image: UIImage(named: "profile"))
    
    
    let groupNameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
    }
    
    let memberLB = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
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
        backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        layer.cornerRadius = 12
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.width.equalTo(40)
        }
        
        addSubview(groupNameLB)
        groupNameLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(12)
            $0.height.equalTo(22)
        }
        
        addSubview(memberLB)
        memberLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(17)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        
    }
    
    private func setData() {
        
        if let group = group {
            
            groupNameLB.text = group.groupName
            
            memberLB.text = "멤버 \(group.users.count)명"
            
        }
        
    }
    
    
}
