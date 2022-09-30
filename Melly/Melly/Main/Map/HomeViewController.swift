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
    
    let filterData = Observable<[String]>.of(["친구만", "연인만", "가족만", "동료만"])
    var markers = [NMFMarker]()
    weak var delegate: HomeViewControllerDelegate?
    var disposeBag = DisposeBag()
    var locationManager: CLLocationManager!
    let vm = MainMapViewModel()
    let secretView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    
    private lazy var mapView = NMFMapView(frame: .zero).then {
        $0.isUserInteractionEnabled = true
        $0.positionMode = .disabled
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
    
    let filterCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let friendBT = GroupToggleButton("친구만")
    
    let loverBT = GroupToggleButton("연인만")
    
    let familyBT = GroupToggleButton("가족만")
    
    let teamBT = GroupToggleButton("동료만")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMap()
        setUI()
        bind()
        setCV()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension HomeViewController {
    
    func setMap() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
    }
    
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
        
        
        safeArea.addSubview(mainTextField)
        mainTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(44)
        }
        
        
        safeArea.addSubview(filterCV)
        filterCV.snp.makeConstraints {
            $0.top.equalTo(mainTextField.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(30)
        }
        
        safeArea.addSubview(addGroupView)
        addGroupView.snp.makeConstraints {
            $0.bottom.equalTo(layoutView.snp.top).offset(-50)
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
    
    func setCV() {
        filterCV.dataSource = nil
        filterCV.delegate = nil
        filterCV.rx.setDelegate(self).disposed(by: disposeBag)
        filterCV.register(FilterCell.self, forCellWithReuseIdentifier: "cell")
        
        filterData
            .bind(to: filterCV.rx.items(cellIdentifier: "cell", cellType: FilterCell.self)) { row, element, cell in
                cell.titleLb.text = element
            }.disposed(by: disposeBag)
        
        
        filterCV.rx.itemSelected
            .map { index in
                let cell = self.filterCV.cellForItem(at: index) as? FilterCell
                let text = cell?.titleLb.text ?? "all"
                let value = GroupFilter.getValue(text)
                return value
            }.bind(to: vm.input.filterGroupObserver)
            .disposed(by: disposeBag)
        
        
        
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
            
            DispatchQueue.main.async {
                if self.mapView.positionMode == .direction {
                    self.mapView.positionMode = .disabled
                } else {
                    self.mapView.positionMode = .direction
                    
                }
            }
        }).disposed(by: disposeBag)
        
        friendBT.rx.tap
            .map { GroupFilter.friend }
            .bind(to: vm.input.filterGroupObserver)
            .disposed(by: disposeBag)
        
        loverBT.rx.tap
            .map { GroupFilter.couple }
            .bind(to: vm.input.filterGroupObserver)
            .disposed(by: disposeBag)
        
        familyBT.rx.tap
            .map { GroupFilter.family }
            .bind(to: vm.input.filterGroupObserver)
            .disposed(by: disposeBag)
        
        teamBT.rx.tap
            .map { GroupFilter.company }
            .bind(to: vm.input.filterGroupObserver)
            .disposed(by: disposeBag)
        
    }
    
    func bindOutput() {
        
        vm.output.markerValue.asDriver(onErrorJustReturn: [])
            .drive(onNext: { markers in
                
                DispatchQueue.main.async {
                    
                    for marker in markers {
                        marker.mapView = self.mapView
                    }
                }
                
            }).disposed(by: disposeBag)
        
        
    }
    
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            mapView.positionMode = .disabled
            self.locationManager.requestWhenInUseAuthorization()
        default:
            mapView.positionMode = .direction
            locationManager.startUpdatingLocation()
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: self.locationManager.location?.coordinate.latitude ?? 0, lng: self.locationManager.location?.coordinate.longitude ?? 0))
            cameraUpdate.animation = .easeIn
            self.mapView.moveCamera(cameraUpdate)
        }
    }
    
}


extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
           guard let cell = collectionView.cellForItem(at: indexPath) as? FilterCell else {
               return true
           }
           if cell.isSelected {
               collectionView.deselectItem(at: indexPath, animated: true)
               return false
           } else {
               return true
           }
       }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 108) / 4
        return CGSize(width: width, height: 30)
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

class FilterCell: UICollectionViewCell {
    
    let titleLb = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        self.layer.cornerRadius = 12
        addSubview(titleLb)
        titleLb.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.titleLb.textColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
                self.backgroundColor = UIColor(red: 0.427, green: 0.459, blue: 0.506, alpha: 1)
                
            } else {
                self.titleLb.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
                self.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
            }
        }
    }
    
    
    
    
}

