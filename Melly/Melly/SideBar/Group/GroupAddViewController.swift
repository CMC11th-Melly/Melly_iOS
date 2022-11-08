//
//  GroupAddViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/28.
//

import UIKit
import RxCocoa
import RxSwift

class GroupAddViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    let vm = GroupViewModel.instance
    
    let backBT = BackButton()
    
    lazy var titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.102, green: 0.118, blue: 0.153, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        
        if let _ = vm.group {
            $0.text = "그룹 편집"
        } else {
            $0.text = "새로운 그룹 추가"
        }
    }
    
    let headerView = UIView()
    
    let groupNameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.text = "그룹명"
    }
    
    lazy var nameTF = CustomTextField(title: "그룹명을 입력해주세요.").then {
        if let _ = vm.group {
            $0.textField.text = vm.group?.groupName
        }
    }
    
    let groupCategoryLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.text = "그룹 카테고리"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let categoryCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let groupIconLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.text = "아이콘 선택"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let iconCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let bodyView = UIView()
    
    let bottomView = UIView()
    
    lazy var cancelBT = DefaultButton("취소", false).then {
        if let _ = vm.group {
            $0.titleLB.text = "그룹 삭제"
        }
    }
    
    lazy var saveBT = DefaultButton("그룹 저장", true).then {
        if let _ = vm.group {
            $0.titleLB.text = "그룹 편집"
        }
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

extension GroupAddViewController {
    
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
        
        safeArea.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        bottomView.addSubview(cancelBT)
        cancelBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(56)
            $0.width.equalTo((self.view.frame.width-70)/2)
        }
        
        bottomView.addSubview(saveBT)
        saveBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
            $0.width.equalTo((self.view.frame.width-70)/2)
        }
        
        safeArea.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.bottom.equalTo(bottomView.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        bodyView.addSubview(groupNameLB)
        groupNameLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(26)
        }
        
        bodyView.addSubview(nameTF)
        nameTF.snp.makeConstraints {
            $0.top.equalTo(groupNameLB.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(58)
        }
        
        bodyView.addSubview(groupCategoryLB)
        groupCategoryLB.snp.makeConstraints {
            $0.top.equalTo(nameTF.snp.bottom).offset(33)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(26)
        }
        
        bodyView.addSubview(categoryCV)
        categoryCV.snp.makeConstraints {
            $0.top.equalTo(groupCategoryLB.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(33)
        }
        
        bodyView.addSubview(groupIconLB)
        groupIconLB.snp.makeConstraints {
            $0.top.equalTo(categoryCV.snp.bottom).offset(33)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(26)
        }
        
        bodyView.addSubview(iconCV)
        iconCV.snp.makeConstraints {
            $0.top.equalTo(groupIconLB.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        saveBT.rx.tap
            .subscribe(onNext: {
                if self.saveBT.titleLB.text == "그룹 저장" {
                    self.vm.input.addGroupObserver.accept(())
                } else {
                    self.vm.input.editGroupObserver.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        cancelBT.rx.tap
            .subscribe(onNext: {
                
                if self.cancelBT.titleLB.text == "그룹 삭제" {
                    
                    let alert = UIAlertController(title: "정말 삭제하시겠어요?", message: "그룹을 삭제하면 멤버도 없어집니다!", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                    let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                        self.vm.input.removeObserver.accept(())
                    }
                    
                    alert.addAction(cancelAction)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                    
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }).disposed(by: disposeBag)
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        nameTF.textField.rx.text.orEmpty
            .debounce(RxTimeInterval.microseconds(5), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: vm.input.groupNameObserver)
            .disposed(by: disposeBag)
        
        categoryCV.dataSource = nil
        categoryCV.delegate = nil
        categoryCV.rx.setDelegate(self).disposed(by: disposeBag)
        categoryCV.register(GroupCategoryCell.self, forCellWithReuseIdentifier: "category")
        categoryCV.rx.itemSelected
            .map { index in
                let cell = self.categoryCV.cellForItem(at: index) as? GroupCategoryCell
                let text = cell?.categoryLB.text ?? ""
                switch text {
                case "가족":
                    return GroupFilter.family.rawValue
                case "동료" :
                    return GroupFilter.company.rawValue
                case "연인":
                    return GroupFilter.couple.rawValue
                case "친구":
                    return GroupFilter.friend.rawValue
                default:
                    return "ALL"
                }
            }.bind(to: vm.input.groupCategoryObserver)
            .disposed(by: disposeBag)
        
        
        iconCV.dataSource = nil
        iconCV.delegate = nil
        iconCV.rx.setDelegate(self).disposed(by: disposeBag)
        iconCV.register(GroupIconCell.self, forCellWithReuseIdentifier: "icon")
        
        iconCV.rx.itemSelected
            .map { index in
                let cell = self.iconCV.cellForItem(at: index) as? GroupIconCell
                return cell!.id
            }.bind(to: vm.input.groupIconObserver)
            .disposed(by: disposeBag)
        
        
    }
    
    private func bindOutput() {
        
        vm.groupCategoryData
            .bind(to: categoryCV.rx.items(cellIdentifier: "category", cellType: GroupCategoryCell.self)) { row, element, cell in
                cell.categoryLB.text = element
                
            }.disposed(by: disposeBag)
        
        vm.groupIconData
            .bind(to: iconCV.rx.items(cellIdentifier: "icon", cellType: GroupIconCell.self)) { row, element, cell in
                cell.id = element
            }.disposed(by: disposeBag)
        
        vm.output.errorValue.asDriver(onErrorJustReturn: "")
            .drive(onNext: { value in
                
                let alert = UIAlertController(title: "에러", message: value, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(alertAction)
                self.present(alert, animated: true)
                
            }).disposed(by: disposeBag)
        
        vm.output.groupAddComplete
            .subscribe(onNext: { value in
                let vc = GroupAddCompleteViewController(group: value)
                vc.modalTransitionStyle = .coverVertical
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.removeValue
            .subscribe(onNext: {
                self.navigationController?.popToRootViewController(animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.editValue
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    
    
}

extension GroupAddViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 26
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == categoryCV {
            return (self.view.frame.width - 280) / 4
        } else {
            return (self.view.frame.width - 310) / 4
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == categoryCV {
            return CGSize(width: 55, height: 33)
        } else {
            return CGSize(width: 50, height: 50)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if collectionView == categoryCV {
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? GroupCategoryCell else {
                return true
            }
            if cell.isSelected {
                collectionView.deselectItem(at: indexPath, animated: true)
                return false
            } else {
                return true
            }
            
        } else {
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? GroupIconCell else {
                return true
            }
            if cell.isSelected {
                collectionView.deselectItem(at: indexPath, animated: true)
                return false
            } else {
                return true
            }
            
        }
        
    }
    
    
}


final class GroupCategoryCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                categoryLB.textColor = .white
                backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
            } else {
                categoryLB.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
                backgroundColor = .white
            }
        }
    }
    
    let categoryLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
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
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        
        
        addSubview(categoryLB)
        categoryLB.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
        
    }
    
    
    
}

final class GroupIconCell: UICollectionViewCell {
    
    
    let imageView = UIImageView(image: UIImage(named: "profile")).then {
        $0.clipsToBounds = true
        $0.alpha = 0
    }
    
    let notSelectImageView = UIImageView().then {
        $0.clipsToBounds = true
    }
    
    var id:Int = 1 {
        didSet {
            imageView.image = UIImage(named: "group_icon_\(id)")
            notSelectImageView.image = UIImage(named: "group_not_seleted_\(id)")
        }
    }
    
    override var isSelected: Bool {
        didSet {
           if isSelected {
               imageView.alpha = 1
            } else {
            imageView.alpha = 0
            }
        }
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
        layer.cornerRadius = 46.67
        layer.borderWidth = 0
        layer.borderColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1).cgColor
        addSubview(notSelectImageView)
        notSelectImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    
    
    
}
