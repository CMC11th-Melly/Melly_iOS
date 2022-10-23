//
//  MyMemoryViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/23.
//

import UIKit
import RxSwift
import RxCocoa

class MyMemoryViewController: UIViewController {

    private let vm = MyMemoryViewModel()
    private let disposeBag = DisposeBag()
    
    let backBT = BackButton()
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "MY메모리"
    }
    
    let searchBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_search"), for: .normal)
    }
    
    let editBT = UIButton(type: .custom).then {
        let string = "편집"
        let attributedString = NSMutableAttributedString(string: string)
        let font = UIFont(name: "Pretendard-Medium", size: 16)!
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 18)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
        
    }
    
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
    

}

extension MyMemoryViewController {
    
    private func setUI() {
        safeArea.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalTo(backBT.snp.trailing).offset(12)
        }
        
        safeArea.addSubview(searchBT)
        searchBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        safeArea.addSubview(dataView)
        dataView.snp.makeConstraints {
            $0.top.equalTo(searchBT.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        dataView.addSubview(editBT)
        editBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(41)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        dataView.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalTo(editBT.snp.bottom).offset(22)
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
        dataCV.delegate = self
        dataCV.dataSource = self
        dataCV.register(MemoryListCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        dataCV.register(FooterLoadingView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterLoadingView.identifier)
    }
    
    private func bindOutput() {
        
    }
    
}

//MARK: - CollectionView delegate
extension MyMemoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
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
        if isLoading || vm.ourMemory.isEnd {
            return CGSize.zero
        } else {
            return CGSize(width: dataCV.bounds.size.width, height: 55)
        }
    }
    
    //셀 선택시 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let memory = memories[indexPath.row]
        self.vm.input.ourMemorySelect.accept(memory)
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
        
        if !vm.ourMemory.isEnd && !self.isLoading && self.memories.count-1 == indexPath.row {
            
            self.isLoading = true
            DispatchQueue.global().async {
                sleep(1)
                self.vm.input.ourMemoryRefresh.accept(())
            }
        }
    }
    
}
