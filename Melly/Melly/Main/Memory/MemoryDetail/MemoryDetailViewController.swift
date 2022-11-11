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
import FirebaseDynamicLinks

class MemoryDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    let vm:MemoryDetailViewModel
    var commentFooterView:CommentFooterView?
    var commentHeaderView:CommentHeaderView?
    
    lazy var pageControl = UIPageControl().then {
        $0.numberOfPages = vm.memory.memoryImages.count
        $0.currentPage = 0
    }
    
    lazy var imagePageView = UIScrollView().then {
        $0.delegate = self
        $0.isScrollEnabled = true
        $0.isPagingEnabled = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        
    }
    lazy var scrollView = UIScrollView().then {
        $0.delegate = self
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
        if vm.memory.memoryImages.count == 1 {
            $0.isHidden = true
        }
        $0.textAlignment = .center
        $0.backgroundColor = UIColor(red: 0.122, green: 0.141, blue: 0.173, alpha: 0.8)
        $0.layer.cornerRadius = 8
        $0.textColor = .white
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.clipsToBounds = true
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
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
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
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
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
        $0.image = UIImage(named: "group_icon_1")
    }
    
    lazy var groupNameLB = UILabel().then {
        $0.text = vm.memory.groupName
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let groupSubLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.text = "와(과) 메모리를 쌓았어요"
    }
    
    let separatorThree = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    lazy var contentLB = UILabel().then {
        $0.text = vm.memory.content
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Regular", size: 15)
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
    
    lazy var commentCV:DynamicHeightCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: "comment")
        collectionView.register(CommentFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CommentFooterView.identifier)
        collectionView.register(CommentHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommentHeaderView.identifier)
        return collectionView
    }()
    
    let bottomView = UIView()
    
    let commentTF = CommentTextField(title: "댓글을 입력해주세요.")
    
    let errorAlert = AlertLabel().then {
        $0.alpha = 0
    }
    
    let keyboardView = UIView()
    
    
    init(vm: MemoryDetailViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setCV()
        bind()
        setSV()
        setNC()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.refreshComment.accept(())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addContentScrollView()
    }
    
}

extension MemoryDetailViewController {

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
        safeArea.backgroundColor = .clear
        
        safeArea.addSubview(imagePageView)
        imagePageView.snp.makeConstraints {
            $0.top.equalTo(self.view)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(289)
        }
        imagePageView.addSubview(pageControl)
        
        view.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalTo(safeArea.snp.top).offset(11)
            $0.leading.equalToSuperview().offset(30)
        }
        
        view.addSubview(editBT)
        editBT.snp.makeConstraints {
            $0.top.equalTo(safeArea.snp.top).offset(11)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        view.addSubview(imageCountLB)
        imageCountLB.snp.makeConstraints {
            $0.bottom.equalTo(imagePageView.snp.bottom).offset(-20)
            $0.trailing.equalToSuperview().offset(-28)
            $0.width.equalTo(37)
            $0.height.equalTo(24)
        }
        
        safeArea.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(imagePageView.snp.bottom)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(34)
            $0.height.equalTo(28)
        }
        
        contentView.addSubview(shareBT)
        shareBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.width.equalTo(24)
        }
        
        contentView.addSubview(placeLB)
        placeLB.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(13)
            $0.leading.equalToSuperview().offset(34)
            $0.height.equalTo(22)
        }
        
        contentView.addSubview(visitedLB)
        visitedLB.snp.makeConstraints {
            $0.top.equalTo(placeLB.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(34)
            $0.height.equalTo(19)
        }
        
        contentView.addSubview(separateOne)
        separateOne.snp.makeConstraints {
            $0.top.equalTo(placeLB.snp.bottom).offset(6)
            $0.leading.equalTo(visitedLB.snp.trailing).offset(8)
            $0.width.equalTo(1)
            $0.height.equalTo(12)
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(placeLB.snp.bottom).offset(3)
            $0.leading.equalTo(separateOne.snp.trailing).offset(9)
            $0.height.equalTo(16)
            $0.width.equalTo(95.36)
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
            $0.height.equalTo(19)
        }
        
        contentView.addSubview(groupSubLB)
        groupSubLB.snp.makeConstraints {
            $0.top.equalTo(separatorTwo.snp.bottom).offset(20)
            $0.leading.equalTo(groupNameLB.snp.trailing).offset(4)
            $0.height.equalTo(19)
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
            $0.height.equalTo(600)
            
        }
        
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.top.equalTo(commentCV.snp.bottom)
            $0.height.equalTo(95)
            $0.leading.trailing.equalToSuperview()
        }
        
        bottomView.addSubview(commentTF)
        commentTF.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(keyboardView)
        keyboardView.snp.makeConstraints {
            $0.top.equalTo(commentTF.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        
        view.addSubview(errorAlert)
        errorAlert.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-47)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
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
        
    }
    
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        backBT.rx.tap.subscribe(onNext: {
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        commentTF.rightButton.rx.tap
            .map ( {
                self.view.endEditing(true)
               return self.commentTF.textField.text
            })
            .bind(to: vm.input.textFieldEditObserver)
            .disposed(by: disposeBag)
        
        shareBT.rx.tap.asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                self.createDynamicLink()
            }).disposed(by: disposeBag)
            
        
        
        editBT.rx.tap
            .subscribe(onNext: {
                
                let alert = UIAlertController(title: "메모리 메뉴", message: nil, preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(title: "메모리 삭제", style: .default) { _ in
                    self.vm.output.isDeleteMemory.accept(())
                }
                
//                let editAction = UIAlertAction(title: "메모리 수정", style: .default) { _ in
//
//                }
                
                let reportAction = UIAlertAction(title: "메모리 신고", style: .default) { _ in
                    let vm = ReportViewModel()
                    vm.memory = self.vm.memory
                    let vc = ReportViewController(vm: vm)
                    vc.detailVm = self.vm
                    vc.modalTransitionStyle = .coverVertical
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                    
                }
                
                let rejectAction = UIAlertAction(title: "메모리 차단", style: .default) { _ in
                    self.vm.input.blockMemoryObserver.accept(())
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                
                if self.vm.memory.loginUserWrite {
                    alert.addAction(deleteAction)
                    //alert.addAction(editAction)
                }
                alert.addAction(reportAction)
                alert.addAction(rejectAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
                
            }).disposed(by: disposeBag)
                
        
    }
    
    private func bindOutput() {
        
        vm.output.commentCountValue.subscribe(onNext: { value in
            self.commentCountLB.text = "총 \(value)개의 댓글"
        }).disposed(by: disposeBag)
        
        vm.output.completeRefresh.asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                
                DispatchQueue.main.async {
                    self.commentTF.textField.text = nil
                    self.commentCV.reloadData()
                    self.commentCV.layoutSubviews()
                    self.commentCV.snp.updateConstraints {
                        $0.height.equalTo(self.commentCV.intrinsicContentSize.height)
                    }
                    print(self.commentCV.intrinsicContentSize.height)
                                        
                }
                
            }).disposed(by: disposeBag)
        
        vm.output.isDeleteMemory.asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                
                let alert = UIAlertController(title: "정말 삭제하시겠어요?", message: "메모리를 삭제하면 다시 복구할 수 없어요", preferredStyle: .alert)
                
                let deleteAction = UIAlertAction(title: "확인", style: .default) { _ in
                    self.vm.input.deleteMemoryObserver.accept(())
                }
            
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                
                alert.addAction(cancelAction)
                alert.addAction(deleteAction)
                self.present(alert, animated: true)
                
            }).disposed(by: disposeBag)
        
        vm.output.completeDelete
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.errorValue
            .subscribe(onNext: { value in
                self.errorAlert.labelView.text = value
                self.errorAlert.alpha = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIView.animate(withDuration: 1.5) {
                        self.errorAlert.alpha = 0
                    }
                }
                
            }).disposed(by: disposeBag)
        
        vm.output.commentEdit
            .subscribe(onNext: { value in
                
                let alert = UIAlertController(title: "메모리 메뉴", message: nil, preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(title: "댓글 삭제", style: .default) { _ in
                    let alert = UIAlertController(title: "정말 삭제하시겠어요?", message: "메모리를 삭제하면 다시 복구할 수 없어요", preferredStyle: .alert)
                    
                    let deleteAction = UIAlertAction(title: "확인", style: .default) { _ in
                        self.vm.input.commentDeleteObserver.accept(value)
                    }
                
                    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                    
                    alert.addAction(cancelAction)
                    alert.addAction(deleteAction)
                    self.present(alert, animated: true)
                }
                
                let reportAction = UIAlertAction(title: "댓글 신고", style: .default) { _ in
                    let vm = ReportViewModel()
                    vm.comment = value
                    let vc = ReportViewController(vm: vm)
                    vc.detailVm = self.vm
                    vc.modalTransitionStyle = .coverVertical
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                    
                }
                
                let blockAction = UIAlertAction(title: "댓글 차단", style: .default) { _ in
                    self.vm.input.blockCommentObserver.accept(value)
                }
                
                let editAction = UIAlertAction(title: "댓글 수정", style: .default) { _ in
                    self.vm.input.reviseCommentObserver.accept(value)
                }
                
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                
                if value.loginUserWrite {
                    alert.addAction(deleteAction)
                    alert.addAction(editAction)
                }
                
                alert.addAction(blockAction)
                alert.addAction(reportAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
                
            }).disposed(by: disposeBag)
        
        vm.output.commentRevise.subscribe(onNext: { value in
            self.commentTF.textField.text = value.content
            self.vm.input.refreshComment.accept(())
            
            
        }).disposed(by: disposeBag)
        
    }
    
    func createDynamicLink() {
            let link = URL(string: "https://cmc11th.page.link/share_memory?memoryId=\(vm.memory.memoryId)")
            let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://cmc11th.page.link")
            
            // iOS 설정
            referralLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.neordinary.CMC11th.Melly")
            referralLink?.iOSParameters?.minimumAppVersion = "1.0.0"
            referralLink?.iOSParameters?.appStoreID = "6444202109"
            
            referralLink?.shorten { (shortURL, warnings, error) in
                
                if let error = error {
                    print(error)
                }
                
                if let shortURL = shortURL {
                    let object = [shortURL]
                    let activityVC = UIActivityViewController(activityItems: object, applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = self.view
                    self.present(activityVC, animated: true, completion: nil)
                }
                
            }
        
        
    }
    
}

//MARK: - ScrollView, TextView Delegate
extension MemoryDetailViewController: UIScrollViewDelegate {
    
    //scrollView에서 스크롤이 시작되어도 키보드가 있으면 사라지게 함
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.view.endEditing(true)
//    }
//
    //키보드 관련 이벤트를 scrollview에 설정
    func setSV() {
        
//        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapMethod))
//        singleTapGestureRecognizer.numberOfTapsRequired = 1
//        singleTapGestureRecognizer.isEnabled = true
//
//        singleTapGestureRecognizer.cancelsTouchesInView = false
//
//        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidShow(notification:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidHide(notification:)),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    //키보드 이외에 다른 곳을 터치할 때 키보드 사라지게 하기
    @objc func myTapMethod(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //키보드가 나타날 때 scrollview의 inset 변경
    @objc func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo
        let keyBoardSize = info![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        
        keyboardView.snp.remakeConstraints {
            $0.top.equalTo(commentTF.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(10)
            
        }
        
        scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
    }
    
    //키보드가 사라질때 scrollview의 inset 변경
    @objc func keyboardDidHide(notification: NSNotification) {
        
        keyboardView.snp.remakeConstraints {
            $0.top.equalTo(commentTF.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
            
        }
        
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    private func addContentScrollView() {
        DispatchQueue.main.async {
            for i in 0..<self.vm.memory.memoryImages.count {
                
                let imageView = UIImageView()
                let xPos = self.view.frame.width * CGFloat(i)
                imageView.frame = CGRect(x: xPos, y: 0, width: self.imagePageView.bounds.width, height: self.imagePageView.bounds.height)
                imageView.contentMode = .scaleAspectFill
                let url = URL(string: self.vm.memory.memoryImages[i].memoryImage)!
                
                imageView.kf.setImage(with: url)
                self.imagePageView.addSubview(imageView)
                
                
            }
            self.imagePageView.contentSize.width = self.view.frame.width * CGFloat(self.vm.memory.memoryImages.count)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == imagePageView {
            let value = imagePageView.contentOffset.x/UIScreen.main.bounds.width
            pageControl.currentPage = Int(value)
            imageCountLB.text = "\(Int(round(value))+1)/\(vm.memory.memoryImages.count)"
        }
        
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
            cell.commentView.commentLB.sizeToFit()
            let height = cell.commentView.commentLB.frame.height + 76
            return CGSize(width: self.view.frame.width, height: height)
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


