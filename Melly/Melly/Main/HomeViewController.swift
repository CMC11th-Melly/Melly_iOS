//
//  HomeViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/13.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift
import FloatingPanel
import NMapsMap

protocol HomeViewControllerDelegate:AnyObject {
    func didTapMenuButton()
}

class HomeViewController: UIViewController {

    weak var delegate: HomeViewControllerDelegate?
    var disposeBag = DisposeBag()
    
    let mapView = NMFMapView(frame: .zero)
    let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .done, target: self, action: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    
}

extension HomeViewController {
    func setUI() {
        view.backgroundColor = .systemBackground
        title = "Home"
        navigationItem.leftBarButtonItem = leftBarButton
        
        safeArea.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let fpc = FloatingPanelController()
        fpc.delegate = self
        let vc = ContentViewController()
        fpc.set(contentViewController: vc)
        fpc.addPanel(toParent: self)
    }
    
    func bind() {
        bindInput()
    }
    
    func bindInput() {
        
        leftBarButton.rx.tap
            .subscribe(onNext: {
                self.delegate?.didTapMenuButton()
            }).disposed(by: disposeBag)
        
    }
    
}

extension HomeViewController: FloatingPanelControllerDelegate {
    
}
