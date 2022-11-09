//
//  ViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/06.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Lottie

class SplashViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    let animationView = LottieAnimationView(name: "MellySplash").then {
        $0.contentMode = .scaleAspectFit
        $0.play()
        $0.loopMode = .loop
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let data = UserDefaults.standard.value(forKey: "loginUser") as? Data,
           let token = UserDefaults.standard.string(forKey: "token"){
            if var user = try? PropertyListDecoder().decode(User.self, from: data) {
                user.jwtToken = token
                User.loginedUser = user
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let vc = MainLoginViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    private func setUI() {
        view.backgroundColor = UIColor(red: 0.116, green: 0.052, blue: 0.521, alpha: 1)
        
        view.addSubview(animationView)
        animationView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.equalTo(330)
            $0.height.equalTo(420)
        }
        
    }
    
}

