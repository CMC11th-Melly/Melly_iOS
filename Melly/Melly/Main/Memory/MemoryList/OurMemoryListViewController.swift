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

class OurMemoryListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    let vm = MemoryListViewModel.instance
    var isLoading:Bool = false
    var loadingView:CollectionReusableView?
    var memories:[Memory] = []
    
    let noDataView = UIView().then {
        $0.isHidden = true
    }
    
    let noDataImageView = UIImageView(image: UIImage(named: "no_memory"))
    
    let noDataLB = UILabel().then {
        $0.text = "앗! 이 장소에 저장된\n나의 메모리가 없어요"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 22)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    let dataView = UIView()
    
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
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.ourMemoryRefresh.accept(())
    }
    
}

extension OurMemoryListViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        //        view.addSubview(noDataView)
        //        noDataView.snp.makeConstraints {
        //            $0.edges.equalToSuperview()
        //        }
        //
        //        noDataView.addSubview(noDataImageView)
        //        noDataImageView.snp.makeConstraints {
        //            $0.top.equalToSuperview().offset(106)
        //            $0.centerX.equalToSuperview()
        //        }
        //
        //        noDataView.addSubview(noDataLB)
        //        noDataLB.snp.makeConstraints {
        //            $0.top.equalTo(noDataImageView.snp.bottom).offset(19)
        //            $0.centerX.equalToSuperview()
        //        }
        
        safeArea.addSubview(dataView)
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
            $0.bottom.equalToSuperview()
            $0.top.equalTo(dataLB.snp.bottom).offset(23)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        dataCV.delegate = self
        dataCV.dataSource = self
        dataCV.register(MemoryListCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        let loadingReusableNib = UINib(nibName: "CollectionReusableView", bundle: nil)
        dataCV.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerCell")
        
        
    }
    
    private func bindOutput() {
        
        vm.output.ourMemoryValue.asDriver(onErrorJustReturn: [])
            .drive(onNext: { value in
                DispatchQueue.main.async {
                    self.memories += value
                    self.dataLB.text = "총 \(self.memories.count)개"
                    self.dataCV.reloadData()
                }
            }).disposed(by: disposeBag)
        
    }
    
}

//MARK: - CollectionView delegate
extension OurMemoryListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //collectionview cell의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memories.count
    }
    
    //collectionView cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MemoryListCollectionViewCell
        cell.configure(memories[indexPath.row])
        return cell
        
    }
    
    //collectionView 자체의 레이아웃
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //열과 열 사이의 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 28
        
    }
    
    //셀 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width - 60
        return CGSize(width: width, height: 183)
    }
    
    //footer 인디케이터 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoading /*|| 서버에서 모든 데이터를 가져왔을 경우*/ {
            return CGSize.zero
        } else {
            return CGSize(width: dataCV.bounds.size.width, height: 55)
        }
    }
    
    //footer(인디케이터) 배경색 등 상세 설정
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerCell", for: indexPath) as! CollectionReusableView
            loadingView = footerView
            loadingView?.backgroundColor = .clear
            return footerView
        }
        return UICollectionReusableView()
    }
    
    //인디케이터 로딩 애니메이션 시작
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if self.isLoading {
                self.loadingView?.activityIndicator.startAnimating()
            } else {
                self.loadingView?.activityIndicator.stopAnimating()
            }
        }
    }
    
    //footer뷰가 안보일 때 동작
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.activityIndicator.stopAnimating()
        }
        
    }
    
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            
        }
    
    
    
}


