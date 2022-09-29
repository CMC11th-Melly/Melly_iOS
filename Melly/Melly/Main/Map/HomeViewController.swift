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
import CoreLocation

protocol HomeViewControllerDelegate:AnyObject {
    func didTapMenuButton()
}

class HomeViewController: UIViewController {

    weak var delegate: HomeViewControllerDelegate?
    var disposeBag = DisposeBag()
    var locationManager: CLLocationManager!
    let vm = MainMapViewModel()
    
    
   private lazy var mapView = NMFMapView(frame: .zero).then {
        $0.isUserInteractionEnabled = true
    }
    
    let layoutView = UIView()
    let mainTextField = MainTextField()
    
    let addGroupView = UIView().then {
        $0.backgroundColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.layer.cornerRadius = 25
    }
    
    let addGroupBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "main_plus"), for: .normal)
    }
    
    let myLocationView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 25
    }
    
    let myLocationBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "myLocation"), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        setUI()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension HomeViewController {
    func setUI() {
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        view.addSubview(layoutView)
        layoutView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(248)
        }
        safeArea.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(layoutView.snp.top)
        }
        
        mapView.addSubview(mainTextField)
        mainTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(44)
        }
        
        mapView.addSubview(addGroupView)
        addGroupView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-50)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(50)
        }
        
        addGroupView.addSubview(addGroupBT)
        addGroupBT.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
        
        mapView.addSubview(myLocationView)
        myLocationView.snp.makeConstraints {
            $0.bottom.equalTo(addGroupView.snp.top).offset(-15)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(50)
        }
        
        myLocationView.addSubview(myLocationBT)
        myLocationBT.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        let fpc = FloatingPanelController()
        let vc = RecommandViewController()
        fpc.set(contentViewController: vc)
        fpc.addPanel(toParent: self)
        fpc.layout = CustomFloatingPanelLayout()
        fpc.show()
        
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        
        mainTextField.bt.rx.tap
            .subscribe(onNext: {
                self.delegate?.didTapMenuButton()
            }).disposed(by: disposeBag)
        
        myLocationBT.rx.tap.subscribe(onNext: {
            self.locationManager.requestWhenInUseAuthorization()
            
            if self.mapView.positionMode == .direction {
                self.mapView.positionMode = .disabled
            } else {
                self.mapView.positionMode = .direction
            }
            
        }).disposed(by: disposeBag)
        
        
    }
    
    func bindOutput() {
        
        vm.output.markerValue.asDriver(onErrorJustReturn: [])
            .drive(onNext: { marker in
                print(marker)
            }).disposed(by: disposeBag)
        
    }
    
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            self.locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
}




class CustomFloatingPanelLayout: FloatingPanelLayout{
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
            return [
                .full: FloatingPanelLayoutAnchor(fractionalInset: 0.85, edge: .bottom, referenceGuide: .superview),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 248.0, edge: .bottom, referenceGuide: .superview)

            ]
        }
}

