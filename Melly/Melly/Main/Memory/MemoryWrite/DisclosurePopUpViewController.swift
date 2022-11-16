//
//  DisclosurePopUpViewController.swift
//  Melly
//
//  Created by Jun on 2022/11/14.
//

import UIKit
import RxCocoa
import RxSwift

class DisclosurePopUpViewController: UIViewController {

    private let disposeBag = DisposeBag()
    let vm:MemoryWriteViewModel
    
    let contentView = UIView()
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "이 메모리를 누구에게 공개할까요?"
    }
    
    let dataCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let bottomView = UIView()
    
    let cancelBT = DefaultButton("취소", false)
    
    let confirmBT = CustomButton(title: "완료").then {
        $0.isEnabled = false
    }
    
    
    init(vm: MemoryWriteViewModel) {
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
    
}



extension DisclosurePopUpViewController {
    
    private func setUI() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(110)
        }
        
        bottomView.addSubview(cancelBT)
        cancelBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo((self.view.frame.width - 70) / 2)
            $0.height.equalTo(56)
        }
        
        bottomView.addSubview(confirmBT)
        confirmBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalTo(cancelBT.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(32)
        }
        
        contentView.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
    }
    
    private func bind() {
        
        dataCV.dataSource = nil
        dataCV.delegate = nil
        dataCV.rx.setDelegate(self).disposed(by: disposeBag)
        dataCV.register(DisclosureCell.self, forCellWithReuseIdentifier: "cell")
        
        vm.rxDisclosureData
            .bind(to: dataCV.rx.items(cellIdentifier: "cell", cellType: DisclosureCell.self)) { row, element, cell in
                cell.titleLB.text = element
            }.disposed(by: disposeBag)
        
        dataCV.rx.itemSelected.map { index in
            let cell = self.dataCV.cellForItem(at: index) as? DisclosureCell
            return cell?.titleLB.text ?? ""
        }.subscribe(onNext: { value in
            let type = MemoryOpenType.getValue(value)
            self.vm.input.openTypeObserver.accept(type)
            self.confirmBT.isEnabled = true
        }).disposed(by: disposeBag)
        
        cancelBT.rx.tap
            .bind(to: vm.input.openTypeCancelObserver)
            .disposed(by: disposeBag)
        
        confirmBT.rx.tap
            .bind(to: vm.input.registerServerObserver)
            .disposed(by: disposeBag)
        
    }
    
}

extension DisclosurePopUpViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
           guard let cell = collectionView.cellForItem(at: indexPath) as? BookmarkCell else {
               return true
           }
           if cell.isSelected {
               collectionView.deselectItem(at: indexPath, animated: true)
               self.confirmBT.isEnabled = false
               return false
           } else {
               return true
           }
       }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width - 60
        return CGSize(width: width, height: 58)
    }
    
}


class DisclosureCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
                titleLB.textColor = .white
            } else {
                titleLB.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
                backgroundColor = .clear
            }
        }
    }
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
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
        
        layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        layer.cornerRadius = 12
        layer.borderWidth = 1
       
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(17)
            $0.height.equalTo(19)
        }
        
    }
    
    
}
