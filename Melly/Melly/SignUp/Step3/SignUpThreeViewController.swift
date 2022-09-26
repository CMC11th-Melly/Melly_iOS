//
//  SignUpThreeViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/19.
//

import UIKit
import Then
import DropDown
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
    
    let layoutView1 = UIView()
    let layoutView2 = UIView()
    
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
        
    }
    
    let profileSelectBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "camera"), for: .normal)
    }
    
    let genderLb = UILabel().then {
        $0.text = "성별"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let genderSelectBT = DropMenuButton("성별")
    
    let genderMenu = DropDown().then {
        $0.dataSource = ["남자", "여자"]
    }
    
    let ageLb = UILabel().then {
        $0.text = "연령"
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    let ageSelectBT = DropMenuButton("연령")
    
    let ageMenu = DropDown().then {
        $0.dataSource = ["10대", "20대", "30대", "40대", "50대", "60대 이상"]
    }
    
    let recomandLabel = UILabel().then {
        $0.text = "성별을 입력하면 장소 추천을 받을 수 있어요"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .black
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .gray
        $0.textAlignment = .center
    }
    
    let skipButton = UIButton(type: .custom).then {
        let title = "나중에 할게요"
        let attributedString = NSMutableAttributedString(string: title)
        let font = UIFont(name: "Pretendard-SemiBold", size: 16)!
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1), range: NSRange(location: 0, length: title.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let nextBT = CustomButton(title: "완료")
    
    init(vm: SignUpThreeViewModel) {
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 1.5) {
                self.recomandLabel.alpha = 0
            }
        }
    }
    
}

extension SignUpThreeViewController {
    
    func setUI() {
        self.view.backgroundColor = .white
        
        safeArea.addSubview(layoutView2)
        safeArea.addSubview(layoutView1)
        layoutView2.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(190)
        }
        layoutView1.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(layoutView2.snp.top)
        }
        
        layoutView1.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo(22)
            $0.height.equalTo(20)
        }
        
        signUpLabel.text = "\(vm.user.nickname)님의\n프로필을 완성해볼까요?"
        layoutView1.addSubview(signUpLabel)
        signUpLabel.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(profileLb)
        profileLb.snp.makeConstraints {
            $0.top.equalTo(signUpLabel.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top.equalTo(profileLb.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
        }
        
        layoutView1.addSubview(profileSelectBT)
        profileSelectBT.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.top).offset(75)
            $0.leading.equalTo(profileView.snp.leading).offset(80)
        }
        
        layoutView1.addSubview(genderLb)
        genderLb.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(50)
            $0.leading.equalToSuperview().offset(30)
        }
        
        layoutView1.addSubview(ageLb)
        ageLb.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(50)
            $0.leading.equalToSuperview().offset(self.view.frame.width / 2 + 8)
        }
        
        layoutView1.addSubview(genderSelectBT)
        genderSelectBT.snp.makeConstraints {
            $0.top.equalTo(genderLb.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(58)
            $0.width.equalTo((self.view.frame.width / 2) - 38)
        }
        
        genderMenu.anchorView = genderSelectBT
        genderMenu.cellHeight = 56
        genderMenu.cornerRadius = 12
        genderMenu.direction = .bottom
        
        layoutView1.addSubview(ageSelectBT)
        ageSelectBT.snp.makeConstraints {
            $0.top.equalTo(genderLb.snp.bottom).offset(7)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(58)
            $0.width.equalTo((self.view.frame.width / 2) - 38)
        }
        
        ageMenu.anchorView = ageSelectBT
        ageMenu.cellHeight = 56
        ageMenu.cornerRadius = 12
        ageMenu.bottomOffset = CGPoint(x: 0, y: genderMenu.anchorView!.plainView.bounds.height)
        
        layoutView2.addSubview(recomandLabel)
        recomandLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(56)
            $0.trailing.equalToSuperview().offset(-56)
            $0.height.equalTo(39)
        }
        
        layoutView2.addSubview(skipButton)
        skipButton.snp.makeConstraints {
            $0.top.equalTo(recomandLabel.snp.bottom).offset(27)
            $0.centerX.equalToSuperview()
        }
        
        layoutView2.addSubview(nextBT)
        nextBT.snp.makeConstraints {
            $0.top.equalTo(skipButton.snp.bottom).offset(36)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        genderSelectBT.rx.tap
            .subscribe(onNext: {
                self.genderMenu.show()
                self.genderSelectBT.imgView.image = UIImage(named: "dropup")
            }).disposed(by: disposeBag)
        
        genderMenu.selectionAction = { [weak self] (index, item) in
            //선택한 Item을 TextField에 넣어준다.
            self!.vm.input.genderObserver.accept(item)
            self!.genderSelectBT.labelView.text = item
            self!.genderSelectBT.imgView.image = UIImage(named: "dropdown")
        }
        
        // 취소 시 처리
        genderMenu.cancelAction = { [weak self] in
            //빈 화면 터치 시 DropDown이 사라지고 아이콘을 원래대로 변경
            self!.genderSelectBT.imgView.image = UIImage(named: "dropdown")
        }
        
        ageSelectBT.rx.tap
            .subscribe(onNext: {
                self.ageMenu.show()
                self.ageSelectBT.imgView.image = UIImage(named: "dropup")
            }).disposed(by: disposeBag)
        
        ageMenu.selectionAction = { [weak self] (index, item) in
            self!.vm.input.ageObserver.accept(item)
            self!.ageSelectBT.labelView.text = item
            self!.ageSelectBT.imgView.image = UIImage(named: "dropdown")
        }
        
        ageMenu.cancelAction = { [weak self] in
            self!.ageSelectBT.imgView.image = UIImage(named: "dropdown")
        }
        
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
