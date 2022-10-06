//
//  SearchViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/05.
//

import UIKit
import RxCocoa
import RxSwift


class SearchViewController: UIViewController {
    
    let searchTextField = SearchTextField()
    
    let recentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let recentLB = UILabel().then {
        $0.text = "최근검색"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 18)
    }
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let recentCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let searchView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
    }
    
}

extension SearchViewController {
    
    func setUI() {
        self.view.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        
        safeArea.addSubview(searchTextField)
        searchTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(44)
        }
        
        safeArea.addSubview(recentView)
        recentView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(26)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        recentView.addSubview(recentLB)
        recentLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.leading.equalToSuperview().offset(30)
        }
        
        recentView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(recentLB.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        recentView.addSubview(recentCV)
        recentCV.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom)
            $0.trailing.leading.bottom.equalToSuperview()
        }
        
        
        
    }
    
}



class SearchTextField: UITextField {
    
    //w:51, h:44
    let leftPaddingView = UIView()
    let leftBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_back"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    let rightPaddingView = UIView()
    let rightBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_x"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        self.font = UIFont(name: "Pretendard-Regular", size: 14)
        self.placeholder = "장소, 메모리 검색"
        self.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        
        
        leftPaddingView.snp.makeConstraints {
            $0.width.equalTo(51)
            $0.height.equalTo(44)
        }
        
        leftPaddingView.addSubview(leftBt)
        leftBt.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        rightPaddingView.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(44)
        }
        
        rightPaddingView.addSubview(rightBt)
        rightBt.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        self.rightView = rightPaddingView
        self.rightViewMode = .whileEditing
        self.leftView = leftPaddingView
        self.leftViewMode = .always
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1).cgColor
        
    }
    
    
}
