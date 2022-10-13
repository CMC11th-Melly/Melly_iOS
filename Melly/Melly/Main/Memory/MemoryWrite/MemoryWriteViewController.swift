//
//  MemoryWriteViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/13.
//

import UIKit
import RxCocoa
import RxSwift
import Then

class MemoryWriteViewController: UIViewController {

    let place:Place
    private let disposeBag = DisposeBag()
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    let contentView = UIView()
    let bottomView = UIView()
    
    lazy private var placeNameLB = UILabel().then {
        $0.text = place.placeName
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 20)
    }
    
    lazy private var placeCategoryLB = UILabel().then {
        $0.text = place.placeCategory
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    
    
    init(place: Place) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    

}
