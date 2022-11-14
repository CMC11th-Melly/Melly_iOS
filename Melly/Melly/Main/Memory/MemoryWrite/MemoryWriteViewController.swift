//
//  MemoryWriteViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/13.
//

import UIKit
import RxCocoa
import RxSwift
import Then
import Photos
import PhotosUI
import FloatingPanel

class MemoryWriteViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let vm:MemoryWriteViewModel
    
    lazy var scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
    }
    
    let contentView = UIView()
    let bottomView = UIView()
    
    lazy private var placeNameLB = UILabel().then {
        $0.text = vm.place.placeName
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 20)
    }
    
    lazy private var placeCategoryLB = UILabel().then {
        $0.text = vm.place.placeCategory
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let imageScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    let imageContentView = UIView()
    
    let imageButton = UIButton(type: .custom).then {
        $0.backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
        $0.layer.cornerRadius = 12
        
        let imgView = UIImageView(image: UIImage(named: "memory_addImage"))
        $0.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    let titleLB = UILabel().then {
        $0.text = "제목 *"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let titleTF = CustomTextField(title: "메모리 제목을 입력해주세요")
    
    let contentsLB = UILabel().then {
        $0.text = "메모리 작성 *"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let contentsTFView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
    }
    
    let placeHolder = "이 장소 메모리를 작성해보세요"
    
    lazy var contentsTF = UITextView().then {
        $0.text = placeHolder
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.delegate = self
    }
    
    let textCountLB = UILabel().then {
        $0.text = "0자 | 최소 20자"
        $0.textColor = UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
    }
    
    let groupLB = UILabel().then {
        $0.text = "그룹 설정 *"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    
    let groupPickerView = DropMenuButton()
    let filterPanel = FloatingPanelController()
    
    
    let dateLB = UILabel().then {
        $0.text = "날짜 *"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let dateBT = DatePickerButton(Date(), isTime: true)
    let timeBT = DatePickerButton(Date(), isTime: false)
    
    let starLB = UILabel().then {
        $0.text = "메모리 별점 *"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let oneStarBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_star"), for: .normal)
    }
    
    let twoStarBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_star"), for: .normal)
    }
    
    let threeStarBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_star"), for: .normal)
    }
    
    let fourStarBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_star"), for: .normal)
    }
    
    let fiveStarBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "memory_star"), for: .normal)
    }
    
    lazy var stackView = UIStackView(arrangedSubviews: [oneStarBT, twoStarBT, threeStarBT, fourStarBT, fiveStarBT]).then {
        $0.distribution = .fillEqually
    }
    
    let keywordLB = UILabel().then {
        $0.text = "내 기분 키워드"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let keywordDetailView = UILabel().then {
        $0.text = "이 메모리에서 느낀 내 기분은 어떤가요?"
        $0.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let keywordCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = true
        collectionView.allowsMultipleSelection = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let errorLable = AlertLabel().then {
        $0.alpha = 0
    }
    
    let cancelBT = DefaultButton("취소", false)
    let writeBT = DefaultButton("메모리 저장", true)
    
    
    init(vm: MemoryWriteViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setSV()
        bind()
        setNC()
    }
    
}

extension MemoryWriteViewController {
    
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
        
        safeArea.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        bottomView.addSubview(cancelBT)
        cancelBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(56)
            $0.width.equalTo((self.view.frame.width - 70) / 2)
        }
        
        bottomView.addSubview(writeBT)
        writeBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.trailing.equalToSuperview().offset(-30)
            $0.leading.equalTo(cancelBT.snp.trailing).offset(10)
            $0.height.equalTo(56)
        }
        
        safeArea.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        safeArea.addSubview(errorLable)
        errorLable.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top).offset(-18)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(placeNameLB)
        placeNameLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(imageScrollView)
        imageScrollView.snp.makeConstraints {
            $0.top.equalTo(placeNameLB.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(26)
            $0.height.equalTo(192)
            $0.trailing.equalToSuperview()
        }
        
        imageScrollView.addSubview(imageContentView)
        imageContentView.snp.makeConstraints {
            $0.height.centerY.top.bottom.equalToSuperview()
        }
        
        imageContentView.addSubview(imageButton)
        imageButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(4)
            $0.width.equalTo(330)
            $0.height.equalTo(170)
            $0.trailing.equalToSuperview().offset(-5)
        }
        
        contentView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalTo(imageScrollView.snp.bottom).offset(19)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(titleTF)
        titleTF.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(58)
        }
        
        contentView.addSubview(contentsLB)
        contentsLB.snp.makeConstraints {
            $0.top.equalTo(titleTF.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(textCountLB)
        textCountLB.snp.makeConstraints {
            $0.top.equalTo(titleTF.snp.bottom).offset(35)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        contentView.addSubview(contentsTFView)
        contentsTFView.snp.makeConstraints {
            $0.top.equalTo(contentsLB.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(160)
        }
        
        contentsTFView.addSubview(contentsTF)
        contentsTF.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        contentView.addSubview(groupLB)
        groupLB.snp.makeConstraints {
            $0.top.equalTo(contentsTFView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        
        contentView.addSubview(groupPickerView)
        groupPickerView.snp.makeConstraints {
            $0.top.equalTo(groupLB.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(58)
        }
        
        contentView.addSubview(dateLB)
        dateLB.snp.makeConstraints {
            $0.top.equalTo(groupPickerView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(dateBT)
        dateBT.snp.makeConstraints {
            $0.top.equalTo(dateLB.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(58)
            $0.width.equalTo((self.view.frame.width - 65) / 2)
        }
        
        contentView.addSubview(timeBT)
        timeBT.snp.makeConstraints {
            $0.top.equalTo(dateLB.snp.bottom).offset(15)
            $0.leading.equalTo(dateBT.snp.trailing).offset(5)
            $0.height.equalTo(58)
            $0.width.equalTo((self.view.frame.width - 65) / 2)
        }
        
        contentView.addSubview(starLB)
        starLB.snp.makeConstraints {
            $0.top.equalTo(timeBT.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(starLB.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(50)
        }
        
        contentView.addSubview(keywordLB)
        keywordLB.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(keywordDetailView)
        keywordDetailView.snp.makeConstraints {
            $0.top.equalTo(keywordLB.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(keywordCV)
        keywordCV.snp.makeConstraints {
            $0.top.equalTo(keywordDetailView.snp.bottom).offset(21)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview()
        }
        
        keywordCV.layoutIfNeeded()
        
        filterPanel.isRemovalInteractionEnabled = true
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        keywordCV.dataSource = nil
        keywordCV.delegate = nil
        keywordCV.rx.setDelegate(self).disposed(by: disposeBag)
        keywordCV.register(KeyWordCell.self, forCellWithReuseIdentifier: "cell")
        
        vm.rxKeywordData
            .bind(to: keywordCV.rx.items(cellIdentifier: "cell", cellType: KeyWordCell.self)) { row, element, cell in
                cell.configure(name: element)
            }.disposed(by: disposeBag)
        
        keywordCV.rx.itemSelected
            .map { index in
                let cell = self.keywordCV.cellForItem(at: index) as? KeyWordCell
                let text = cell?.titleLabel.text ?? "all"
                return text
            }.bind(to: vm.input.keywordObserver)
            .disposed(by: disposeBag)
        
        imageButton.rx.tap.subscribe(onNext: {
            let alert = UIAlertController(title: "사진 추가하기", message: nil, preferredStyle: .actionSheet)
            
            let pickerAction = UIAlertAction(title: "앨범에서 사진 선택", style: .default) { _ in
                var config = PHPickerConfiguration(photoLibrary: .shared())
                config.selectionLimit = 8
                config.filter = PHPickerFilter.any(of: [.images])
                let vc = PHPickerViewController(configuration: config)
                vc.delegate = self
                self.present(vc, animated: true)
            }
            
            let cameraAction = UIAlertAction(title: "사진 촬영하기", style: .default) { _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true)
            }
            
            let removeAction = UIAlertAction(title: "사진 삭제하기", style: .default) { _ in
                self.vm.input.imagesObserver.accept([])
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(pickerAction)
            alert.addAction(cameraAction)
            alert.addAction(removeAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            
        }).disposed(by: disposeBag)
        
        titleTF.textField.rx.controlEvent([.editingDidEnd])
            .map { self.titleTF.textField.text ?? "" }
            .bind(to: vm.input.titleObserver)
            .disposed(by: disposeBag)
        
        contentsTF.rx.didEndEditing
            .map { self.contentsTF.text ?? "" }
            .bind(to: vm.input.contentObserver)
            .disposed(by: disposeBag)
        
        dateBT.rx.tap
            .subscribe(onNext: {
                let datePicker = UIDatePicker()
                datePicker.datePickerMode = .date
                datePicker.preferredDatePickerStyle = .wheels
                datePicker.locale = Locale(identifier: "ko_KO")
                
                let dateAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                dateAlert.view.addSubview(datePicker)
                dateAlert.addAction(UIAlertAction(title: "선택 완료", style: .cancel, handler: { _ in
                    let date = datePicker.date
                    self.vm.input.dateObserver.accept(date)
                    self.dateBT.changeDate(date, isTime: true)
                }))
                let height : NSLayoutConstraint = NSLayoutConstraint(item: dateAlert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 300)
                dateAlert.view.addConstraint(height)
                
                self.present(dateAlert, animated: true)
            }).disposed(by: disposeBag)
        
        timeBT.rx.tap
            .subscribe(onNext: {
                let datePicker = UIDatePicker()
                datePicker.datePickerMode = .time
                datePicker.preferredDatePickerStyle = .wheels
                datePicker.locale = Locale(identifier: "ko_KO")
                
                let dateAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                dateAlert.view.addSubview(datePicker)
                dateAlert.addAction(UIAlertAction(title: "선택 완료", style: .cancel, handler: { _ in
                    let date = datePicker.date
                    self.vm.input.timeObserver.accept(date)
                    self.timeBT.changeDate(date, isTime: false)
                }))
                let height : NSLayoutConstraint = NSLayoutConstraint(item: dateAlert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 300)
                dateAlert.view.addConstraint(height)
                
                self.present(dateAlert, animated: true)
            }).disposed(by: disposeBag)
        
        
        oneStarBT.rx.tap
            .map { 0 }
            .bind(to: vm.input.starObserver)
            .disposed(by: disposeBag)
        
        twoStarBT.rx.tap
            .map { 1 }
            .bind(to: vm.input.starObserver)
            .disposed(by: disposeBag)
        
        threeStarBT.rx.tap
            .map { 2 }
            .bind(to: vm.input.starObserver)
            .disposed(by: disposeBag)
        
        fourStarBT.rx.tap
            .map { 3 }
            .bind(to: vm.input.starObserver)
            .disposed(by: disposeBag)
        
        fiveStarBT.rx.tap
            .map { 4 }
            .bind(to: vm.input.starObserver)
            .disposed(by: disposeBag)
        
        groupPickerView.rx.tap
            .subscribe(onNext: {
                let vc = MemoryWriteGroupPickerViewController(vm: self.vm)
                self.filterPanel.layout = MemoryDetailPanel()
                self.filterPanel.set(contentViewController: vc)
                self.filterPanel.addPanel(toParent: self)
            }).disposed(by: disposeBag)
        
        writeBT.rx.tap
            .bind(to: vm.input.writeObserver)
            .disposed(by: disposeBag)
        
        cancelBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        
        vm.output.starValue.asDriver(onErrorJustReturn: [false, false, false, false, false])
            .drive(onNext: { value in
                
                if value[0] {
                    self.oneStarBT.setImage(UIImage(named: "memory_star_fill"), for: .normal)
                } else {
                    self.oneStarBT.setImage(UIImage(named: "memory_star"), for: .normal)
                }
                
                if value[1] {
                    self.twoStarBT.setImage(UIImage(named: "memory_star_fill"), for: .normal)
                } else {
                    self.twoStarBT.setImage(UIImage(named: "memory_star"), for: .normal)
                }
                
                if value[2] {
                    self.threeStarBT.setImage(UIImage(named: "memory_star_fill"), for: .normal)
                } else {
                    self.threeStarBT.setImage(UIImage(named: "memory_star"), for: .normal)
                }
                
                if value[3] {
                    self.fourStarBT.setImage(UIImage(named: "memory_star_fill"), for: .normal)
                } else {
                    self.fourStarBT.setImage(UIImage(named: "memory_star"), for: .normal)
                }
                
                if value[4] {
                    self.fiveStarBT.setImage(UIImage(named: "memory_star_fill"), for: .normal)
                } else {
                    self.fiveStarBT.setImage(UIImage(named: "memory_star"), for: .normal)
                }
                
            }).disposed(by: disposeBag)
        
        vm.output.imagesValue.asDriver(onErrorJustReturn: [])
            .drive(onNext: { value in
                
                
                DispatchQueue.main.async {
                    self.imageContentView.subviews.forEach { $0.removeFromSuperview() }
                    self.viewDidLayoutSubviews()
                }
                
                if !value.isEmpty {
                    DispatchQueue.main.async {
                        self.imageContentView.subviews.forEach { $0.removeFromSuperview() }
                        let imagesView:[UIImageView] = {
                            var views:[UIImageView] = []
                            for image in value {
                                let imgView = UIImageView(image: image).then {
                                    $0.layer.cornerRadius = 12
                                    $0.clipsToBounds = true
                                    $0.contentMode = .scaleAspectFill
                                }
                                views.append(imgView)
                            }
                            return views
                        }()
                        
                        for i in 0..<value.count {
                            self.imageContentView.addSubview(imagesView[i])
                            if i == 0 {
                                imagesView[i].snp.makeConstraints {
                                    $0.top.equalToSuperview().offset(11)
                                    $0.leading.equalToSuperview().offset(5)
                                    $0.width.equalTo(330)
                                    $0.height.equalTo(170)
                                }
                            } else {
                                imagesView[i].snp.makeConstraints {
                                    $0.top.equalToSuperview().offset(11)
                                    $0.leading.equalTo(imagesView[i-1].snp.trailing).offset(5)
                                    $0.width.equalTo(330)
                                    $0.height.equalTo(170)
                                }
                            }
                        }
                        
                        self.imageContentView.addSubview(self.imageButton)
                        self.imageButton.snp.makeConstraints {
                            $0.top.equalToSuperview().offset(11)
                            $0.leading.equalTo(imagesView[imagesView.count-1].snp.trailing).offset(5)
                            $0.trailing.equalToSuperview()
                            $0.width.equalTo(330)
                            $0.height.equalTo(170)
                        }
                        
                        self.imageScrollView.contentSize = CGSize(width: 335 * (value.count + 1), height: 192)
                        self.viewDidLayoutSubviews()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.imageContentView.addSubview(self.imageButton)
                        self.imageButton.snp.makeConstraints {
                            $0.top.equalToSuperview().offset(11)
                            $0.leading.equalToSuperview().offset(4)
                            $0.width.equalTo(330)
                            $0.height.equalTo(170)
                            $0.trailing.equalToSuperview()
                        }
                        self.imageScrollView.contentSize = CGSize(width: 335, height: 192)
                        self.viewDidLayoutSubviews()
                        
                    }
                    
                    
                }
                
            }).disposed(by: disposeBag)
        
        vm.output.groupValue.subscribe(onNext: { value in
            if let value = value {
                self.groupPickerView.textLB.text = value.groupName
                self.groupPickerView.textLB.font = UIFont(name: "Pretendard-Regular", size: 16)
            }
            self.filterPanel.view.removeFromSuperview()
            self.filterPanel.removeFromParent()
        }).disposed(by: disposeBag)
        
        vm.output.errorValue.asDriver(onErrorJustReturn: "")
            .drive(onNext: { value in
                
                self.errorLable.labelView.text = value
                self.errorLable.alpha = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 1.5) {
                        self.errorLable.alpha = 0
                    }
                }
                
            }).disposed(by: disposeBag)
        
        vm.output.successValue.subscribe(onNext: {
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        vm.output.goToDisclosurePanel.subscribe(onNext: {
            let vc = DisclosurePopUpViewController(vm: self.vm)
            self.filterPanel.layout = MemoryDisclosurePanel()
            self.filterPanel.set(contentViewController: vc)
            self.filterPanel.addPanel(toParent: self)
        }).disposed(by: disposeBag)
        
        vm.output.cancelOpenType.subscribe(onNext: {
            self.filterPanel.view.removeFromSuperview()
            self.filterPanel.removeFromParent()
        }).disposed(by: disposeBag)
        
    }
    
    
}

//MARK: - CollectionView delegate
extension MemoryWriteViewController: UICollectionViewDelegateFlowLayout {
    
    //collectionView자체 latout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    }
    
    //행과 행사이의 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    //셀 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return KeyWordCell.fittingSize(availableHeight: 33, name: vm.keywordData[indexPath.item])
    }
    
    //2번 선택할 때 deselect 모드로 변경
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? KeyWordCell else {
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

//MARK: - PHPicker, UIImagePicker delegate
extension MemoryWriteViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //imagePicker에서 이미지 선택 시
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let group = DispatchGroup()
        var images:[UIImage] = []
        results.forEach { result in
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                images.append(image)
            }
        }
        
        group.notify(queue: .main) {
            self.vm.input.imagesObserver.accept(images)
        }
    }
    
    //imagePicker 취소 시
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    //카메라로 이미지 선택할 때
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true)
        vm.input.imagesObserver.accept([image])
        
    }
    
}


//MARK: - ScrollView, TextView Delegate
extension MemoryWriteViewController: UIScrollViewDelegate, UITextViewDelegate {
    
    //scrollView에서 스크롤이 시작되어도 키보드가 있으면 사라지게 함
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    //키보드 관련 이벤트를 scrollview에 설정
    func setSV() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
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
        scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
    }
    
    //키보드가 사라질때 scrollview의 inset 변경
    @objc func keyboardDidHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    //textView에 포커싱이 갈 때 호출
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolder {
            textView.text = nil
            textView.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        }
        contentsTFView.layer.borderColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1).cgColor
    }
    
    //textView에서 포커싱이 벗어날 때 호출
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeHolder
            textView.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
            updateCountLabel(characterCount: 0)
        }
        contentsTFView.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
    }
    
    //textView의 text가 바뀔 때 마다 호출
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)
        
        let characterCount = newString.count
        guard characterCount <= 700 else { return false }
        updateCountLabel(characterCount: characterCount)
        
        return true
    }
    
    
    //textView의 글자수를 최신화
    private func updateCountLabel(characterCount: Int) {
        textCountLB.text = "\(characterCount)자 | 최소 20자"
    }
    
}

final class KeyWordCell: UICollectionViewCell {
    
    static func fittingSize(availableHeight: CGFloat, name: String) -> CGSize {
        let cell = KeyWordCell()
        cell.configure(name: name)
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    let titleLabel: UILabel = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 1.2
        layer.borderColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1).cgColor
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().offset(-8)
            $0.trailing.equalToSuperview().offset(-15)
        }
    }
    
    func configure(name: String) {
        titleLabel.text = name
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
                titleLabel.textColor = .white
            } else {
                backgroundColor = .white
                titleLabel.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
            }
        }
    }
}

class MemoryDetailPanel: FloatingPanelLayout{
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 383, edge: .bottom, referenceGuide: .superview)
        ]
    }
}

class MemoryDisclosurePanel: FloatingPanelLayout{
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 413, edge: .bottom, referenceGuide: .superview)
        ]
    }
}


class MemoryWriteGroupPickerViewController: UIViewController {
    
    let vm:MemoryWriteViewModel
    
    var selectGroup:Group? {
        didSet {
            if selectGroup == nil {
                saveBT.isEnabled = false
            } else {
                saveBT.isEnabled = true
            }
        }
    }
    
    private let disposeBag = DisposeBag()
    
    let contentView = UIView()
    
    let groupCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let bottomView = UIView()
    let cancelBT = DefaultButton("취소", false)
    let saveBT = CustomButton(title: "저장").then {
        $0.isEnabled = false
    }
    
    init(vm: MemoryWriteViewModel) {
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
    }
    
    private func setUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(381)
        }
        
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(105)
        }
        
        bottomView.addSubview(cancelBT)
        cancelBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(56)
            $0.width.equalTo((self.view.frame.width-70)/2)
        }
        
        bottomView.addSubview(saveBT)
        saveBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
            $0.width.equalTo((self.view.frame.width-70)/2)
        }
        
        contentView.addSubview(groupCV)
        groupCV.snp.makeConstraints {
            $0.top.equalToSuperview().offset(33)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
    }
    
    private func setCV() {
        groupCV.delegate = self
        groupCV.dataSource = self
        groupCV.register(SelectGroupCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    private func bind() {
        
        saveBT.rx.tap
            .map { self.selectGroup }
            .bind(to: vm.input.groupObserver)
            .disposed(by: disposeBag)
        
        cancelBT.rx.tap
            .map { nil }
            .bind(to: vm.input.groupObserver)
            .disposed(by: disposeBag)
        
        
    }
    
    
    
}


extension MemoryWriteGroupPickerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.groupData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelectGroupCell
        cell.group = self.vm.groupData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectGroup = vm.groupData[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectGroupCell else {
            return true
        }
        if cell.isSelected {
            collectionView.deselectItem(at: indexPath, animated: true)
            selectGroup = nil
            return false
        } else {
            return true
        }
    }
    
    
    
}

class SelectGroupCell: UICollectionViewCell {
    
    var group:Group? {
        didSet {
            setData()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
            } else {
                backgroundColor = .white
            }
        }
    }
    
    let groupTypeLB = UILabel().then {
        $0.clipsToBounds = true
        $0.textColor = .white
        $0.layer.cornerRadius = 4
        $0.textAlignment = .center
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
    }
    
    let groupNameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .white
        
        addSubview(groupTypeLB)
        groupTypeLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(47)
            $0.height.equalTo(19)
            $0.width.equalTo(29)
        }
        
        addSubview(groupNameLB)
        groupNameLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(groupTypeLB.snp.trailing).offset(10)
            $0.height.equalTo(19)
        }
        
    }
    
    private func setData() {
        if let group = group {
            groupNameLB.text = group.groupName
            
            switch group.groupType {
            case "FAMILY":
                groupTypeLB.text = "가족"
                groupTypeLB.backgroundColor = UIColor(red: 0.337, green: 0.29, blue: 0.898, alpha: 1)
            case "COUPLE":
                groupTypeLB.text = "연인"
                groupTypeLB.backgroundColor = UIColor(red: 0.941, green: 0.259, blue: 0.322, alpha: 1)
            case "COMPANY":
                groupTypeLB.text = "동료"
                groupTypeLB.backgroundColor = UIColor(red: 0.278, green: 0.494, blue: 0.922, alpha: 1)
            case "FRIEND":
                groupTypeLB.text = "친구"
                groupTypeLB.backgroundColor = UIColor(red: 0.221, green: 0.679, blue: 0.459, alpha: 1)
            default:
                break
            }
            
            
        }
        
    }
    
}

