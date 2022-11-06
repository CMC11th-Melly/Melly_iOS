//
//  ReportViewController.swift
//  Melly
//
//  Created by Jun on 2022/11/05.
//

import UIKit
import RxCocoa
import RxSwift

class ReportViewController: UIViewController {
    
    let headerView = UIView()
    let vm:ReportViewModel
    var detailVm:MemoryDetailViewModel?
    
    private let disposeBag = DisposeBag()
    
    let backBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "search_x"), for: .normal)
    }
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "신고하기"
    }
    
    let reportIcon = UIImageView(image: UIImage(named: "report_icon"))
    
    let reportTitle = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.text = "사유에 맞지 않는 신고는 반영되지 않을 수 있습니다"
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.delegate = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    let contentView = UIView()
    
    let textCountLB = UILabel().then {
        $0.text = "0자 | 최소 20자"
        $0.textColor = UIColor(red: 0.4, green: 0.435, blue: 0.486, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.alpha = 0
    }
    
    let cvTitleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        $0.text = "신고 유형"
    }
    
    let dataCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let bottomView = UIView()
    
    let reportBT = CustomButton(title: "신고하기").then {
        $0.isEnabled = false
    }
    
    var mode = false {
        didSet {
            if mode {
                separatorTwo.alpha = 1
                cvEtcTitleLB.alpha = 1
                contentsTF.alpha = 1
                contentsTFView.alpha = 1
                textCountLB.alpha = 1
            } else {
                separatorTwo.alpha = 0
                cvEtcTitleLB.alpha = 0
                contentsTF.alpha = 0
                contentsTFView.alpha = 0
                textCountLB.alpha = 0
            }
        }
    }
    
    let separatorTwo = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        $0.alpha = 0
    }
    
    let cvEtcTitleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        $0.text = "신고 사유"
        $0.alpha = 0
    }
    
    lazy var contentsTF = UITextView().then {
        $0.text = placeHolder
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.delegate = self
        $0.alpha = 0
    }
    
    let contentsTFView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        $0.alpha = 0
    }
    
    let placeHolder = "이 장소 메모리를 작성해보세요"
    
    let alertLabel = AlertLabel().then {
        $0.alpha = 0
    }
    
    init(vm: ReportViewModel) {
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

extension ReportViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        
        safeArea.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(106)
        }
        
        headerView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        headerView.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(28)
        }
        
        headerView.addSubview(reportIcon)
        reportIcon.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(18)
        }
        
        headerView.addSubview(reportTitle)
        reportTitle.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(24)
            $0.leading.equalTo(reportIcon.snp.trailing).offset(5)
            $0.height.equalTo(17)
        }
        
        headerView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(105)
        }
        
        bottomView.addSubview(reportBT)
        reportBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        view.addSubview(alertLabel)
        alertLabel.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top).offset(-10)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        safeArea.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom)
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(cvTitleLB)
        cvTitleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(29)
        }
        
        contentView.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalTo(cvTitleLB.snp.bottom).offset(11)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(276)
        }
        
        contentView.addSubview(separatorTwo)
        separatorTwo.snp.makeConstraints {
            $0.top.equalTo(dataCV.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(1)
        }
        
        contentView.addSubview(cvEtcTitleLB)
        cvEtcTitleLB.snp.makeConstraints {
            $0.top.equalTo(separatorTwo.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(29)
        }
        
        contentView.addSubview(textCountLB)
        textCountLB.snp.makeConstraints {
            $0.top.equalTo(separatorTwo.snp.bottom).offset(27)
            $0.trailing.equalToSuperview().offset(-29)
            $0.height.equalTo(17)
        }
        
        contentView.addSubview(contentsTFView)
        contentsTFView.snp.makeConstraints {
            $0.top.equalTo(cvEtcTitleLB.snp.bottom).offset(11)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(160)
            $0.bottom.equalToSuperview().offset(-22)
        }
        
        contentsTFView.addSubview(contentsTF)
        contentsTF.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        dataCV.delegate = nil
        dataCV.dataSource = nil
        dataCV.rx.setDelegate(self).disposed(by: disposeBag)
        dataCV.register(ReportCell.self, forCellWithReuseIdentifier: "cell")
        
        dataCV.rx.itemSelected
            .map { index in
                let cell = self.dataCV.cellForItem(at: index) as! ReportCell
                self.reportBT.isEnabled = true
                return cell.titleView.text!
            }
            .bind(to: vm.input.reportTextObserver)
            .disposed(by: disposeBag)
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        reportBT.rx.tap
            .bind(to: vm.input.reportObserver)
            .disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        vm.data
            .bind(to: dataCV.rx.items(cellIdentifier: "cell", cellType: ReportCell.self)) { row, element, cell in
            cell.titleView.text = element
        }.disposed(by: disposeBag)
        
        vm.output.textValue
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { value in
                self.mode = value
            }).disposed(by: disposeBag)
        
        vm.output.errorValue
            .subscribe(onNext: { value in
                
                self.alertLabel.labelView.text = value
                self.alertLabel.alpha = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIView.animate(withDuration: 1.5) {
                        self.alertLabel.alpha = 0
                    }
                }
                
            }).disposed(by: disposeBag)
        
        vm.output.completeValue
            .subscribe(onNext: { value in
                self.detailVm?.output.errorValue.accept(value)
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
    }
    
}

//MARK: - CollectionView delegate
extension ReportViewController: UICollectionViewDelegateFlowLayout {
    
    //collectionView자체 latout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    //셀 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width-60, height: 34)
    }
    
    //2번 선택할 때 deselect 모드로 변경
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? KeyWordCell else {
            return true
        }
        if cell.isSelected {
            collectionView.deselectItem(at: indexPath, animated: true)
            vm.input.reportTextObserver.accept("")
            return false
        } else {
            return true
        }
    }
    
}


//MARK: - ScrollView, TextView Delegate
extension ReportViewController: UIScrollViewDelegate, UITextViewDelegate {
    
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
        if !(textView.text == placeHolder) {
            vm.input.reportTextObserver.accept(textView.text)
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

final class ReportCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectImageView.alpha = 1
            } else {
                selectImageView.alpha = 0
            }
        }
    }
    
    let imageView = UIImageView(image: UIImage(named: "report_not_select"))
    
    let selectImageView = UIImageView(image: UIImage(named: "report_select")).then {
        $0.alpha = 0
    }
    
    let titleView = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 15)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        addSubview(selectImageView)
        selectImageView.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(14)
            $0.height.equalTo(18)
        }
        
    }
    
}
