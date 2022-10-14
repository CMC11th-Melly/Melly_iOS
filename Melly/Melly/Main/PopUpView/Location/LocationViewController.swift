//
//  LocationViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/05.
//

import UIKit
import RxSwift
import RxCocoa


class LocationViewController: UIViewController {

    let vm = PopUpViewModel.instance
    
    var place:Place? {
        didSet {
            setData()
        }
    }
    
    let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let disposeBag = DisposeBag()
    
    let locationLB = UILabel().then {
        $0.text = "상수동"
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Bold", size: 20)
    }
    
    let categoryLB = UILabel().then {
        $0.textColor = UIColor(red: 0.545, green: 0.584, blue: 0.631, alpha: 1)
        $0.text = "거리"
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let bookmarkBT = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "bookmark"), for: .normal)
    }
    
    let myMemoryLB = UILabel().then {
        $0.text = "내 메모리 5개"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        $0.layer.cornerRadius = 12
    }
    
    let ourMemoryLB = UILabel().then {
        $0.text = "이 장소에 저장된 메모리 20개"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
        $0.layer.cornerRadius = 12
    }
    
    let showMemoryBT = UIButton(type: .custom).then {
        $0.setTitle("메모리 보기", for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.titleLabel?.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
        $0.layer.cornerRadius = 12
        
    }
    
    let writeMemoryBT = UIButton(type: .custom).then {
        $0.setTitle("메모리 쓰기", for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.titleLabel?.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.backgroundColor = UIColor(red: 0.886, green: 0.898, blue: 0.914, alpha: 1)
        $0.layer.cornerRadius = 12
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
}

extension LocationViewController {
    
    func setUI() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(248)
        }
        
        contentView.addSubview(locationLB)
        locationLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(47)
            $0.leading.equalToSuperview().offset(34)
        }
        
        contentView.addSubview(categoryLB)
        categoryLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(52)
            $0.leading.equalTo(locationLB.snp.trailing).offset(6)
        }
        
        contentView.addSubview(bookmarkBT)
        bookmarkBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(49)
            $0.trailing.equalToSuperview().offset(-31)
        }
        
        contentView.addSubview(myMemoryLB)
        myMemoryLB.snp.makeConstraints {
            $0.top.equalTo(locationLB.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(30)
        }
        
        contentView.addSubview(ourMemoryLB)
        ourMemoryLB.snp.makeConstraints {
            $0.top.equalTo(locationLB.snp.bottom).offset(27)
            $0.leading.equalTo(myMemoryLB.snp.trailing).offset(10)
            $0.height.equalTo(30)
        }
        
        contentView.addSubview(showMemoryBT)
        showMemoryBT.snp.makeConstraints {
            $0.top.equalTo(myMemoryLB.snp.bottom).offset(29)
            $0.leading.equalToSuperview().offset(30)
            $0.height.equalTo(56)
            $0.width.equalTo((self.view.frame.width - 70) / 2)
        }
        
        contentView.addSubview(writeMemoryBT)
        writeMemoryBT.snp.makeConstraints {
            $0.top.equalTo(myMemoryLB.snp.bottom).offset(29)
            $0.leading.equalTo(showMemoryBT.snp.trailing).offset(10)
            $0.height.equalTo(56)
            $0.width.equalTo((self.view.frame.width - 70) / 2)
        }
        
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        bookmarkBT.rx.tap
            .map { self.place! }
            .bind(to: vm.input.bookmarkPopUpObserver)
            .disposed(by: disposeBag)
        
        showMemoryBT.rx.tap.subscribe(onNext: {
            MemoryListViewModel.instance.place = self.place
            let vc = MemoryListViewController()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }).disposed(by: disposeBag)
        
        writeMemoryBT.rx.tap.subscribe(onNext: {
            let vm = MemoryWriteViewModel(self.place!)
            let vc = MemoryWriteViewController(vm: vm)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }).disposed(by: disposeBag)
    }
    
    func bindOutput() {
        vm.output.completeBookmark.asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                self.place?.isScraped = true
            }).disposed(by: disposeBag)
    }
    
    func setData() {
        
        if let place = place {
            locationLB.text = place.placeName
            categoryLB.text = place.placeCategory
            myMemoryLB.text = "내 메모리 \(place.myMemoryCount)개"
            ourMemoryLB.text = "이 장소에 저장된 메모리 \(place.otherMemoryCount)개"
        }
        
    }
    
}
