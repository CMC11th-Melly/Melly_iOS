//
//  OurMemoryListViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/12.
//

import Foundation
import UIKit
import Then

class OurMemoryListViewController: UIViewController {
    
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


extension OurMemoryListViewController {
    
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
        
        dataView.addSubview(dataLB)
        dataLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-30)
            
        }
        
        dataView.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(dataLB.snp.bottom).offset(23)
        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
    }
    
    private func bindOutput() {
        
    }
}
