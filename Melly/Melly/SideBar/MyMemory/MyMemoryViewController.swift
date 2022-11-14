//
//  MyMemoryViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/23.
//

import UIKit
import RxSwift
import RxCocoa
import FloatingPanel

class MyMemoryViewController: UIViewController {
    
    private let vm = MyMemoryViewModel()
    private let disposeBag = DisposeBag()
    let headerView = UIView()
    
    let backBT = BackButton()
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "MY메모리"
    }
    
    let searchBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_search"), for: .normal)
        $0.isHidden = true
    }
    
    var isLoading:Bool = false
    var loadingView:FooterLoadingView?
    
    let filterPanel = FloatingPanelController()
    
    var isNoData:Bool = false {
        didSet {
            if isNoData {
                noDataView.alpha = 1
                dataCV.alpha = 0
            } else {
                noDataView.alpha = 0
                dataCV.alpha = 1
            }
        }
    }
    
    let noDataView = UIView().then {
        $0.alpha = 0
    }
    
    let noDataFrame = UIView()
    
    let noDataImageView = UIImageView(image: UIImage(named: "no_memory"))
    
    let noDataLB = UILabel().then {
        $0.text = "내가 작성한 메모리가 없습니다."
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.textAlignment = .center
        $0.font = UIFont(name: "Pretendard-Medium", size: 20)
    }
    
    let noDataLB2 = UILabel().then {
        $0.text = "앗! 이 장소에 저장된\n나의 메모리가 없어요"
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 20)
    }
    
    let noDataBT = CustomButton(title: "새 메모리 작성하기").then {
        $0.isEnabled = true
    }
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
        setNC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.viewAppearObserver.accept(())
    }
    
    
}

extension MyMemoryViewController {
    
    func setNC() {
        NotificationCenter.default.addObserver(self, selector: #selector(goToInviteGroup), name: NSNotification.InviteGroupNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(shareMemory), name: NSNotification.MemoryShareNotification, object: nil)
    }
    
    @objc func goToInviteGroup(_ notification: Notification) {
        
        if let value = notification.object as? [String] {
            let vm = InviteGroupViewModel(userId: value[1], groupId: value[0])
            let vc = InviteGroupViewController(vm: vm)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        
    }
    
    @objc func shareMemory(_ notification:Notification) {
        
        if let memoryId = notification.object as? String {
            
            ShareMemoryViewModel.getMemory(memoryId)
                .subscribe(onNext: { value in
                    
                    if let error = value.error {
                        self.vm.output.errorValue.accept(error.msg)
                    } else if let memory = value.success as? Memory {
                        let vm = MemoryDetailViewModel(memory)
                        let vc = MemoryDetailViewController(vm: vm)
                        vc.modalTransitionStyle = .coverVertical
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                        
                    }
                    
                }).disposed(by: disposeBag)
            
        }
        
    }
    
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
        
        safeArea.addSubview(noDataView)
        noDataView.snp.makeConstraints {
            $0.top.equalTo(sortFilter.snp.bottom).offset(22)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        noDataView.addSubview(noDataFrame)
        noDataFrame.snp.makeConstraints {
            $0.width.equalTo(239)
            $0.height.equalTo(189)
            $0.centerX.centerY.equalToSuperview()
        }
        
        noDataFrame.addSubview(noDataImageView)
        noDataImageView.snp.makeConstraints {
            $0.width.height.equalTo(46)
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        noDataFrame.addSubview(noDataLB2)
        noDataLB2.snp.makeConstraints {
            $0.top.equalTo(noDataImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
            
        }
        
        safeArea.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalTo(sortFilter.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
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
                    let vc = MyMemoryFilterViewController(self.vm)
                    self.filterPanel.set(contentViewController: vc)
                    self.filterPanel.addPanel(toParent: self)
                }
            }).disposed(by: disposeBag)
        
        groupFilter.rx.tap
            .subscribe(onNext: {
                
                if self.groupFilter.mode {
                    self.vm.input.groupFilterObserver.accept(.all)
                } else {
                    let vc = MyMemoryGroupFilterViewController(self.vm)
                    self.filterPanel.set(contentViewController: vc)
                    self.filterPanel.addPanel(toParent: self)
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        vm.output.ourMemoryValue.asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                DispatchQueue.main.async {
                    print(self.vm.memories.count)
                    self.dataCV.reloadData()
                    self.isLoading = false
                    self.isNoData = self.vm.memories.isEmpty ? true : false
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
                
                self.vm.input.ourMemoryRefresh.accept(())
                self.filterPanel.view.removeFromSuperview()
                self.filterPanel.removeFromParent()
            }).disposed(by: disposeBag)
        
        vm.output.groupFilterValue.asDriver(onErrorJustReturn: .all)
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
                
                self.vm.input.ourMemoryRefresh.accept(())
                self.filterPanel.view.removeFromSuperview()
                self.filterPanel.removeFromParent()
                
            }).disposed(by: disposeBag)
        
        vm.output.errorValue.asDriver(onErrorJustReturn: "")
            .drive(onNext: { value in
                
                let alert = UIAlertController(title: "에러", message: value, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(alertAction)
                self.present(alert, animated: true)
                
            }).disposed(by: disposeBag)
        
    }
    
}

//MARK: - CollectionView delegate
extension MyMemoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //collectionview cell의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.memories.count
    }
    
    //collectionView cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MemoryListCollectionViewCell
        cell.memory = self.vm.memories[indexPath.row]
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
        let memory = vm.memories[indexPath.row]
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
        
        if !vm.ourMemory.isEnd && !self.isLoading && self.vm.memories.count-1 == indexPath.row {
            
            self.isLoading = true
            DispatchQueue.global().async {
                sleep(1)
                self.vm.input.ourMemoryRefresh.accept(())
            }
        }
    }
    
}



//MARK: - Recommand Pop Up View Layout
class MyMemoryPanelLayout: FloatingPanelLayout{
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 301, edge: .bottom, referenceGuide: .superview)
        ]
    }
}

class MyMemoryFilterViewController: UIViewController {
    
    let contentView = UIView()
    let vm:MyMemoryViewModel
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
    
    init(_ vm: MyMemoryViewModel) {
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

class MyMemoryGroupFilterViewController: UIViewController {
    
    let contentView = UIView()
    let vm:MyMemoryViewModel
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
    
    init(_ vm: MyMemoryViewModel) {
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
            .bind(to: vm.input.groupFilterObserver)
            .disposed(by: disposeBag)
        
        coupleBT.rx.tap
            .map { GroupFilter.couple }
            .bind(to: vm.input.groupFilterObserver)
            .disposed(by: disposeBag)
        
        friendBT.rx.tap
            .map { GroupFilter.friend }
            .bind(to: vm.input.groupFilterObserver)
            .disposed(by: disposeBag)
        
        companyBT.rx.tap
            .map { GroupFilter.company }
            .bind(to: vm.input.groupFilterObserver)
            .disposed(by: disposeBag)
    }
    
}

