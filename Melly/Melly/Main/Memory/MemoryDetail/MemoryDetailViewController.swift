//
//  MemoryDetailViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/23.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import Kingfisher

class MemoryDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    let vm:MemoryDetailViewModel
    var commentFooterView:CommentFooterView?
    var commentHeaderView:CommentHeaderView?
    
    
    lazy var imagePageView = UIScrollView().then {
        $0.delegate = self
        $0.isScrollEnabled = true
        $0.isPagingEnabled = true
    }
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    let contentView = UIView()
    
    let backBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_back"), for: .normal)
    }
    
    let editBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_dot"), for: .normal)
    }
    
    lazy var imageCountLB = UILabel().then {
        $0.text = "1/\(vm.memory.memoryImages.count)"
        $0.textAlignment = .center
        $0.backgroundColor = UIColor(red: 0.102, green: 0.118, blue: 0.153, alpha: 0.8)
        $0.layer.cornerRadius = 8
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
    }
    
    lazy var titleLB = UILabel().then {
        $0.text = vm.memory.title
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 20)
    }
    
    let shareBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_share"), for: .normal)
    }
    
    lazy var placeLB = UILabel().then {
        $0.text = vm.memory.placeName
        $0.textColor = UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
    }
    
    lazy var visitedLB = UILabel().then {
        let text = vm.memory.visitedDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHss"
        dateFormatter.locale = Locale(identifier: "ko_KO")
        let date = dateFormatter.date(from: text) ?? Date()
        dateFormatter.dateFormat = "yyyy. MM. dd a HH:mm"
        $0.text = dateFormatter.string(from: date)
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 12)
    }
    
    let separateOne = UIView().then {
        $0.backgroundColor = UIColor(red: 0.835, green: 0.852, blue: 0.875, alpha: 1)
    }
    
    lazy var starOneImageView = UIImageView().then {
        $0.image = vm.memory.stars >= 1 ? UIImage(named: "memory_star_fill") : UIImage(named: "memory_star")
        
    }
    
    lazy var starTwoImageView = UIImageView().then {
        $0.image = vm.memory.stars >= 2 ? UIImage(named: "memory_star_fill") : UIImage(named: "memory_star")
    }
    
    lazy var starThreeImageView = UIImageView().then {
        $0.image = vm.memory.stars >= 3 ? UIImage(named: "memory_star_fill") : UIImage(named: "memory_star")
    }
    
    lazy var starFourImageView = UIImageView().then {
        $0.image = vm.memory.stars >= 4 ? UIImage(named: "memory_star_fill") : UIImage(named: "memory_star")
    }
    
    lazy var starFiveImageView = UIImageView().then {
        $0.image = vm.memory.stars >= 5 ? UIImage(named: "memory_star_fill") : UIImage(named: "memory_star")
    }
    
    lazy var stackView = UIStackView(arrangedSubviews: [starOneImageView, starTwoImageView, starThreeImageView, starFourImageView, starFiveImageView]).then {
        $0.distribution = .fillEqually
    }
    
    let separatorTwo = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    lazy var groupIconView = UIImageView().then {
        $0.image = UIImage(systemName: "heart.text.square.fill")
    }
    
    lazy var groupNameLB = UILabel().then {
        $0.text = vm.memory.groupName
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let groupSubLB = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.text = "와(과) 메모리를 쌓았어요"
    }
    
    let separatorThree = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    lazy var contentLB = UILabel().then {
        $0.text = vm.memory.content
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.numberOfLines = 0
    }
    
    let keywordCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let separatorFour = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let commentCountLB = UILabel().then {
        $0.text = "총 0개의 댓글"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 12)
    }
    
    let commentCV:DynamicHeightCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = DynamicHeightCollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let bottomView = UIView()
    
    let commentTF = CommentTextField(title: "댓글을 입력해주세요.")
    
    init(vm: MemoryDetailViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        addContentScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setCV()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.refreshComment.accept(())
    }
    
}

extension MemoryDetailViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        safeArea.backgroundColor = .clear
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(imagePageView)
        imagePageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(289)
        }
        
        contentView.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalTo(safeArea.snp.top).offset(11)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(editBT)
        editBT.snp.makeConstraints {
            $0.top.equalTo(safeArea.snp.top).offset(11)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        contentView.addSubview(imageCountLB)
        imageCountLB.snp.makeConstraints {
            $0.bottom.equalTo(imagePageView.snp.bottom).offset(-20)
            $0.trailing.equalToSuperview().offset(-28)
        }
        
        contentView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalTo(imagePageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(34)
        }
        
        contentView.addSubview(shareBT)
        shareBT.snp.makeConstraints {
            $0.top.equalTo(imagePageView.snp.bottom).offset(26)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        contentView.addSubview(placeLB)
        placeLB.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(13)
            $0.leading.equalToSuperview().offset(34)
        }
        
        contentView.addSubview(visitedLB)
        visitedLB.snp.makeConstraints {
            $0.top.equalTo(placeLB.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(34)
        }
        
        contentView.addSubview(separateOne)
        separateOne.snp.makeConstraints {
            $0.top.equalTo(placeLB.snp.bottom).offset(6)
            $0.leading.equalTo(visitedLB.snp.trailing).offset(8)
            $0.width.equalTo(1)
            $0.height.equalTo(12)
        }
        
        contentView.addSubview(separatorTwo)
        separatorTwo.snp.makeConstraints {
            $0.top.equalTo(visitedLB.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        contentView.addSubview(groupIconView)
        groupIconView.snp.makeConstraints {
            $0.top.equalTo(separatorTwo.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(34)
            $0.width.height.equalTo(30)
        }
        
        contentView.addSubview(groupNameLB)
        groupNameLB.snp.makeConstraints {
            $0.top.equalTo(separatorTwo.snp.bottom).offset(20)
            $0.leading.equalTo(groupIconView.snp.trailing).offset(9)
        }
        
        contentView.addSubview(groupSubLB)
        groupSubLB.snp.makeConstraints {
            $0.top.equalTo(separatorTwo.snp.bottom).offset(20)
            $0.leading.equalTo(groupNameLB.snp.trailing).offset(4)
        }
        
        contentView.addSubview(separatorThree)
        separatorThree.snp.makeConstraints {
            $0.top.equalTo(groupSubLB.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(12)
        }
        
        contentView.addSubview(contentLB)
        contentLB.snp.makeConstraints {
            $0.top.equalTo(separatorThree.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        contentView.addSubview(keywordCV)
        keywordCV.snp.makeConstraints {
            $0.top.equalTo(contentLB.snp.bottom).offset(39)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        contentView.addSubview(separatorFour)
        separatorFour.snp.makeConstraints {
            $0.top.equalTo(keywordCV.snp.bottom).offset(33)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(12)
        }
        
        contentView.addSubview(commentCountLB)
        commentCountLB.snp.makeConstraints {
            $0.top.equalTo(separatorFour.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(commentCV)
        commentCV.snp.makeConstraints {
            $0.top.equalTo(commentCountLB.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(500)
            
        }
        
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.top.equalTo(commentCV.snp.bottom)
            $0.height.equalTo(95)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomView.addSubview(commentTF)
        commentTF.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(54)
        }
        
        
        
    }
    
    private func setCV() {
        
        keywordCV.dataSource = nil
        keywordCV.delegate = nil
        keywordCV.rx.setDelegate(self).disposed(by: disposeBag)
        keywordCV.register(KeyWordCell.self, forCellWithReuseIdentifier: "keyword")
        vm.keywordData
            .bind(to: keywordCV.rx.items(cellIdentifier: "keyword", cellType: KeyWordCell.self)) { row, element, cell in
                cell.configure(name: element)
            }.disposed(by: disposeBag)
        
        commentCV.delegate = self
        commentCV.dataSource = self
        commentCV.register(CommentCell.self, forCellWithReuseIdentifier: "comment")
        commentCV.register(CommentFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CommentFooterView.identifier)
        commentCV.register(CommentHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommentHeaderView.identifier)
        
    }
    
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        backBT.rx.tap.subscribe(onNext: {
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        
    }
    
    private func bindOutput() {
        
        vm.output.commentCountValue.subscribe(onNext: { value in
            self.commentCountLB.text = "총 \(value)개의 댓글"
        }).disposed(by: disposeBag)
        
        vm.output.completeRefresh.asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                self.commentCV.reloadData()
            }).disposed(by: disposeBag)
        
    }
    
}

//MARK: - CollectionView delegate
extension MemoryDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    //collectionview cell의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.comment.count
    }
    
    //collectionView cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "comment", for: indexPath) as! CommentCell
        cell.comment = vm.comment[indexPath.row]
        cell.vm = vm
        return cell
    }
    
    //collectionView 자체의 레이아웃
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == keywordCV {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    //행과 행사이의 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == keywordCV {
            return 9
        } else {
            return 0
        }
        
    }
    
    //열과 열 사이의 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == commentCV {
            return 20
        } else {
           return 20
        }
       
    }
    
    //셀 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == keywordCV {
            return KeyWordCell.fittingSize(availableHeight: 33, name: vm.memory.keyword[indexPath.item])
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "comment", for: indexPath) as! CommentCell
            cell.comment = vm.comment[indexPath.row]
            cell.vm = vm
            
            return CGSize(width: view.frame.width, height: cell.getSize())
        }
        
    }
    
    //footer 인디케이터 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if collectionView == commentCV {
            if vm.isRecommented {
                return CGSize(width: commentCV.bounds.size.width, height: 40)
            } else {
                return CGSize.zero
            }
        } else {
            return CGSize.zero
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == commentCV {
            
            if vm.comment.isEmpty {
                return CGSize(width: commentCV.bounds.size.width, height: 22)
            } else {
                return CGSize.zero
            }
            
        } else {
            return CGSize.zero
        }
        
        
    }
    
    
    //footer(인디케이터) 배경색 등 상세 설정
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView == commentCV {
            if kind == UICollectionView.elementKindSectionFooter {
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommentFooterView.identifier, for: indexPath) as! CommentFooterView
                commentFooterView = footerView
                return footerView
            } else if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommentHeaderView.identifier, for: indexPath) as! CommentHeaderView
                commentHeaderView = headerView
                return headerView
            }
        }
        
        return UICollectionReusableView()
    }
    
    
}


extension MemoryDetailViewController: UIScrollViewDelegate {
    
    private func addContentScrollView() {
        DispatchQueue.main.async {
            for i in 0..<self.vm.memory.memoryImages.count {
                let imageView = UIImageView()
                let xPos = self.view.frame.width * CGFloat(i)
                imageView.frame = CGRect(x: xPos, y: 0, width: self.imagePageView.bounds.width, height: self.imagePageView.bounds.height)
                let url = URL(string: self.vm.memory.memoryImages[i].memoryImage)!
                
                imageView.kf.setImage(with: url)
                self.imagePageView.addSubview(imageView)
                self.imagePageView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
            }
            self.viewDidLayoutSubviews()
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = imagePageView.contentOffset.x/imagePageView.frame.size.width
        imageCountLB.text = "\(Int(round(value)))/\(vm.memory.memoryImages.count)"
    }
    
}
