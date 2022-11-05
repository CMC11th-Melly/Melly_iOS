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

class SplashViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let vc = ReportViewController()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
//        if let data = UserDefaults.standard.value(forKey: "loginUser") as? Data,
//           let token = UserDefaults.standard.string(forKey: "token"){
//            if var user = try? PropertyListDecoder().decode(User.self, from: data) {
//                user.jwtToken = token
//                User.loginedUser = user
//            }
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            let vc = MainLoginViewController()
//            vc.modalTransitionStyle = .crossDissolve
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true)
//        }
    }
    
}

