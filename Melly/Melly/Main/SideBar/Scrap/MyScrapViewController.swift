//
//  ScrapViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/29.
//

import UIKit
import RxSwift
import RxCocoa


class MyScrapViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let vm = MyScrapViewModel()
    
    let headerView = UIView()
    
    let backBT = BackButton()
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "스크랩"
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
        vm.input.scrapObserver.accept(())
    }

}

extension MyScrapViewController {
    
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
        
        safeArea.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(36)
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
        
        dataCV.delegate = nil
        dataCV.dataSource = nil
        dataCV.rx.setDelegate(self).disposed(by: disposeBag)
        dataCV.register(ScrapCell.self, forCellWithReuseIdentifier: "cell")
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        
    }
    
    
}

extension MyScrapViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: self.view.frame.width-60, height: 76)
    }
    
    
    
}

final class ScrapCell: UICollectionViewCell {
    
    
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
    
    
    
    
}
