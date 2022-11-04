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
import FloatingPanel

class OurMemoryListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    let vm:MemoryListViewModel
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
    
    let filterView = UIView()
    
    let groupFilter = CategoryPicker(title: "카테고리")
    let sortFilter = CategoryPicker(title: "최신 순")
    
    let dataCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    init(vm: MemoryListViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        safeArea.addSubview(dataView)
        dataView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dataView.addSubview(filterView)
        filterView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(77)
        }
        
        filterView.addSubview(groupFilter)
        groupFilter.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(30)
        }
        
        filterView.addSubview(sortFilter)
        sortFilter.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.equalTo(groupFilter.snp.trailing).offset(12)
            $0.height.equalTo(30)
        }
        
        
        dataView.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalTo(sortFilter.snp.bottom).offset(22)
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
        
        sortFilter.rx.tap
            .subscribe(onNext: {
                
                if self.sortFilter.mode {
                    self.vm.input.ourSortObserver.accept("visitedDate,desc")
                } else {
                    self.vm.output.goToOurSortVC.accept(())
                    
                }
            }).disposed(by: disposeBag)
        
        groupFilter.rx.tap
            .subscribe(onNext: {
                
                if self.groupFilter.mode {
                    self.vm.input.ourGroupFilterObserver.accept(.all)
                } else {
                    self.vm.output.goToOurFilterVC.accept(())
                }
                
            }).disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        
        vm.output.ourMemoryValue.asDriver(onErrorJustReturn: [])
            .drive(onNext: { value in
                DispatchQueue.main.async {
                    self.memories += value
                    self.dataCV.reloadData()
                    self.isLoading = false
                    self.isNoData = value.isEmpty ? true : false
                }
            }).disposed(by: disposeBag)
        
        vm.output.ourSortValue.asDriver(onErrorJustReturn: "")
            .drive(onNext: { value in
                if value == "visitedDate,asc" {
                    self.sortFilter.textLabel.text = "오래된 순"
                    self.sortFilter.mode = true
                } else if value == "stars,desc" {
                    self.sortFilter.textLabel.text = "별점이 높은 순"
                    self.sortFilter.mode = true
                } else if value == "stars,asc" {
                    self.sortFilter.textLabel.text = "별점이 낮은 순"
                    self.sortFilter.mode = true
                } else {
                    self.sortFilter.textLabel.text = "최신 순"
                    self.sortFilter.mode = false
                }
                
                self.view.layoutIfNeeded()
                self.memories = []
                self.vm.input.ourMemoryRefresh.accept(())
            }).disposed(by: disposeBag)
        
        vm.output.ourGroupFilterValue.asDriver(onErrorJustReturn: .all)
            .drive(onNext: { value in
                
                switch value {
                case .company:
                    self.groupFilter.textLabel.text = "동료만"
                    self.groupFilter.mode = true
                case .friend:
                    self.groupFilter.textLabel.text = "친구만"
                    self.groupFilter.mode = true
                case .couple:
                    self.groupFilter.textLabel.text = "연인만"
                    self.groupFilter.mode = true
                case .family:
                    self.groupFilter.textLabel.text = "가족만"
                    self.groupFilter.mode = true
                default :
                    self.groupFilter.textLabel.text = "카테고리"
                    self.groupFilter.mode = false
                }
                
                self.view.layoutIfNeeded()
                self.memories = []
                self.vm.input.ourMemoryRefresh.accept(())
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
        
        if !vm.ourMemory.isEnd && !self.isLoading && self.memories.count-1 == indexPath.row {
            
            self.isLoading = true
            DispatchQueue.global().async {
                sleep(1)
                self.vm.input.ourMemoryRefresh.accept(())
            }
        }
    }
    
}


class OurMemoryFilterViewController: UIViewController {
    
    let contentView = UIView()
    let vm:MemoryListViewModel
    private let disposeBag = DisposeBag()
    
    lazy var lastestBT = UIButton(type: .custom).then {
        let string = "최신 순"
        let attributedString = NSMutableAttributedString(string: string)
        
        let font = vm.ourMemory.sort == "visitedDate,desc" ? UIFont(name: "Pretendard-SemiBold", size: 20)! : UIFont(name: "Pretendard-Medium", size: 20)!
        let color = vm.ourMemory.sort == "visitedDate,desc" ?  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1) : UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:  color, range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    lazy var oldestBT = UIButton(type: .custom).then {
        let string = "오래된 순"
        let attributedString = NSMutableAttributedString(string: string)
        
        let font = vm.ourMemory.sort == "visitedDate,asc" ? UIFont(name: "Pretendard-SemiBold", size: 20)! : UIFont(name: "Pretendard-Medium", size: 20)!
        let color = vm.ourMemory.sort == "visitedDate,asc" ?  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1) : UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    lazy var starsHighBT = UIButton(type: .custom).then {
        let string = "별점이 높은 순"
        let attributedString = NSMutableAttributedString(string: string)
        
        let font = vm.ourMemory.sort == "stars,desc" ? UIFont(name: "Pretendard-SemiBold", size: 20)! : UIFont(name: "Pretendard-Medium", size: 20)!
        let color = vm.ourMemory.sort == "stars,desc" ?  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1) : UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:  color, range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    lazy var starsLowBT = UIButton(type: .custom).then {
        let string = "별점이 낮은 순"
        let attributedString = NSMutableAttributedString(string: string)
        let font = vm.ourMemory.sort == "stars,asc" ? UIFont(name: "Pretendard-SemiBold", size: 20)! : UIFont(name: "Pretendard-Medium", size: 20)!
        let color = vm.ourMemory.sort == "stars,asc" ?  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1) : UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    init(vm: MemoryListViewModel) {
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
    
    private func setUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(301)
        }
        
        contentView.addSubview(lastestBT)
        lastestBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(41)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        contentView.addSubview(oldestBT)
        oldestBT.snp.makeConstraints {
            $0.top.equalTo(lastestBT.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        contentView.addSubview(starsHighBT)
        starsHighBT.snp.makeConstraints {
            $0.top.equalTo(oldestBT.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        contentView.addSubview(starsLowBT)
        starsLowBT.snp.makeConstraints {
            $0.top.equalTo(starsHighBT.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
    }
    
    private func bind() {
        
        lastestBT.rx.tap
            .map { "visitedDate,desc" }
            .bind(to: vm.input.ourSortObserver)
            .disposed(by: disposeBag)
        
        oldestBT.rx.tap
            .map { "visitedDate,asc" }
            .bind(to: vm.input.ourSortObserver)
            .disposed(by: disposeBag)
        
        starsHighBT.rx.tap
            .map { "stars,desc" }
            .bind(to: vm.input.ourSortObserver)
            .disposed(by: disposeBag)
        
        starsLowBT.rx.tap
            .map { "stars,asc" }
            .bind(to: vm.input.ourSortObserver)
            .disposed(by: disposeBag)
    }
    
}

class OurMemoryGroupFilterViewController: UIViewController {
    
    let contentView = UIView()
    let vm:MemoryListViewModel
    private let disposeBag = DisposeBag()
    
    lazy var familyBT = UIButton(type: .custom).then {
        let string = "가족만"
        let attributedString = NSMutableAttributedString(string: string)
        
        let font = vm.ourMemory.groupType == .family ? UIFont(name: "Pretendard-SemiBold", size: 20)! : UIFont(name: "Pretendard-Medium", size: 20)!
        let color = vm.ourMemory.groupType == .family ?  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1) : UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:  color, range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    lazy var coupleBT = UIButton(type: .custom).then {
        let string = "연인만"
        let attributedString = NSMutableAttributedString(string: string)
        
        let font = vm.ourMemory.groupType == .couple ? UIFont(name: "Pretendard-SemiBold", size: 20)! : UIFont(name: "Pretendard-Medium", size: 20)!
        let color = vm.ourMemory.groupType == .couple ?  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1) : UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    lazy var friendBT = UIButton(type: .custom).then {
        let string = "친구만"
        let attributedString = NSMutableAttributedString(string: string)
        
        let font = vm.ourMemory.groupType == .friend ? UIFont(name: "Pretendard-SemiBold", size: 20)! : UIFont(name: "Pretendard-Medium", size: 20)!
        let color = vm.ourMemory.groupType == .friend ?  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1) : UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value:  color, range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    lazy var companyBT = UIButton(type: .custom).then {
        let string = "동료만"
        let attributedString = NSMutableAttributedString(string: string)
        let font = vm.ourMemory.groupType == .company  ? UIFont(name: "Pretendard-SemiBold", size: 20)! : UIFont(name: "Pretendard-Medium", size: 20)!
        let color = vm.ourMemory.groupType == .company ?  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1) : UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    init(vm: MemoryListViewModel) {
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
    
    private func setUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(301)
        }
        
        contentView.addSubview(familyBT)
        familyBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(41)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        contentView.addSubview(coupleBT)
        coupleBT.snp.makeConstraints {
            $0.top.equalTo(familyBT.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        contentView.addSubview(friendBT)
        friendBT.snp.makeConstraints {
            $0.top.equalTo(coupleBT.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        contentView.addSubview(companyBT)
        companyBT.snp.makeConstraints {
            $0.top.equalTo(friendBT.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
    }
    
    private func bind() {
        
        familyBT.rx.tap
            .map { GroupFilter.family }
            .bind(to: vm.input.ourGroupFilterObserver)
            .disposed(by: disposeBag)
        
        coupleBT.rx.tap
            .map { GroupFilter.couple }
            .bind(to: vm.input.ourGroupFilterObserver)
            .disposed(by: disposeBag)
        
        friendBT.rx.tap
            .map { GroupFilter.friend }
            .bind(to: vm.input.ourGroupFilterObserver)
            .disposed(by: disposeBag)
        
        companyBT.rx.tap
            .map { GroupFilter.company }
            .bind(to: vm.input.ourGroupFilterObserver)
            .disposed(by: disposeBag)
    }
    
}
