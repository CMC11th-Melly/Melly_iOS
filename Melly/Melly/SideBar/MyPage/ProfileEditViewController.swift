//
//  ProfileEditViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/23.
//

import UIKit
import RxSwift
import RxCocoa
import Photos
import PhotosUI

class ProfileEditViewController: UIViewController {

    private let disposeBag = DisposeBag()
    let vm = MyPageViewModel.instance
    let backBT = BackButton()
    
    let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    let contentView = UIView()
    let bottomView = UIView()
    
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "프로필 수정"
    }
    
    let profileView = UIImageView(image: UIImage(named: "profile")).then {
        $0.isUserInteractionEnabled = true
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 22
    }
    
    let profileSelectBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "camera"), for: .normal)
    }
    
    
    let nameLB = UILabel().then {
        $0.text = "닉네임 *"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
    }
    
    let nameTf = CustomTextField(title: "이름을 입력해주세요.")
    
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
    
    let cancelBT = CustomButton(title: "취소").then {
        $0.isEnabled = true
        $0.backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.984, alpha: 1)
        let title = "취소"
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 16)!, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.173, green: 0.092, blue: 0.671, alpha: 1), range: NSRange(location: 0, length: title.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let writeBT = CustomButton(title: "완료").then {
        $0.isEnabled = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.initialObserver
    }

}

extension ProfileEditViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        
        safeArea.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(30)
        }
        
        safeArea.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalTo(backBT.snp.trailing).offset(12)
        }
        
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
            $0.top.equalTo(backBT.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(55)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(130)
        }
        
        contentView.addSubview(profileSelectBT)
        profileSelectBT.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.top).offset(75)
            $0.leading.equalTo(profileView.snp.leading).offset(80)
        }
        
        contentView.addSubview(nameLB)
        nameLB.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(34)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(nameTf)
        nameTf.snp.makeConstraints {
            $0.top.equalTo(nameLB.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(58)
        }
        
        contentView.addSubview(genderLb)
        genderLb.snp.makeConstraints {
            $0.top.equalTo(nameTf.snp.bottom).offset(27)
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
        
        
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        cancelBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
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
                    self.vm.deleteImage = true
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                
                alert.addAction(pickerAction)
                alert.addAction(cameraAction)
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
                
            }).disposed(by: disposeBag)
        
        genderCV.dataSource = nil
        genderCV.delegate = nil
        genderCV.rx.setDelegate(self).disposed(by: disposeBag)
        genderCV.register(SignUpCell.self, forCellWithReuseIdentifier: "gender")
        
        
        vm.genderData
            .bind(to: genderCV.rx.items(cellIdentifier: "gender", cellType: SignUpCell.self)) { row, element, cell in
                cell.textLB.text = element
                
                if let user = User.loginedUser {
                    if String.getGenderValue(user.gender) == element {
                        cell.isSelected = true
                        cell.setData()
                        
                    }
                }
                
                
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
                if let user = User.loginedUser {
                    if String.getAgeValue(user.ageGroup) == element {
                        cell.isSelected = true
                        cell.setData()
                        
                    }
                }
            }.disposed(by: disposeBag)
        
        writeBT.rx.tap.bind(to: vm.input.editObserver).disposed(by: disposeBag)
        
        nameTf.textField.rx.text.orEmpty
            .debounce(RxTimeInterval.microseconds(5), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: vm.input.nicnameObserver)
            .disposed(by: disposeBag)
        
        
    }
    
    private func bindOutput() {
        
        
        
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
        
        vm.output.errorValue.subscribe(onNext: { value in
            
            let alert = UIAlertController(title: "에러", message: value, preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
            
        }).disposed(by: disposeBag)
        
        vm.output.successValue.subscribe(onNext: {
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        
    }
    
    
    private func setData() {
        if let user = User.loginedUser {
            
            if let image = user.profileImage {
                let url = URL(string: image)!
                profileView.kf.setImage(with: url)
            } else {
                profileView.image = UIImage(named: "profile")
            }
            
            nameTf.textField.text = user.nickname
            
        }
    }
    
}

extension ProfileEditViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                self.vm.deleteImage = false
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
        self.vm.deleteImage = false
        vm.input.profileImgObserver.accept(image)
        
    }
    
}

extension ProfileEditViewController: UICollectionViewDelegateFlowLayout {
    
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
