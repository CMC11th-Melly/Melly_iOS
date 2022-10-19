//
//  ViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/06.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
//            let place = Place(placeId: 1, position: Position(lat: 1, lng: 1), myMemoryCount: 0, otherMemoryCount: 0, placeCategory: "거리", isScraped: true, placeName: "성수동", recommendType: "가족")
//            let vm = MemoryWriteViewModel(place)
//
//            let vc = MemoryWriteViewController(vm: vm)
            let vc = OurMemoryListViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }


}

