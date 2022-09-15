//
//  DefaultLoginViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/14.
//

import UIKit
import Then

class DefaultLoginViewController: UIViewController {

    let backBT = BackButton()
    
    let loginLabel = UILabel().then {
        $0.text = "로그인"
        $0.font = UIFont.systemFont(ofSize: 26)
        $0.textColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    
}
