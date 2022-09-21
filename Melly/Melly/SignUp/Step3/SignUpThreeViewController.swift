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
        
        $0.font = UIFont.systemFont(ofSize: 26)
        $0.textColor = .black
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    
    let selectBT = DropMenuButton("성별을 선택해주세요.")
    
    let menu = DropDown().then {
        $0.dataSource = ["남자", "여자"]
    }
    
    let recomandLabel = UILabel().then {
        $0.text = "성별을 입력하면 장소 추천을 받을 수 있어요"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .black
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .gray
        $0.textAlignment = .center
    }
    
    let selectPhotoBT = UIButton(type: .custom).then {
        $0.setTitle("포토", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    let skipButton = UIButton(type: .custom).then {
        let title = "나중에 할게요"
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    let nextBT = CustomButton(title: "다음").then {
        $0.isEnabled = false
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
        
        signUpLabel.text = "\(vm.user.nickname)님의\n성별은 무엇인가요?"
        layoutView1.addSubview(signUpLabel)
        signUpLabel.snp.makeConstraints {
            $0.top.equalTo(backBT.snp.bottom).offset(56)
            $0.leading.equalToSuperview().offset(30)
        }
        
        menu.cellHeight = 56
        menu.cornerRadius = 12
        menu.anchorView = selectBT
        menu.bottomOffset = CGPoint(x: 0, y: (menu.anchorView?.plainView.bounds.height)!)
        
        layoutView1.addSubview(selectBT)
        selectBT.snp.makeConstraints {
            $0.top.equalTo(signUpLabel.snp.bottom).offset(62)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(58)
        }
        
        layoutView1.addSubview(selectPhotoBT)
        selectPhotoBT.snp.makeConstraints {
            $0.top.equalTo(selectBT.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(58)
        }
        
        
        
        
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
        selectBT.rx.tap
            .subscribe(onNext: {
                self.menu.show()
                self.selectBT.imgView.image = UIImage(named: "dropup")
            }).disposed(by: disposeBag)
        
        menu.selectionAction = { [weak self] (index, item) in
            //선택한 Item을 TextField에 넣어준다.
            if item == "남성" {
                self!.vm.user.gender = true
            } else {
                self!.vm.user.gender = false
            }
            
            self!.selectBT.labelView.text = item
            self!.selectBT.imgView.image = UIImage(named: "dropdown")
        }
        
        selectPhotoBT.rx.tap
            .subscribe(onNext: {
                var config = PHPickerConfiguration(photoLibrary: .shared())
                config.selectionLimit = 1
                config.filter = PHPickerFilter.any(of: [.images])
                let vc = PHPickerViewController(configuration: config)
                vc.delegate = self
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
        // 취소 시 처리
        menu.cancelAction = { [weak self] in
            //빈 화면 터치 시 DropDown이 사라지고 아이콘을 원래대로 변경
            self!.selectBT.imgView.image = UIImage(named: "dropdown")
        }
        
    }
    
    func bindOutput() {
        
    }
    
}

extension SignUpThreeViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                
                let header:HTTPHeaders = [
                            "Content-Type": "multipart/form-data"
                        ]
                
                let pngData = image.pngData() ?? Data()
                let realUrl = URL(string: "http://3.39.218.234/api/imageTest")
                let url:Alamofire.URLConvertible = realUrl!
                
                AF.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(pngData, withName: "image", fileName: "test.png", mimeType: "image/png")
                }, to: url, method: .post, headers: header)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            print("성공\(data)")
                        case .failure(let error):
                            print(error)
                        }
                    }
                    
                
                
                
                
//                RxAlamofire.upload(multipartFormData: { multipartFormData in
//                    multipartFormData.append(pngData, withName: "image", fileName: "test.png", mimeType: "image/png")
//                }, to: url, method: .post, headers: header)
//
//                    .subscribe({ event in
//                        switch event {
//                        case .next(let response):
//                            print(response)
//                        case .onError(let error):
//                            print(error)
//                        case .completed:
//                            break
//                        }
//
//                    }).disposed(by: disposeBag)
//
                    
            }
        }
    }
    
    
}
