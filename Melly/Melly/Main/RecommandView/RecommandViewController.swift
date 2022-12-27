//
//  ContentViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/13.
//

import UIKit
import FloatingPanel
import RxSwift
import RxCocoa
import SkeletonView


class RecommandViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    let vm = RecommandViewModel.instance
    weak var delegate:GoPlaceDelegate?
    
    let mainSV = UIScrollView().then {
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
    let contentView = UIView()
    
    lazy var recomandLabel = UILabel().then {
        let text = "\(User.loginedUser!.nickname)에게 추천하는 메모리 장소"
        let attributedString = NSMutableAttributedString(string: text)
        let font = UIFont(name: "Pretendard-Medium", size: 20)!
        let highlightFont = UIFont(name: "Pretendard-Bold", size: 20)!
        let color = UIColor(red: 0.102, green: 0.118, blue: 0.153, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.font, value: highlightFont, range: (text as NSString).range(of: "메모리 장소"))
        $0.attributedText = attributedString
    }
    
    let recommandSubLabel = UILabel().then {
        $0.text = "비슷한 연령대가 이 장소에서 메모리를 많이 작성했어요"
        $0.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let recommandCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.isUserInteractionEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isSkeletonable = true
        
        return collectionView
    }()
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let hotLabel = UILabel().then {
        let text = "요즘 핫한 메모리 장소"
        let attributedString = NSMutableAttributedString(string: text)
        let font = UIFont(name: "Pretendard-Medium", size: 20)!
        let highlightFont = UIFont(name: "Pretendard-Bold", size: 20)!
        let color = UIColor(red: 0.102, green: 0.118, blue: 0.153, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.font, value: highlightFont, range: (text as NSString).range(of: "메모리 장소"))
        $0.attributedText = attributedString
    }
    
    let hotSubLabel = UILabel().then {
        $0.text = "동시간대 가장 많이 메모리가 작성되고 있는 장소예요"
        $0.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let hotLocationCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.isUserInteractionEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isSkeletonable = true
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCV()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recommandCV.showSkeleton(usingColor: .gray)
        hotLocationCV.showSkeleton(usingColor: .gray)
        vm.input.viewAppearObserver.accept(())
    }
    
}

extension RecommandViewController {
    
   private func setUI() {
        view.backgroundColor = .white
        
        safeArea.addSubview(mainSV)
        mainSV.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainSV.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(recomandLabel)
        recomandLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(43)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(recommandSubLabel)
        recommandSubLabel.snp.makeConstraints {
            $0.top.equalTo(recomandLabel.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(recommandCV)
        recommandCV.snp.makeConstraints {
            $0.top.equalTo(recommandSubLabel.snp.bottom).offset(34)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1134)
        }
        
        
        contentView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.trailing.equalTo(safeArea)
            $0.height.equalTo(1)
            $0.top.equalTo(recommandCV.snp.bottom).offset(28)
        }
        
        contentView.addSubview(hotLabel)
        hotLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(hotSubLabel)
        hotSubLabel.snp.makeConstraints {
            $0.top.equalTo(hotLabel.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(hotLocationCV)
        hotLocationCV.snp.makeConstraints {
            $0.top.equalTo(hotSubLabel.snp.bottom).offset(34)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1139)
            $0.bottom.equalToSuperview()
        }
        
        
    }
    
   private func setCV() {
        recommandCV.dataSource = self
        recommandCV.delegate = self
        recommandCV.register(RecommandCollectionViewCell.self, forCellWithReuseIdentifier: "recommand")
        
        
        hotLocationCV.dataSource = self
        hotLocationCV.delegate = self
        hotLocationCV.register(RecommandCollectionViewCell.self, forCellWithReuseIdentifier: "hot")
        
    }
    
   private func bind() {
        
        vm.output.goToPlace
            .subscribe(onNext: { value in
                self.delegate?.showLocationPopupView(value)
            }).disposed(by: disposeBag)
       
       vm.output.errorValue.asDriver(onErrorJustReturn: "")
           .drive(onNext: { value in
               let alert = UIAlertController(title: "에러", message: value, preferredStyle: .alert)
               let cancelAction = UIAlertAction(title: "확인", style: .cancel)
               alert.addAction(cancelAction)
               self.present(alert, animated: true)
           }).disposed(by: disposeBag)
       
       PopUpViewModel.instance.output.completeBookmark.subscribe(onNext: {
           self.vm.input.viewAppearObserver.accept(())
       }).disposed(by: disposeBag)
       
       vm.output.goToMemory.subscribe(onNext: { memory in
           self.delegate?.goToMemoryView(memory)
       }).disposed(by: disposeBag)
       
       vm.output.successValue
           .subscribe(onNext: {
               DispatchQueue.main.async {
                   self.recommandCV.reloadData()
                   self.hotLocationCV.reloadData()
                   self.recommandCV.stopSkeletonAnimation()
                   self.recommandCV.hideSkeleton(reloadDataAfter: true)
                   self.hotLocationCV.stopSkeletonAnimation()
                   self.hotLocationCV.hideSkeleton(reloadDataAfter: true)
                   
               }
           }).disposed(by: disposeBag)
       
    }
    
}



extension RecommandViewController: SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        if skeletonView == recommandCV {
            return "recommand"
        } else {
            return "hot"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recommandCV {
            return vm.recommendData.count
        } else {
            return vm.hotDatas.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recommandCV {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommand", for: indexPath) as! RecommandCollectionViewCell
            cell.itLocation = vm.recommendData[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hot", for: indexPath) as! RecommandCollectionViewCell
            cell.itLocation = vm.hotDatas[indexPath.row]
            return cell
        }
    }
    
}

//MARK: - UICollectionView Delegate
extension RecommandViewController: UICollectionViewDelegateFlowLayout {
    
    
    //collectionView 자체의 레이아웃
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //열과 열사이의 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    //행과 행사이의 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    //셀의 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 342)
    }
    
}
