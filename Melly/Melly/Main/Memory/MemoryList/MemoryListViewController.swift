//
//  MemoryListViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/12.
//

import UIKit
import RxCocoa
import RxSwift
import FloatingPanel

class MemoryListViewController: UIViewController {
    
    let vm:MemoryListViewModel
    let filterPanel = FloatingPanelController()
    private let disposeBag = DisposeBag()
    
    let bottomView = UIView()
    
    let contentView = UIView()
    
    lazy var locationTitleLB = UILabel().then {
        $0.text = vm.place.placeName
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 18)
    }
    
    lazy var locationCategoryLB = UILabel().then {
        $0.text = vm.place.placeCategory
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    lazy var bmButton = UIImageView().then {
        let image = UIImage(named: vm.place.isScraped ? "bookmark_fill" : "bookmark_empty")
        $0.image = image
    }
    
    let closeButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_x"), for: .normal)
    }
    
    let locationImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let memorySegmentedControl = UnderlineSegmentedControl(items: ["나의 메모리", "이 장소 메모리"]).then {
        $0.selectedSegmentIndex = 0
    }
    
    private lazy var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil).then {
        $0.setViewControllers([self.dataView[0]], direction: .forward, animated: true)
        $0.isPagingEnabled = false
        $0.delegate = self
        $0.dataSource = self
        
    }
    
    private lazy var ourMemoryViewController = OurMemoryListViewController(vm: vm)
    private lazy var otherMemoryViewController = OtherMemoryListViewController(vm: vm)
    
    
    var dataView: [UIViewController] { [self.ourMemoryViewController, self.otherMemoryViewController] }
    
    let writeMemoryBT = CustomButton(title: "이 장소에 메모리 쓰기").then {
        $0.isEnabled = true
    }
    
    var currentPage: Int = 0 {
        didSet {
          let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
          self.pageViewController.setViewControllers(
            [dataView[self.currentPage]],
            direction: direction,
            animated: true,
            completion: nil
          )
        }
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
    
}

extension MemoryListViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        
        safeArea.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        bottomView.addSubview(writeMemoryBT)
        writeMemoryBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        safeArea.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        contentView.addSubview(locationTitleLB)
        locationTitleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(34)
        }
        
        contentView.addSubview(locationCategoryLB)
        locationCategoryLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalTo(locationTitleLB.snp.trailing).offset(6)
        }
        
        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(24)
        }
        
        contentView.addSubview(bmButton)
        bmButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-6)
        }
        
        contentView.addSubview(locationImageView)
        locationImageView.snp.makeConstraints {
            $0.top.equalTo(locationTitleLB.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(183)
        }
        
        contentView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(locationImageView.snp.bottom).offset(62)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        contentView.addSubview(memorySegmentedControl)
        memorySegmentedControl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(locationImageView.snp.bottom).offset(17)
            $0.height.equalTo(45)
        }
        
        contentView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        
        filterPanel.isRemovalInteractionEnabled = true
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        memorySegmentedControl.addTarget(self, action: #selector(changeValue), for: .valueChanged)
        self.changeValue(control: self.memorySegmentedControl)
        
        closeButton.rx.tap.subscribe(onNext: {
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
    }
    
    @objc private func changeValue(control: UISegmentedControl) {
        self.currentPage = control.selectedSegmentIndex
    }
    
    private func bindOutput() {
        vm.output.selectMemoryValue.subscribe(onNext: { value in
            let vm = MemoryDetailViewModel(value)
            let vc = MemoryDetailViewController(vm: vm)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }).disposed(by: disposeBag)
        
        vm.output.goToOurFilterVC
            .subscribe(onNext: {
                let vc = OurMemoryGroupFilterViewController(vm: self.vm)
                self.filterPanel.layout = MyMemoryPanelLayout()
                self.filterPanel.set(contentViewController: vc)
                self.filterPanel.addPanel(toParent: self)
            }).disposed(by: disposeBag)
        
        vm.output.goToOurSortVC
            .subscribe(onNext: {
                let vc = OurMemoryFilterViewController(vm: self.vm)
                self.filterPanel.layout = MyMemoryPanelLayout()
                self.filterPanel.set(contentViewController: vc)
                self.filterPanel.addPanel(toParent: self)
            }).disposed(by: disposeBag)
        
        vm.output.ourSortValue
            .subscribe(onNext: { value in
                self.filterPanel.view.removeFromSuperview()
                self.filterPanel.removeFromParent()
            }).disposed(by: disposeBag)
        
        vm.output.ourGroupFilterValue
            .subscribe(onNext: { value in
                self.filterPanel.view.removeFromSuperview()
                self.filterPanel.removeFromParent()
            }).disposed(by: disposeBag)
        
        vm.output.goToOtherFilterVC
            .subscribe(onNext: {
                let vc = OtherMemoryGroupFilterViewController(vm: self.vm)
                self.filterPanel.layout = MyMemoryPanelLayout()
                self.filterPanel.set(contentViewController: vc)
                self.filterPanel.addPanel(toParent: self)
            }).disposed(by: disposeBag)
        
        vm.output.goToOtherSortVC
            .subscribe(onNext: {
                let vc = OtherMemoryFilterViewController(vm: self.vm)
                self.filterPanel.layout = MyMemoryPanelLayout()
                self.filterPanel.set(contentViewController: vc)
                self.filterPanel.addPanel(toParent: self)
            }).disposed(by: disposeBag)
        
        vm.output.goToOtherAllVC
            .subscribe(onNext: {
                let vc = OtherAllViewController(vm: self.vm)
                self.filterPanel.layout = OtherAllPanelLayout()
                self.filterPanel.set(contentViewController: vc)
                self.filterPanel.addPanel(toParent: self)
            }).disposed(by: disposeBag)
        
        vm.output.otherSortValue
            .subscribe(onNext: { value in
                self.filterPanel.view.removeFromSuperview()
                self.filterPanel.removeFromParent()
            }).disposed(by: disposeBag)
        
        vm.output.otherGroupFilterValue
            .subscribe(onNext: { value in
                self.filterPanel.view.removeFromSuperview()
                self.filterPanel.removeFromParent()
            }).disposed(by: disposeBag)
        
        vm.output.otherAllValue
            .subscribe(onNext: { value in
                self.filterPanel.view.removeFromSuperview()
                self.filterPanel.removeFromParent()
            }).disposed(by: disposeBag)
        
    }
    
}

//MARK: - PageViewController Delegate, DataSource
extension MemoryListViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    //page가 바뀌기 직전에 호출
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController ) -> UIViewController? {
        guard
            let index = self.dataView.firstIndex(of: viewController),
            index - 1 >= 0
        else { return nil }
        return self.dataView[index - 1]
    }
    
    //page가 바뀐 후에 호출
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController ) -> UIViewController? {
        guard
            let index = self.dataView.firstIndex(of: viewController),
            index + 1 < self.dataView.count
        else { return nil }
        return self.dataView[index + 1]
    }
    
    //page animation이 실행한 후에 실행
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let viewController = pageViewController.viewControllers?[0],
            let index = self.dataView.firstIndex(of: viewController)
        else { return }
        self.currentPage = index
        self.memorySegmentedControl.selectedSegmentIndex = index
    }
    
}

class OtherAllPanelLayout: FloatingPanelLayout{
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 192, edge: .bottom, referenceGuide: .superview)
        ]
    }
}
