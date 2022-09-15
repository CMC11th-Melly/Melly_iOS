//
//  CustomComponent.swift
//  Melly
//
//  Created by Jun on 2022/09/14.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(title: String) {
        self.init()
        self.setTitle(title, for: .normal)
        self.layer.cornerRadius = 12
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.backgroundColor = UIColor.gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class BackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init()
        self.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
