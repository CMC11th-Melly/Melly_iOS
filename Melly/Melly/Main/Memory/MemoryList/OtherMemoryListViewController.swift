//
//  OurMemoryListViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/12.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa


class OtherMemoryListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let noDataView = UIView()
    
    let noDataImageView = UIImageView(image: UIImage(named: "no_memory"))
    
    let noDataLB = UILabel().then {
        $0.text = "앗! 이 장소에 저장된\n나의 메모리가 없어요"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 22)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    let dataView = UIView().then {
        $0.isHidden = true
    }
    
    let dataLB = UILabel().then {
        $0.text = "총 5개"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor(red: 0.965, green: 0.969, blue: 0.973, alpha: 1)
    }
    
    let otherAlertImageView = UIImageView(image: UIImage(named: "memory_info"))
    
    let otherAlertLB = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.text = "공개 범위가 전체인 메모리만 표시됩니다."
    }
    
    
    let dataCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    
}


extension OtherMemoryListViewController {
    
    private func setUI() {
        
        view.addSubview(noDataView)
        noDataView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        noDataView.addSubview(noDataImageView)
        noDataImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(106)
            $0.centerX.equalToSuperview()
        }
        
        noDataView.addSubview(noDataLB)
        noDataLB.snp.makeConstraints {
            $0.top.equalTo(noDataImageView.snp.bottom).offset(19)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(dataView)
        dataView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        
//        dataView.addSubview(dataLB)
//        dataLB.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(22)
//            $0.trailing.equalToSuperview().offset(-30)
//            
//        }
//        
//        dataView.addSubview(otherAlertImageView)
//        otherAlertImageView.snp.makeConstraints {
//            $0.top.equalTo(dataLB.snp.bottom).offset(23)
//            $0.leading.equalToSuperview().offset(30)
//        }
//        
//        dataView.addSubview(otherAlertLB)
//        otherAlertLB.snp.makeConstraints {
//            $0.top.equalTo(dataLB.snp.bottom).offset(23)
//            $0.leading.equalTo(otherAlertImageView.snp.trailing).offset(5)
//        }
//        
//        dataView.addSubview(dataCV)
//        dataCV.snp.makeConstraints {
//            $0.leading.trailing.bottom.equalToSuperview()
//            $0.top.equalTo(otherAlertImageView.snp.bottom).offset(19)
//        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        dataCV.delegate = nil
        dataCV.dataSource = nil
        dataCV.rx.setDelegate(self).disposed(by: disposeBag)
        dataCV.register(MemoryListCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    private func bindOutput() {
        
    }
}


extension OtherMemoryListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width - 60
        return CGSize(width: width, height: 183)
    }
}
