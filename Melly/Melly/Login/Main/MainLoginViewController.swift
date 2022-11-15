//
//  LoginViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/07.
//

import UIKit
import Then
import RxSwift
import RxCocoa
import Firebase
import GoogleSignIn
import RxKakaoSDKAuth
import KakaoSDKAuth
import NaverThirdPartyLogin
import AuthenticationServices

class MainLoginViewController: UIViewController {
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    let vm = MainLoginViewModel()
    let disposeBag = DisposeBag()
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    let contentView = UIView()
    
    let welcomeLabel = UILabel().then {
        let text = "어서오세요, MELLY에\n소중한 메모리를 담아보세요!"
        let attrString = NSMutableAttributedString(string: text)
        let font = UIFont(name: "Pretendard-Bold", size: 26)!
        let color = UIColor(red: 0.059, green: 0.053, blue: 0.363, alpha: 1)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attrString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
        attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attrString
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    let logoImageView = UIImageView(image: UIImage(named: "login_main_logo"))
    
    let loginBT = UIButton(type: .custom).then {
        $0.backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
        $0.layer.cornerRadius = 12
        $0.setImage(UIImage(named: "login_lock"), for: .normal)
        $0.setTitle("이메일로 로그인", for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -9, bottom: 0, right: 0)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -9)
        
    }
    
    let signUpBT = UIButton(type: .custom).then {
        $0.backgroundColor = .white
        let string = "이메일로 가입"
        let attributedString = NSMutableAttributedString(string: string)
        let font = UIFont(name: "Pretendard-Medium", size: 16)!
        attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 16)!, range: NSRange(location: 0, length: string.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1), range: NSRange(location: 0, length: string.count))
        $0.setAttributedTitle(attributedString, for: .normal)
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 0.274, green: 0.173, blue: 0.9, alpha: 1).cgColor
        $0.setImage(UIImage(named: "signup_login"), for: .normal)
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -6)
        
    }
    
    let googleLoginBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "googleLogo"), for: .normal)
    }
    
    let kakaoLoginBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "kakaoLogo"), for: .normal)
    }
    
    let naverLoginBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "naverLogo"), for: .normal)
    }
    
    let appleLoginBt = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "appleLogo"), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = User.loginedUser {
            if let initialUser = UserDefaults.standard.string(forKey: "initialUser") {
                if initialUser == "yes" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let vc = ResearchLaunchViewController()
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalTransitionStyle = .crossDissolve
                        nav.modalPresentationStyle = .fullScreen
                        nav.isNavigationBarHidden = true
                        self.present(nav, animated: true)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let vc = ContainerViewController()
                        vc.modalTransitionStyle = .crossDissolve
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let vc = ContainerViewController()
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }
    }
    
}

extension MainLoginViewController {
    
    private func setUI() {
        view.backgroundColor = UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
        
        safeArea.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(welcomeLabel)
        welcomeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(69)
            $0.centerX.equalToSuperview()
        }
        
        contentView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(270)
        }
        
        contentView.addSubview(loginBT)
        loginBT.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(safeArea).offset(-30)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(signUpBT)
        signUpBT.snp.makeConstraints {
            $0.top.equalTo(loginBT.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalTo(safeArea).offset(-30)
            $0.height.equalTo(56)
        }
        
        let apiFieldStack = UIStackView(arrangedSubviews: [kakaoLoginBt, naverLoginBt, googleLoginBt, appleLoginBt]).then {
            $0.axis = .horizontal
            $0.spacing = 28
            $0.distribution = .fillEqually
        }

        contentView.addSubview(apiFieldStack)
        apiFieldStack.snp.makeConstraints {
            $0.top.equalTo(signUpBT.snp.bottom).offset(46)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
        }
        
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        googleLoginBt.rx.tap
            .map { self }
            .bind(to: vm.input.googleLoginObserver)
            .disposed(by: disposeBag)
        
        kakaoLoginBt.rx.tap
            .bind(to: vm.input.kakaoLoginObserver)
            .disposed(by: disposeBag)
        
        naverLoginBt.rx.tap
            .subscribe(onNext: {
                self.naverLoginInstance?.delegate = self
                self.naverLoginInstance?.requestThirdPartyLogin()
            }).disposed(by: disposeBag)
        
        appleLoginBt.rx.tap
            .subscribe(onNext: {
                self.appleLogin()
            }).disposed(by: disposeBag)
        
        loginBT.rx.tap
            .subscribe(onNext: {
                let vc = DefaultLoginViewController()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
        signUpBT.rx.tap
            .subscribe(onNext: {
                let vm = SignUpZeroViewModel(User())
                let vc = SignUpZeroViewController(vm: vm)
                let nav = UINavigationController(rootViewController: vc)
                nav.isNavigationBarHidden = true
                nav.modalTransitionStyle = .crossDissolve
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        vm.output.outputData.asDriver(onErrorJustReturn: (true, User()))
            .drive(onNext: { value in
                
                if value.0 {
                    let vm = SignUpZeroViewModel(value.1)
                    let vc = SignUpZeroViewController(vm: vm)
                    let nav = UINavigationController(rootViewController: vc)
                    nav.isNavigationBarHidden = true
                    nav.modalTransitionStyle = .crossDissolve
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true)
                } else {
                    User.loginedUser = value.1
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(value.1), forKey: "loginUser")
                    UserDefaults.standard.set(value.1.jwtToken, forKey: "token")
                    let vc = ContainerViewController()
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }).disposed(by: disposeBag)
        
        vm.output.errorData.asDriver(onErrorJustReturn: "")
            .drive(onNext: { value in
                let alert = UIAlertController(title: "에러", message: value, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }).disposed(by: disposeBag)
    }
    
    
}

//MARK: - 네이버 로그인 Delegate
extension MainLoginViewController: NaverThirdPartyLoginConnectionDelegate {
    
    //토큰 유효성 검사뒤 viewModel로 보내줌
    private func getNaverInfo() {
        guard let isValidAccessToken = naverLoginInstance?.isValidAccessTokenExpireTimeNow() else { return }
        if !isValidAccessToken { return }
        guard let accessToken = naverLoginInstance?.accessToken else { return }
        vm.input.naverAppleLoginObserver.accept((accessToken, LoginType.naver))
    }
    
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        self.getNaverInfo()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        
    }
    
    
    func oauth20ConnectionDidFinishDeleteToken() {
        naverLoginInstance?.requestDeleteToken()
    }
    
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error] : ", error.localizedDescription)
    }
}


//MARK: - 애플 로그인 Delegate
extension MainLoginViewController: ASAuthorizationControllerDelegate {
    
    //애플로그인 실행
    func appleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
    }
    
    //토큰을 정상적으로 발급받으면 viewmodel로 이동
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if let token = String(data: credential.identityToken ?? Data(), encoding: .utf8) {
                vm.input.naverAppleLoginObserver.accept((token, .apple))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error \(error)")
    }
    
    
}
