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
    
    let headerView = UIView()
    let backButton = BackButton()
    
    let researchView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.alwaysBounceVertical = false
        $0.isScrollEnabled = true
        $0.bounces = false
        $0.backgroundColor = .clear
    }
    
    let childView:[UIView] = [ResearchOneView(), ResearchTwoView(), ResearchThreeView()]
    
    
    let bottomView = UIView()
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
        view.backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        
        safeArea.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        
        headerView.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(27)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(105)
        }
        
        bottomView.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        safeArea.addSubview(researchView)
        researchView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom)
            $0.bottom.equalTo(bottomView.snp.top)
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
        
        vm.output.nextBackValid.asDriver(onErrorJustReturn: -1)
            .drive(onNext: { value in
                
                if value == -1 {
                    self.navigationController?.popViewController(animated: true)
                } else if value == 3 {
                    let vc = ResearchLoadingViewController()
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let contentOffset = CGPoint(x: Int(self.view.frame.width) * value, y: 0)
                    self.researchView.setContentOffset(contentOffset, animated: true)
                    self.nextBT.isEnabled = false
                }
                
            }).disposed(by: disposeBag)
        
        vm.output.buttonValid.asDriver(onErrorJustReturn: false)
            .drive(onNext: { value in
                if value {
                    self.nextBT.isEnabled = true
                } else {
                    self.nextBT.isEnabled = false
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func addContentScrollView() {
        researchView.frame = UIScreen.main.bounds
        researchView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(childView.count), height:  UIScreen.main.bounds.height)
            for i in 0..<childView.count {
                let xPos = self.view.frame.width * CGFloat(i)
                childView[i].frame = CGRect(x: xPos, y: 0, width: researchView.bounds.width, height: UIScreen.main.bounds.height)
                researchView.addSubview(childView[i])
                researchView.contentSize.width = childView[i].frame.width * CGFloat(i + 1)
            }
        }
    
    
    
}


class ResearchOneView: UIView, UICollectionViewDelegateFlowLayout {
    
    let disposeBag = DisposeBag()
    let vm = ResearchMainViewModel.instance
    
    let stepLB = UILabel().then {
        let string = "01/03"
        let attributedString = NSMutableAttributedString(string: string)
        let defaultFont = UIFont(name: "Pretendard-Regular", size: 15)!
        let boldFont =  UIFont(name: "Pretendard-Bold", size: 15)!
        let defaultColor =  UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        attributedString.addAttribute(.font, value: defaultFont, range: (string as NSString).range(of: "/03"))
        attributedString.addAttribute(.font, value: boldFont, range: (string as NSString).range(of: "01"))
        attributedString.addAttribute(.foregroundColor, value: defaultColor, range: NSRange(location: 0, length: string.count))
        $0.attributedText = attributedString
    }
    
    let titleLb = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 22)
        $0.text = "요즘 관심있는 핫한 장소는 어딘가요?"
    }
    
    let researchCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
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
        backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        
        addSubview(stepLB)
        stepLB.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        addSubview(titleLb)
        titleLb.snp.makeConstraints {
            $0.top.equalTo(stepLB.snp.bottom).offset(17)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(31)
        }
        
        addSubview(researchCV)
        researchCV.snp.makeConstraints {
            $0.top.equalTo(titleLb.snp.bottom).offset(52)
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
                cell.title = element
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
    
    let stepLB = UILabel().then {
        let string = "02/03"
        let attributedString = NSMutableAttributedString(string: string)
        let defaultFont = UIFont(name: "Pretendard-Regular", size: 15)!
        let boldFont =  UIFont(name: "Pretendard-Bold", size: 15)!
        let defaultColor =  UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        attributedString.addAttribute(.font, value: boldFont, range: (string as NSString).range(of: "02"))
        attributedString.addAttribute(.font, value: defaultFont, range: (string as NSString).range(of: "/03"))
        attributedString.addAttribute(.foregroundColor, value: defaultColor, range: NSRange(location: 0, length: string.count))
        $0.attributedText = attributedString
    }
    
    let titleLb = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 22)
        $0.text = "요즘 관심있는 활동는 무엇인가요?"
    }
    
    let researchCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor =  UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
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
        backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        
        addSubview(stepLB)
        stepLB.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        addSubview(titleLb)
        titleLb.snp.makeConstraints {
            $0.top.equalTo(stepLB.snp.bottom).offset(17)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(31)
        }
        
        addSubview(researchCV)
        researchCV.snp.makeConstraints {
            $0.top.equalTo(titleLb.snp.bottom).offset(52)
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
                cell.title = element
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
    
    
    let stepLB = UILabel().then {
        let string = "03/03"
        let attributedString = NSMutableAttributedString(string: string)
        let defaultFont = UIFont(name: "Pretendard-Regular", size: 15)!
        let boldFont =  UIFont(name: "Pretendard-Bold", size: 15)!
        let defaultColor =  UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        attributedString.addAttribute(.font, value: boldFont, range: (string as NSString).range(of: "03"))
        attributedString.addAttribute(.font, value: defaultFont, range: (string as NSString).range(of: "/03"))
        attributedString.addAttribute(.foregroundColor, value: defaultColor, range: NSRange(location: 0, length: string.count))
        $0.attributedText = attributedString
    }
    
    let titleLb = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 22)
        $0.text = "요즘 누구와 시간을 자주 보내시나요?"
    }
    
    let researchCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
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
        backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        
        addSubview(stepLB)
        stepLB.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        addSubview(titleLb)
        titleLb.snp.makeConstraints {
            $0.top.equalTo(stepLB.snp.bottom).offset(17)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(31)
        }
        
        addSubview(researchCV)
        researchCV.snp.makeConstraints {
            $0.top.equalTo(titleLb.snp.bottom).offset(52)
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
                cell.title = element
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
    
    var title:String? {
        didSet {
            if let title = title {
                let imageTitle = title.components(separatedBy: " / ").joined()
                
                logoImageView.image = UIImage(named: imageTitle)
                titleLB.text = title
            }
        }
    }
    
    let logoImageView = UIImageView()
    
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
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
            $0.top.equalToSuperview().offset(15)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(34)
        }
        
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
        }
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
                titleLB.textColor = .white
                logoImageView.image!.withRenderingMode(.alwaysTemplate)
                logoImageView.tintColor = UIColor.white
                
                
            } else {
                backgroundColor = .white
                titleLB.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
                logoImageView.image?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
}
