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

class MemoryWriteViewController: UIViewController {
    
    //    let place:Place
    private let disposeBag = DisposeBag()
    private let vm:MemoryWriteViewModel
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
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
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let titleTF = UITextField().then {
        $0.placeholder = "메모리 제목을 입력해주세요"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
        let lv = UIView()
        lv.snp.makeConstraints {
            $0.width.equalTo(17)
            $0.height.equalTo(58)
        }
        $0.leftView = lv
        $0.leftViewMode = .always
    }
    
    let contentsLB = UILabel().then {
        $0.text = "메모리 작성 *"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let contentsTFView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1).cgColor
    }
    
    lazy var contentsTF = UITextView().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    let textCountLB = UILabel().then {
        $0.text = "0자 | 최소 20자"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
    }
    
    let groupLB = UILabel().then {
        $0.text = "그룹 설정 *"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let groupDetailLB = UILabel().then {
        $0.text = "누구와 함께 메모리를 쌓았나요?"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
    }
    
    let groupPickerView = DropMenuButton()
    
    let dateLB = UILabel().then {
        $0.text = "날짜"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let dateBT = UIButton(type: .custom).then {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. M. d (E) a hh:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let dateString = dateFormatter.string(from: Date())
        let attributedString = NSMutableAttributedString(string: dateString)
        let font = UIFont(name: "Pretendard-Medium", size: 16)!
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: dateString.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1), range: NSRange(location: 0, length: dateString.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let dateSeparator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.906, green: 0.93, blue: 0.954, alpha: 1)
    }
    
    let starLB = UILabel().then {
        $0.text = "메모리 별점"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    
    
    let keywordLB = UILabel().then {
        $0.text = "내 기분 키워드"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let keywordDetailView = UILabel().then {
        $0.text = "이 메모리에서 느낀 내 기분은 어떤가요?"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
    }
    
    let keywordCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    let cancelBT = CustomButton(title: "취소")
    let writeBT = CustomButton(title: "메모리 저장")
    
    
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
        bind()
    }
    
    
}

extension MemoryWriteViewController {
    
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
        
        contentView.addSubview(groupDetailLB)
        groupDetailLB.snp.makeConstraints {
            $0.top.equalTo(contentsTFView.snp.bottom).offset(35)
            $0.leading.equalTo(groupLB.snp.trailing).offset(9)
            
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
            $0.height.equalTo(20)
        }
        
        contentView.addSubview(dateSeparator)
        dateSeparator.snp.makeConstraints {
            $0.top.equalTo(dateBT.snp.bottom).offset(11)
            $0.height.equalTo(1)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        contentView.addSubview(starLB)
        starLB.snp.makeConstraints {
            $0.top.equalTo(dateSeparator.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(30)
        }
        
        
        var views:[UIView] = []
        for _ in 0..<5 {
            let button = UIButton(type: .custom).then {
                $0.setImage(UIImage(named: "memory_star"), for: .normal)
            }
            views.append(button)
        }
        
        let stackView = UIStackView(arrangedSubviews: views).then {
            $0.distribution = .fillEqually
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
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(150)
            $0.bottom.equalToSuperview()
        }
        
        
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
        
        
        cancelBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        
    }
    
    
}

extension MemoryWriteViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return KeyWordCell.fittingSize(availableHeight: 33, name: vm.keywordData[indexPath.item])
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
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
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
        layer.cornerRadius = 22.0
    }
    
    private func setupView() {
        backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        layer.cornerRadius = 12
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
    
}
