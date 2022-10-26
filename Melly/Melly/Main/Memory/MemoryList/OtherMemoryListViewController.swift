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
    let vm = MemoryListViewModel.instance
    var isLoading:Bool = false
    var loadingView:FooterLoadingView?
    var memories:[Memory] = []
    
    var isNoData:Bool = false {
        didSet {
            if isNoData {
                noDataView.isHidden = false
                dataView.isHidden = true
            } else {
                noDataView.isHidden = true
                dataView.isHidden = false
            }
        }
    }
    
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
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.otherMemoryRefresh.accept(())
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
        
        
        dataView.addSubview(dataLB)
        dataLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-30)
            
        }
        
        dataView.addSubview(otherAlertImageView)
        otherAlertImageView.snp.makeConstraints {
            $0.top.equalTo(dataLB.snp.bottom).offset(23)
            $0.leading.equalToSuperview().offset(30)
        }
        
        dataView.addSubview(otherAlertLB)
        otherAlertLB.snp.makeConstraints {
            $0.top.equalTo(dataLB.snp.bottom).offset(23)
            $0.leading.equalTo(otherAlertImageView.snp.trailing).offset(5)
        }
        
        dataView.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
            $0.top.equalTo(otherAlertImageView.snp.bottom).offset(19)
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
        dataCV.register(FooterLoadingView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterLoadingView.identifier)
    }
    
    private func bindOutput() {
        
        vm.output.otherMemoryValue.asDriver(onErrorJustReturn: [])
            .drive(onNext: { value in
                DispatchQueue.main.async {
                    self.memories += value
                    self.dataLB.text = "총 \(self.memories.count)개"
                    self.dataCV.reloadData()
                    self.isLoading = false
                    self.isNoData = value.isEmpty ? true : false
                }
            }).disposed(by: disposeBag)
        
    }
}

//MARK: - CollectionView delegate
extension OtherMemoryListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //collectionview cell의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memories.count
    }
    
    //collectionView cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MemoryListCollectionViewCell
        cell.memory = self.memories[indexPath.row]
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
        if isLoading || vm.otherMemory.isEnd {
            return CGSize.zero
        } else {
            return CGSize(width: dataCV.bounds.size.width, height: 55)
        }
    }
    
    //셀 선택시 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let memory = memories[indexPath.row]
        self.vm.input.memorySelect.accept(memory)
    }
    
    
    //footer(인디케이터) 배경색 등 상세 설정
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FooterLoadingView.identifier, for: indexPath) as! FooterLoadingView
            loadingView = footerView
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
    
    //cell이 보일 때 실행하는 메서드
    //마지막 인덱스 일때 api실행
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if !vm.otherMemory.isEnd && !self.isLoading && self.memories.count-1 == indexPath.row {
            
            self.isLoading = true
            DispatchQueue.global().async {
                sleep(1)
                self.vm.input.otherMemoryRefresh.accept(())
            }
        }
    }
    
}
