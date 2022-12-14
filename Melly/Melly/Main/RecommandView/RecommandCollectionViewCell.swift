//
//  RecommandCollectionViewCell.swift
//  Melly
//
//  Created by Jun on 2022/09/26.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import SkeletonView

class RecommandCollectionViewCell: UICollectionViewCell {
    
    private let disposeBag = DisposeBag()
    let vm = RecommandViewModel.instance
    
    var itLocation:ItLocation? {
        didSet {
            setData()
        }
    }
    
    let mainImageView = UIButton(type: .custom).then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        $0.isUserInteractionEnabled = true
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
        $0.contentMode = .scaleAspectFill
        $0.isSkeletonable = true
        $0.skeletonCornerRadius = 10
    }
    
    let categoryView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 0.7)
        $0.layer.cornerRadius = 6
    }
    
    let thumbsImage = UIImageView(image: UIImage(named: "thumbs"))
    
    let categoryLb = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.text = "연인과 추천"
    }
    
    let bookmarkBT = UIButton(type: .custom).then {
        $0.isSelected = false
        $0.setImage(UIImage(named: "bookmark_empty"), for: .normal)
        $0.setImage(UIImage(named: "bookmark_fill"), for: .selected)
    }
    
    let locationLB = UILabel().then {
        $0.text = "트러플에이커피 서울역점"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 18)
        $0.isSkeletonable = true
        $0.linesCornerRadius = 5
    }
    
    let locationCategoryLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.text = "카페, 디저트"
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.isSkeletonable = true
        $0.linesCornerRadius = 5
    }
    
    let memoryCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(RecommandMemoryCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.isScrollEnabled = true
        collectionView.allowsSelection = false
        collectionView.isUserInteractionEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isSkeletonable = true
        collectionView.skeletonCornerRadius = 10
        
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        memoryCV.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .lightGray), animation: animation, transition: .crossDissolve(0.5))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        isUserInteractionEnabled = true
        addSubview(mainImageView)
        mainImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(183)
        }
        
        categoryView.addSubview(thumbsImage)
        thumbsImage.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
        }
        
        categoryView.addSubview(categoryLb)
        categoryLb.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(thumbsImage.snp.trailing).offset(4)
        }
        
        mainImageView.addSubview(categoryView)
        categoryView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.leading.equalToSuperview().offset(18)
            $0.width.equalTo(98)
            $0.height.equalTo(24)
        }
        
        mainImageView.addSubview(bookmarkBT)
        bookmarkBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(17)
            $0.trailing.equalToSuperview().offset(-18)
            $0.width.height.equalTo(24)
        }
        
        addSubview(locationLB)
        locationLB.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(30)
        }
        
        addSubview(locationCategoryLB)
        locationCategoryLB.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(21)
            $0.leading.equalTo(locationLB.snp.trailing).offset(7)
        }
        
        addSubview(memoryCV)
        memoryCV.snp.makeConstraints {
            $0.top.equalTo(locationLB.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        
        
    }
    
    func setData() {
        if var itLocation = itLocation {
            if let urlString = itLocation.placeInfo.placeImage {
                let url = URL(string: urlString)!
                mainImageView.kf.setImage(with: url, for: .normal)
            } else {
                mainImageView.setImage(UIImage(named: "place_default_image"), for: .normal)
            }
            
            mainImageView.rx.tap
                .map { itLocation.placeInfo }
                .bind(to: vm.input.placeObserver)
                .disposed(by: disposeBag)
            
            categoryLb.text = "\(GroupFilter.getKoValue(itLocation.placeInfo.recommendType)) 추천"
            locationCategoryLB.text = itLocation.placeInfo.placeCategory
            locationLB.text = itLocation.placeInfo.placeName
            bookmarkBT.isSelected = itLocation.placeInfo.isScraped
            
            bookmarkBT.rx.tap
                .subscribe(onNext: {
                    if itLocation.placeInfo.isScraped {
                        self.vm.input.bookmarkRemoveObserver.accept(itLocation.placeInfo)
                        itLocation.placeInfo.isScraped = false
                        self.bookmarkBT.isSelected = false
                    } else {
                        self.vm.input.bookmarkAddObserver.accept(itLocation.placeInfo)
                    }
                    
                }).disposed(by: disposeBag)
            
            
            memoryCV.dataSource = self
            memoryCV.delegate = self
            DispatchQueue.main.async {
                self.memoryCV.reloadData()
                self.memoryCV.stopSkeletonAnimation()
                self.memoryCV.hideSkeleton(reloadDataAfter: true)
            }
            
        }
        
        
    }
    
    
    
    
    
}

//MARK: - CollectionView delegate
extension RecommandCollectionViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itLocation?.memoryInfo.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecommandMemoryCell
        cell.memory = itLocation!.memoryInfo[indexPath.row]
        
        return cell
    }
    
    //collectionView자체 latout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    }
    
    //행과 행사이의 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 13
    }
    
    //셀 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width-60, height: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? RecommandMemoryCell else { return }
        if let memory = cell.memory {
            vm.output.goToMemory.accept(memory)
        }
    }
    
    
}



class RecommandMemoryCell: UICollectionViewCell {
    
    var memory:Memory? {
        didSet {
            setData()
        }
    }
    
    let bubbleView = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "main_bubble"), for: .normal)
    }
    
    let bubbleImageView = UIImageView().then {
        $0.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.isSkeletonable = true
        $0.skeletonCornerRadius = 10
    }
    
    let bubbleDateLB = UILabel().then {
        $0.textColor = UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 10)
    }
    
    let bubbleTitleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.text = "꽤 괜찮은 하루였다."
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.isSkeletonable = true
        $0.linesCornerRadius = 5
    }
    
    let bubbleContentLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
        $0.text = "오늘은 트러플에이커피에서 오빠랑 함께 놀았다. 그래 특히 기분이 더 좋았다. 역시 노는게 최고"
        $0.isSkeletonable = true
        $0.linesCornerRadius = 5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setUI() {
        self.isSkeletonable = true
        addSubview(bubbleView)
        bubbleView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bubbleView.addSubview(bubbleImageView)
        bubbleImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(19)
            $0.height.width.equalTo(50)
        }
        
        
        bubbleView.addSubview(bubbleTitleLB)
        bubbleTitleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.equalTo(bubbleImageView.snp.trailing).offset(16)
            $0.height.equalTo(22)
        }
        
        bubbleView.addSubview(bubbleDateLB)
        bubbleDateLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(29)
            $0.leading.equalTo(bubbleTitleLB.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualToSuperview().offset(-19)
            $0.height.equalTo(14)
        }
        
        
        bubbleView.addSubview(bubbleContentLB)
        bubbleContentLB.snp.makeConstraints {
            $0.top.equalTo(bubbleTitleLB.snp.bottom).offset(5)
            $0.leading.equalTo(bubbleImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-25)
            $0.height.equalTo(34)
        }
        
    }
    
    private func setData() {
        
        if let memory = memory {
            
            if memory.memoryImages.count != 0 {
                let url = URL(string: memory.memoryImages[0].memoryImage)!
                bubbleImageView.kf.setImage(with: url)
            }
            
            bubbleTitleLB.text = memory.title
            bubbleContentLB.text = memory.content
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmm"
            
            let date = dateFormatter.date(from: memory.visitedDate) ?? Date()
            dateFormatter.dateFormat = "MM월 dd일"
            
            let stringDate = dateFormatter.string(from: date)
            bubbleDateLB.text = stringDate
            
        }
        
    }
    
}
