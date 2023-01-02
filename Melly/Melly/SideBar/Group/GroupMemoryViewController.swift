//
//  GroupMemoryViewController.swift
//  Melly
//
//  Created by Jun on 2022/11/02.
//

import UIKit
import RxSwift
import RxCocoa
import FloatingPanel
import SkeletonView

class GroupMemoryViewController: UIViewController {
    
    private let vm:GroupMemoryViewModel
    private let disposeBag = DisposeBag()
    
    let headerView = UIView()
    
    let backBT = BackButton()
    lazy var titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = vm.group.groupName
    }
    
    let searchBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_search"), for: .normal)
        $0.isHidden = true
    }
    
    var isLoading:Bool = false
    var loadingView:FooterLoadingView?
    var memories:[Memory] = []
    let filterPanel = FloatingPanelController()
    
    
    let noDataView = UIView().then {
        $0.alpha = 0
    }
    
    let noDataFrame = UIView()
    
    let noDataImg = UIImageView(image: UIImage(named: "push_no_data"))
    
    let noDataLabel = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 20)
        $0.text = "내가 스크랩한 장소가 없습니다."
    }
    
    let filterView = UIView()
    
    let sortFilter = CategoryPicker(title: "최신 순")
    let userFilter = CategoryPicker(title: "멤버별")
    
    lazy var dataCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isSkeletonable = true
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        memories = []
        vm.input.viewAppearObserver.accept(())
    }
    
    
    init(_ vm: GroupMemoryViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        memories = []
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        dataCV.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .lightGray), animation: animation, transition: .crossDissolve(0.5))
        vm.input.ourMemoryRefresh.accept(())
    }
    
    
}

extension GroupMemoryViewController {
    
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
            $0.width.height.equalTo(28)
        }
        
        headerView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalTo(backBT.snp.trailing).offset(12)
            $0.height.equalTo(24)
        }
        
        headerView.addSubview(searchBT)
        searchBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.trailing.equalToSuperview().offset(-27)
            $0.width.height.equalTo(28)
        }
        
        
        safeArea.addSubview(filterView)
        filterView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(77)
        }
        
        
        filterView.addSubview(userFilter)
        userFilter.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(30)
        }
        
        filterView.addSubview(sortFilter)
        sortFilter.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.equalTo(userFilter.snp.trailing).offset(12)
            $0.height.equalTo(30)
        }
        
        
        safeArea.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalTo(sortFilter.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
        }
        
        safeArea.addSubview(noDataView)
        noDataView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        safeArea.addSubview(noDataView)
        noDataView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(36)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        noDataView.addSubview(noDataFrame)
        noDataFrame.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(92)
        }
        
        noDataFrame.addSubview(noDataImg)
        noDataImg.snp.makeConstraints {
            $0.centerX.top.equalToSuperview()
            $0.height.width.equalTo(46)
        }
        
        noDataFrame.addSubview(noDataLabel)
        noDataLabel.snp.makeConstraints {
            $0.top.equalTo(noDataImg.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        filterPanel.layout = MyMemoryPanelLayout()
        filterPanel.isRemovalInteractionEnabled = true
        
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
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        sortFilter.rx.tap
            .subscribe(onNext: {
                
                if self.sortFilter.mode {
                    self.vm.input.sortObserver.accept("visitedDate,desc")
                } else {
                    let vc = GroupMemorySortViewController(vm: self.vm)
                    self.filterPanel.set(contentViewController: vc)
                    self.filterPanel.addPanel(toParent: self)
                }
            }).disposed(by: disposeBag)
        
        userFilter.rx.tap
            .subscribe(onNext: {
                
                if self.userFilter.mode {
                    self.vm.input.userFilterObserver.accept(nil)
                } else {
                    let vc = GroupUserFilterViewController(vm: self.vm)
                    self.filterPanel.set(contentViewController: vc)
                    self.filterPanel.addPanel(toParent: self)
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        vm.output.ourMemoryValue.asDriver(onErrorJustReturn: [])
            .drive(onNext: { value in
                DispatchQueue.main.async {
                    self.memories += value
                    self.dataCV.reloadData()
                    self.dataCV.stopSkeletonAnimation()
                    self.dataCV.hideSkeleton(reloadDataAfter: true)
                    self.isLoading = false
                    self.refreshControl.endRefreshing()
                    if value.isEmpty {
                        self.noDataView.alpha = 1
                        self.dataCV.alpha = 0
                    } else {
                        self.noDataView.alpha = 0
                        self.dataCV.alpha = 1
                    }
                    self.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
        
        vm.output.sortValue.asDriver(onErrorJustReturn: "")
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
                self.filterPanel.view.removeFromSuperview()
                self.filterPanel.removeFromParent()
            }).disposed(by: disposeBag)
        
        vm.output.userFilterValue.asDriver(onErrorJustReturn: nil)
            .drive(onNext: { value in
                
                if let value = value {
                    self.userFilter.textLabel.text = value.nickname
                    self.userFilter.mode = true
                } else {
                    self.userFilter.textLabel.text = "멤버별"
                    self.userFilter.mode = false
                }
                
                self.view.layoutIfNeeded()
                self.memories = []
                self.vm.input.ourMemoryRefresh.accept(())
                self.filterPanel.view.removeFromSuperview()
                self.filterPanel.removeFromParent()
            }).disposed(by: disposeBag)
        
        
        
    }
    
}

//MARK: - CollectionView delegate
extension GroupMemoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource{
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "cell"
    }
    
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
        let vm = MemoryDetailViewModel(memory)
        let vc = MemoryDetailViewController(vm: vm)
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
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



class GroupUserFilterViewController: UIViewController {
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    let contentView = UIView()
    let vm:GroupMemoryViewModel
    private let disposeBag = DisposeBag()
    
    var buttons:[UIButton] = []
    
    init(vm: GroupMemoryViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(301)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        
        
        for i in 0..<vm.group.users.count {
            
            let bt = UIButton(type: .custom).then {
                let string = vm.group.users[i].nickname
                let attributedString = NSMutableAttributedString(string: string)
                let font = vm.ourMemory.userId == vm.group.users[i].userID  ? UIFont(name: "Pretendard-SemiBold", size: 20)! : UIFont(name: "Pretendard-Medium", size: 20)!
                let color = vm.ourMemory.userId == vm.group.users[i].userID ?  UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1) : UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
                attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: string.count))
                attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: string.count))
                $0.setAttributedTitle(attributedString, for: .normal)
            }
            
            bt.rx.tap
                .map { self.vm.group.users[i] }
                .bind(to: vm.input.userFilterObserver)
                .disposed(by: disposeBag)
            
            buttons.append(bt)
            contentView.addSubview(bt)
            if i == 0 {
                bt.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(41)
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(24)
                }
            } else if i == vm.group.users.count-1 {
                bt.snp.makeConstraints {
                    $0.top.equalTo(buttons[i-1].snp.bottom).offset(41)
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(24)
                    $0.bottom.equalToSuperview()
                }
            } else {
                bt.snp.makeConstraints {
                    $0.top.equalTo(buttons[i-1].snp.bottom).offset(41)
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(24)
                }
            }
            
        }
    }
    
}

class GroupMemorySortViewController: UIViewController {
    
    let contentView = UIView()
    let vm:GroupMemoryViewModel
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
    
    init(vm: GroupMemoryViewModel) {
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
            .bind(to: vm.input.sortObserver)
            .disposed(by: disposeBag)
        
        oldestBT.rx.tap
            .map { "visitedDate,asc" }
            .bind(to: vm.input.sortObserver)
            .disposed(by: disposeBag)
        
        starsHighBT.rx.tap
            .map { "stars,desc" }
            .bind(to: vm.input.sortObserver)
            .disposed(by: disposeBag)
        
        starsLowBT.rx.tap
            .map { "stars,asc" }
            .bind(to: vm.input.sortObserver)
            .disposed(by: disposeBag)
    }
    
}
