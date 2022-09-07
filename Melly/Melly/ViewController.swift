//
//  ViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/06.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let vc = LoginViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }


}

