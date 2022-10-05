//
//  ResearchMainViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/04.
//

import UIKit
import RxSwift
import RxCocoa

class ResearchMainViewController: UIViewController {
    let vm = ResearchMainViewModel.instance
    let disposeBag = DisposeBag()
    
    let backButton = BackButton()
    
    let researchView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.alwaysBounceVertical = false
        $0.isScrollEnabled = false
        $0.bounces = false
        $0.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
    }
    
    let stepLB = UILabel().then {
        $0.text = "01/03"
        $0.textColor = UIColor(red: 0.427, green: 0.459, blue: 0.506, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 15)
    }
    
    let childView:[UIView] = [ResearchOneView(), ResearchTwoView(), ResearchThreeView()]
    
    let nextBT = CustomButton(title: "다음으로").then {
        $0.isEnabled = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
        addContentScrollView()
    }
    
}

extension ResearchMainViewController {
    
    private func setUI() {
        view.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        
        safeArea.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(stepLB)
        stepLB.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        safeArea.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        safeArea.addSubview(researchView)
        researchView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(stepLB.snp.bottom)
            $0.bottom.equalTo(nextBT.snp.top)
        }
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        backButton.rx.tap
            .bind(to: vm.input.backObserver)
            .disposed(by: disposeBag)
        
        nextBT.rx.tap
            .bind(to: vm.input.nextObserver)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        
        vm.output.nextBackValid.asDriver(onErrorJustReturn: 0)
            .drive(onNext: { value in
                
                if value == 0 {
                    self.dismiss(animated: true)
                } else if value == 4 {
                    let vc = ResearchLaunchViewController()
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                } else {
                    let value = value - 1
                    let contentOffset = CGPoint(x: Int(self.view.frame.width) * value, y: 0)
                    self.researchView.setContentOffset(contentOffset, animated: true)
                    self.nextBT.isEnabled = false
                    self.nextBT.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
                }
                
            }).disposed(by: disposeBag)
        
        vm.output.buttonValid.asDriver(onErrorJustReturn: false)
            .drive(onNext: { value in
                if value {
                    self.nextBT.isEnabled = true
                    self.nextBT.backgroundColor = .orange
                } else {
                    self.nextBT.isEnabled = false
                    self.nextBT.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func addContentScrollView() {
        researchView.frame = UIScreen.main.bounds
        researchView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(childView.count), height: 525)
            for i in 0..<childView.count {
                let xPos = self.view.frame.width * CGFloat(i)
                childView[i].frame = CGRect(x: xPos, y: 0, width: researchView.bounds.width, height: 525)
                researchView.addSubview(childView[i])
                researchView.contentSize.width = childView[i].frame.width * CGFloat(i + 1)
            }
        }
    
    
    
}


class ResearchOneView: UIView, UICollectionViewDelegateFlowLayout {
    
    let disposeBag = DisposeBag()
    let vm = ResearchMainViewModel.instance
    
    
    let titleLb = UILabel().then {
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        $0.text = "요즘 관심있는 핫한 장소는 어딘가요?"
        $0.font = UIFont(name: "Pretendard-Bold", size: 22)
    }
    
    let researchCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        addSubview(titleLb)
        titleLb.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(40)
        }
        
        addSubview(researchCV)
        researchCV.snp.makeConstraints {
            $0.top.equalTo(titleLb.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    func bind() {
        
        researchCV.dataSource = nil
        researchCV.delegate = nil
        researchCV.rx.setDelegate(self).disposed(by: disposeBag)
        researchCV.register(ResearchViewCell.self, forCellWithReuseIdentifier: "cell")
        
        vm.oneData
            .bind(to: researchCV.rx.items(cellIdentifier: "cell", cellType: ResearchViewCell.self)) { row, element, cell in
                cell.titleLB.text = element
            }.disposed(by: disposeBag)
        
        researchCV.rx.itemSelected
            .map { index in
                let cell = self.researchCV.cellForItem(at: index) as? ResearchViewCell
                let text = cell?.titleLB.text ?? ""
                return text
            }.bind(to: vm.input.researchOneObserver)
            .disposed(by: disposeBag)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 23
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 26
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (frame.width-86)/2
        return CGSize(width: width, height: 89)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
           guard let cell = collectionView.cellForItem(at: indexPath) as? ResearchViewCell else {
               return true
           }
           if cell.isSelected {
               collectionView.deselectItem(at: indexPath, animated: true)
               return false
           } else {
               return true
           }
       }
    
    
}

class ResearchTwoView: UIView, UICollectionViewDelegateFlowLayout {
    
    let disposeBag = DisposeBag()
    let vm = ResearchMainViewModel.instance
    
    let titleLb = UILabel().then {
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        $0.text = "요즘 관심있는 활동는 무엇인가요?"
        $0.font = UIFont(name: "Pretendard-Bold", size: 22)
    }
    
    let researchCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor =  UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        addSubview(titleLb)
        titleLb.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(40)
        }
        
        addSubview(researchCV)
        researchCV.snp.makeConstraints {
            $0.top.equalTo(titleLb.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    func bind() {
        
        researchCV.dataSource = nil
        researchCV.delegate = nil
        researchCV.rx.setDelegate(self).disposed(by: disposeBag)
        researchCV.register(ResearchViewCell.self, forCellWithReuseIdentifier: "cell")
        
        vm.twoData
            .bind(to: researchCV.rx.items(cellIdentifier: "cell", cellType: ResearchViewCell.self)) { row, element, cell in
                cell.titleLB.text = element
            }.disposed(by: disposeBag)
        
        researchCV.rx.itemSelected
            .map { index in
                let cell = self.researchCV.cellForItem(at: index) as? ResearchViewCell
                let text = cell?.titleLB.text ?? ""
                return text
            }.bind(to: vm.input.researchTwoObserver)
            .disposed(by: disposeBag)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 23
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 26
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (frame.width-86)/2
        return CGSize(width: width, height: 89)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
           guard let cell = collectionView.cellForItem(at: indexPath) as? ResearchViewCell else {
               return true
           }
           if cell.isSelected {
               collectionView.deselectItem(at: indexPath, animated: true)
               return false
           } else {
               return true
           }
       }
    
}

class ResearchThreeView: UIView, UICollectionViewDelegateFlowLayout {
    
    let disposeBag = DisposeBag()
    let vm = ResearchMainViewModel.instance
    
    
    let titleLb = UILabel().then {
        $0.textColor = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        $0.text = "요즘 누구와 시간을 자주 보내시나요?"
        $0.font = UIFont(name: "Pretendard-Bold", size: 22)
    }
    
    let researchCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        addSubview(titleLb)
        titleLb.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(40)
        }
        
        addSubview(researchCV)
        researchCV.snp.makeConstraints {
            $0.top.equalTo(titleLb.snp.bottom).offset(17)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    func bind() {
        
        researchCV.dataSource = nil
        researchCV.delegate = nil
        researchCV.rx.setDelegate(self).disposed(by: disposeBag)
        researchCV.register(ResearchViewCell.self, forCellWithReuseIdentifier: "cell")
        
        vm.threeData
            .bind(to: researchCV.rx.items(cellIdentifier: "cell", cellType: ResearchViewCell.self)) { row, element, cell in
                cell.titleLB.text = element
            }.disposed(by: disposeBag)
        
        researchCV.rx.itemSelected
            .map { index in
                let cell = self.researchCV.cellForItem(at: index) as? ResearchViewCell
                let text = cell?.titleLB.text ?? ""
                return text
            }.bind(to: vm.input.researchThreeObserver)
            .disposed(by: disposeBag)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 23
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 26
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (frame.width-86)/2
        return CGSize(width: width, height: 89)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
           guard let cell = collectionView.cellForItem(at: indexPath) as? ResearchViewCell else {
               return true
           }
           if cell.isSelected {
               collectionView.deselectItem(at: indexPath, animated: true)
               return false
           } else {
               return true
           }
       }
    
}




class ResearchViewCell: UICollectionViewCell {
    
    
    let logoImageView = UIImageView(image: UIImage(systemName: "globe.americas.fill"))
    
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
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
    
    func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(29.47)
        }
        
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(7.27)
            $0.centerX.equalToSuperview()
        }
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .orange
            } else {
                backgroundColor = .white
            }
        }
    }
    
}
