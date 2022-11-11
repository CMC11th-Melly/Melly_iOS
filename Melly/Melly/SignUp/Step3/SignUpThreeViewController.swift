//
//  SignUpThreeViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/19.
//

import UIKit
import Then
import RxSwift
import RxCocoa
import RxRelay
import Photos
import PhotosUI
import RxAlamofire
import Alamofire

class SignUpThreeViewController: UIViewController {
    
    let vm:SignUpThreeViewModel
    private var disposeBag = DisposeBag()
    
    let headerView = UIView()
    let bodyView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    let contentView = UIView()
    let bottomView = UIView()
    
    let backBT = BackButton()
    
    let signUpLabel = UILabel().then {
        
        $0.font = UIFont.init(name: "Pretendard-Bold", size: 26)
        $0.textColor = .black
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    
    let profileLb = UILabel().then {
        $0.text = "프로필"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let profileView = UIImageView(image: UIImage(named: "profile")).then {
        $0.isUserInteractionEnabled = true
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFill
    }
    
    let profileSelectBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "camera"), for: .normal)
    }
    
    let genderLb = UILabel().then {
        $0.text = "성별"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let genderCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    
    let ageLb = UILabel().then {
        $0.text = "연령"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let ageCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let recommendView = UIImageView(image: UIImage(named: "step3_label"))
    
    let recomandLabel = UILabel().then {
        $0.text = "성별을 입력하면 장소 추천을 받을 수 있어요"
        $0.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    let skipBT = CustomButton(title: "다음에 하기").then {
        $0.backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.984, alpha: 1)
        let title = "다음에 하기"
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 16)!, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.173, green: 0.092, blue: 0.671, alpha: 1), range: NSRange(location: 0, length: title.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let nextBT = CustomButton(title: "완료").then {
        $0.isEnabled = true
    }
    
    init(vm: SignUpThreeViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCV()
        setUI()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 1.5) {
                self.recommendView.alpha = 0
            }
        }
    }
    
}

extension SignUpThreeViewController {
    
    func setUI() {
        self.view.backgroundColor = .white
        
        safeArea.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        headerView.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(27)
            $0.height.width.equalTo(28)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(105)
        }
        
        bottomView.addSubview(skipBT)
        skipBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(56)
            $0.width.equalTo((self.view.frame.width-70)/2)
        }
        
        bottomView.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.height.equalTo(56)
            $0.width.equalTo((self.view.frame.width-70)/2)
            $0.trailing.equalToSuperview().offset(-30)
           
        }
        
        safeArea.addSubview(bodyView)
        
        bodyView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom)
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        bodyView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        signUpLabel.text = "\(vm.user.nickname)님의\n프로필을 완성해볼까요?"
        contentView.addSubview(signUpLabel)
        signUpLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(profileLb)
        profileLb.snp.makeConstraints {
            $0.top.equalTo(signUpLabel.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top.equalTo(profileLb.snp.bottom).offset(28)
            $0.centerX.equalTo(safeArea)
            $0.width.height.equalTo(130)
        }
        
        contentView.addSubview(profileSelectBT)
        profileSelectBT.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.top).offset(75)
            $0.leading.equalTo(profileView.snp.leading).offset(80)
        }
        
        contentView.addSubview(genderLb)
        genderLb.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(50)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(genderCV)
        genderCV.snp.makeConstraints {
            $0.top.equalTo(genderLb.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(safeArea).offset(-30)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(ageLb)
        ageLb.snp.makeConstraints {
            $0.top.equalTo(genderCV.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(ageCV)
        ageCV.snp.makeConstraints {
            $0.top.equalTo(ageLb.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(safeArea).offset(-30)
            $0.height.equalTo(254)
            $0.bottom.equalToSuperview()
        }
        
        safeArea.addSubview(recommendView)
        recommendView.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top).offset(-9)
            $0.leading.equalToSuperview().offset(56)
            $0.trailing.equalToSuperview().offset(-56)
            $0.height.equalTo(46)
        }
        
        recommendView.addSubview(recomandLabel)
        recomandLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.leading.equalToSuperview().offset(25)
            $0.trailing.equalToSuperview().offset(-25)
        }
        
        
        
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        
        profileSelectBT.rx.tap
            .subscribe(onNext: {
                
                let alert = UIAlertController(title: "프로필 사진 추가하기", message: nil, preferredStyle: .actionSheet)
                
                let pickerAction = UIAlertAction(title: "앨범에서 사진 선택", style: .default) { _ in
                    var config = PHPickerConfiguration(photoLibrary: .shared())
                    config.selectionLimit = 1
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
                
                let defaultAction = UIAlertAction(title: "기본 이미지로 변경", style: .default) { _ in
                    self.vm.input.profileImgObserver.accept(nil)
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                
                alert.addAction(pickerAction)
                alert.addAction(cameraAction)
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
                
            }).disposed(by: disposeBag)
        
        nextBT.rx.tap
            .bind(to: vm.input.signUpObserver)
            .disposed(by: disposeBag)
        
        skipBT.rx.tap
            .bind(to: vm.input.signUpObserver)
            .disposed(by: disposeBag)
        
    }
    
    func bindOutput() {
        
        vm.output.imageValue.asDriver(onErrorJustReturn: nil)
            .drive(onNext: { image in
                
                if let image = image {
                    DispatchQueue.main.async {
                        self.profileView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.profileView.image = UIImage(named: "profile")
                    }
                }
            }).disposed(by: disposeBag)
        
        vm.output.userValue.asDriver(onErrorJustReturn: nil)
            .drive(onNext: { value in
                
                if let value = value {
                    //MARK: 에러처리
                    print(value)
                } else {
                    self.dismiss(animated: true)
                }
                
            }).disposed(by: disposeBag)
        
    }
    
    func setCV() {
        genderCV.dataSource = nil
        genderCV.delegate = nil
        genderCV.rx.setDelegate(self).disposed(by: disposeBag)
        genderCV.register(SignUpCell.self, forCellWithReuseIdentifier: "gender")
        
        
        vm.genderData
            .bind(to: genderCV.rx.items(cellIdentifier: "gender", cellType: SignUpCell.self)) { row, element, cell in
                cell.textLB.text = element
                
            }.disposed(by: disposeBag)
        
        genderCV.rx.itemSelected
            .map { index in
                let cell = self.genderCV.cellForItem(at: index) as? SignUpCell
                return cell?.textLB.text ?? ""
            }.bind(to: vm.input.genderObserver)
            .disposed(by: disposeBag)
        
        ageCV.dataSource = nil
        ageCV.delegate = nil
        ageCV.rx.setDelegate(self).disposed(by: disposeBag)
        ageCV.register(SignUpCell.self, forCellWithReuseIdentifier: "age")
                
        ageCV.rx.itemSelected
            .map { index in
                let cell = self.ageCV.cellForItem(at: index) as? SignUpCell
                return cell?.textLB.text ?? ""
            }.bind(to: vm.input.ageObserver)
            .disposed(by: disposeBag)
        
        vm.ageData
            .bind(to: ageCV.rx.items(cellIdentifier: "age", cellType: SignUpCell.self)) { row, element, cell in
                cell.textLB.text = element
            }.disposed(by: disposeBag)
        
        
        
        
    }
    
}

extension SignUpThreeViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                
                self.vm.input.profileImgObserver.accept(image)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        vm.input.profileImgObserver.accept(image)
        
    }
    
}

extension SignUpThreeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 70) / 2
        return CGSize(width: width, height: 56)
    }
    
    
}


class SignUpCell: UICollectionViewCell {
    
    
    let textLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
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
        
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.965, green: 0.969, blue: 0.973, alpha: 1).cgColor
        addSubview(textLB)
        textLB.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    func setData() {
        textLB.textColor = UIColor(red: 0.116, green: 0.052, blue: 0.521, alpha: 1)
        backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.984, alpha: 1)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                textLB.textColor = UIColor(red: 0.116, green: 0.052, blue: 0.521, alpha: 1)
                backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.984, alpha: 1)
                
            } else {
                textLB.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
                backgroundColor = .white
            }
        }
    }
   
    
}
