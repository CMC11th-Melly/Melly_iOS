//
//  MyPageViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/21.
//

import Foundation
import UIKit

class MyPageViewController:UIViewController {
    
    let backBT = BackButton()
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "마이페이지"
    }
    
    let imageView = UIImageView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    let nicknameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 26)
    }
    
    let emailLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12.6)
    }
    
    let revisedBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "go_profile"), for: .normal)
    }
    
    let oneSt = UIView().then {
        $0.backgroundColor = UIColor(red: 0.971, green: 0.977, blue: 0.983, alpha: 1)
    }
    
    let storeLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

