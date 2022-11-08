//
//  ScrapDetailViewController.swift
//  Melly
//
//  Created by Jun on 2022/11/04.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class ScrapDetailViewController: UIViewController {

    let vm = MyScrapViewModel.instance
    private let disposeBag = DisposeBag()
    
    let headerView = UIView()
    let backBT = BackButton()
    var loadingView:FooterLoadingView?
    var isLoading = false
    var places:[Place] = []
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.102, green: 0.118, blue: 0.153, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "스크랩"
    }
    
    let dataCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let rightAlert = RightAlert().then {
        $0.alpha = 0
        $0.labelView.text = "장소 스크랩 취소"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.places = []
        self.vm.scrapOption.page = 0
        self.vm.scrapOption.isEnd = false
        vm.input.refreshPlaceObserver.accept(())
    }
    

   
}

extension ScrapDetailViewController {
    
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
        }
        
        headerView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.height.equalTo(24)
            $0.leading.equalTo(backBT.snp.trailing).offset(12)
        }
        
        safeArea.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
        }
        
        safeArea.addSubview(rightAlert)
        rightAlert.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-45)
        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        dataCV.delegate = self
        dataCV.dataSource = self
        dataCV.register(ScrapPlaceCell.self, forCellWithReuseIdentifier: "cell")
        dataCV.register(FooterLoadingView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterLoadingView.identifier)
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        
        vm.output.placeValue.asDriver(onErrorJustReturn: [])
            .drive(onNext: { value in
                DispatchQueue.main.async {
                    self.places += value
                    self.dataCV.reloadData()
                    self.isLoading = false
                }
            }).disposed(by: disposeBag)
        
        vm.output.removeBookmark
            .subscribe(onNext: {
                self.places = []
                self.vm.input.refreshPlaceObserver.accept(())
                self.rightAlert.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 1.5) {
                        self.rightAlert.alpha = 0
                    }
                }
            }).disposed(by: disposeBag)
        
    }
    
}

extension ScrapDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    //collectionview cell의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    //collectionView cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ScrapPlaceCell
        cell.place = places[indexPath.row]
        return cell
    }
    
    //collectionView 자체의 레이아웃
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //열과 열 사이의 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 26
        
    }
    
    //셀 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width - 60
        return CGSize(width: width, height: 172)
    }
    
    //footer 인디케이터 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoading || vm.scrapOption.isEnd {
            return CGSize.zero
        } else {
            return CGSize(width: dataCV.bounds.size.width, height: 55)
        }
    }
    
    //셀 선택시 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let vm = MemoryListViewModel(place: place)
        let vc = MemoryListViewController(vm: vm)
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
        
        if !vm.scrapOption.isEnd && !self.isLoading && places.count-1 == indexPath.row {
            
            self.isLoading = true
            DispatchQueue.global().async {
                sleep(1)
                self.vm.input.refreshPlaceObserver.accept(())
            }
        }
    }
    
    
    
}

final class ScrapPlaceCell: UICollectionViewCell {
    
    let vm = MyScrapViewModel.instance
    private let disposeBag = DisposeBag()
    var place:Place? {
        didSet {
            setData()
        }
    }
    
    let imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.isUserInteractionEnabled = true
    }
    
    let bookmarkBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "bookmark_fill"), for: .normal)
    }
    
    let locationNameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 18)
    }
    
    let locationCategoryLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let myMemoryLB = BasePaddingLabel(title: "내 메모리 5개")
    
    let ourMemoryLB = BasePaddingLabel(title: "이 장소에 저장된 메모리 20개")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }
    
    private func setupView() {
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        imageView.addSubview(bookmarkBT)
        bookmarkBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.trailing.equalToSuperview().offset(-15)
            $0.width.height.equalTo(24)
        }
        
        addSubview(locationNameLB)
        locationNameLB.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(4)
            $0.height.equalTo(25)
        }
        
        addSubview(locationCategoryLB)
        locationCategoryLB.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(19)
            $0.leading.equalTo(locationNameLB.snp.trailing).offset(7)
            $0.trailing.lessThanOrEqualToSuperview().offset(-4)
            $0.height.equalTo(20)
        }
        
        addSubview(myMemoryLB)
        myMemoryLB.snp.makeConstraints {
            $0.top.equalTo(locationNameLB.snp.bottom).offset(6)
            $0.leading.equalToSuperview()
        }
        
        addSubview(ourMemoryLB)
        ourMemoryLB.snp.makeConstraints {
            $0.top.equalTo(locationNameLB.snp.bottom).offset(6)
            $0.leading.equalTo(myMemoryLB.snp.trailing).offset(7)
        }
        
        
    }
    
    private func setData() {
        
        if let place = place {
            
            if let urlString = place.placeImage {
                let url = URL(string: urlString)!
                imageView.kf.setImage(with: url)
            } else {
                //기본 이미지 등록
            }
            
            locationNameLB.text = place.placeName
            locationCategoryLB.text = place.placeCategory
            
            if place.myMemoryCount == 0 && place.otherMemoryCount == 0 {
                myMemoryLB.text = "장소에 저장된 메모리가 없어요"
                ourMemoryLB.isHidden = true
            } else {
                ourMemoryLB.isHidden = false
                if place.myMemoryCount == 0 {
                    myMemoryLB.text = "장소에 저장된 메모리가 없어요"
                } else {
                    myMemoryLB.text = "내 메모리 \(place.myMemoryCount)개"
                }
                
                if place.otherMemoryCount == 0 {
                    ourMemoryLB.text = "장소에 저장된 메모리가 없어요"
                } else {
                    ourMemoryLB.text = "이 장소에 저장된 메모리 \(place.otherMemoryCount)개"
                }
                
            }
            layoutIfNeeded()
        
        }
        
    }
    
    private func bind() {
        bookmarkBT.rx.tap
            .map { self.place! }
            .bind(to: vm.input.removeBookmarkObserver)
            .disposed(by: disposeBag)
        
    }
    
    
}

