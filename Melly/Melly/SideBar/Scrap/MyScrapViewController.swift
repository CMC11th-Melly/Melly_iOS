//
//  ScrapViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/29.
//

import UIKit
import RxSwift
import RxCocoa


class MyScrapViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let vm = MyScrapViewModel.instance
    
    let headerView = UIView()
    
    let backBT = BackButton()
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.102, green: 0.118, blue: 0.153, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "스크랩"
    }
    
    let noDataView = UIView().then {
        $0.alpha = 0
    }
    
    let noDataFrame = UIView()
    
    let noDataImg = UIImageView(image: UIImage(named: "push_no_data"))
    
    let noDataLabel = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 20)
        $0.text = "내가 스크랩한 장소가 없습니다."
    }
    
    let dataCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.scrapObserver.accept(())
    }

}

extension MyScrapViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        
        safeArea.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        
        headerView.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(27)
        }
        
        headerView.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.height.equalTo(24)
            $0.leading.equalTo(backBT.snp.trailing).offset(12)
        }
        
        safeArea.addSubview(noDataView)
        noDataView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(36)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        noDataView.addSubview(noDataFrame)
        noDataFrame.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(92)
        }
        
        noDataFrame.addSubview(noDataImg)
        noDataImg.snp.makeConstraints {
            $0.centerX.top.equalToSuperview()
            $0.height.width.equalTo(46)
        }
        
        noDataFrame.addSubview(noDataLabel)
        noDataLabel.snp.makeConstraints {
            $0.top.equalTo(noDataImg.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        safeArea.addSubview(dataCV)
        dataCV.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(36)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        dataCV.delegate = nil
        dataCV.dataSource = nil
        dataCV.rx.setDelegate(self).disposed(by: disposeBag)
        dataCV.register(ScrapCell.self, forCellWithReuseIdentifier: "cell")
        
        dataCV.rx.itemSelected
            .map { index in
                let cell = self.dataCV.cellForItem(at: index) as! ScrapCell
                return cell.scrapCount!
            }.bind(to: vm.input.goScrapDetailObserver)
            .disposed(by: disposeBag)
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    private func bindOutput() {
        
        vm.output.scrapValue
            .bind(to: dataCV.rx.items(cellIdentifier: "cell", cellType: ScrapCell.self)) { row, element, cell in
                cell.scrapCount = element
            }.disposed(by: disposeBag)
        
        vm.output.goToScrapDetail
            .subscribe(onNext: {
                let vc = ScrapDetailViewController()
                vc.modalTransitionStyle = .coverVertical
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.isNoData
            .subscribe(onNext: { value in
                if value {
                    self.noDataView.alpha = 1
                    self.dataCV.alpha = 0
                } else {
                    self.noDataView.alpha = 0
                    self.dataCV.alpha = 1
                }
            }).disposed(by: disposeBag)
        
    }
    
    
}

extension MyScrapViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: self.view.frame.width-60, height: 76)
    }
    
    
    
}

final class ScrapCell: UICollectionViewCell {
    
    var scrapCount:ScrapCount? {
        didSet {
            setData()
        }
    }
    
    let imageView = UIImageView(image: UIImage(named: "profile"))
    
    let groupNameLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 18)
    }
    
    let scrapCountLB = UILabel().then {
        $0.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1.2
        layer.borderColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1).cgColor
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.width.equalTo(40)
        }
        
        addSubview(groupNameLB)
        groupNameLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(12)
            $0.height.equalTo(22)
        }
        
        addSubview(scrapCountLB)
        scrapCountLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(17)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        
    }
    
    private func setData() {
        
        if let scrapCount = scrapCount {
            
            switch scrapCount.scrapType {
            case "FAMILY":
                groupNameLB.text = "가족이랑 가고 싶은 곳"
                imageView.image = UIImage(named: "group_icon_1")
            case "COMPANY":
                groupNameLB.text = "동료랑 가고 싶은 곳"
                imageView.image = UIImage(named: "group_icon_6")
            case "COUPLE":
                groupNameLB.text = "연인이랑 가고 싶은 곳"
                imageView.image = UIImage(named: "group_icon_8")
            case "FRIEND":
                groupNameLB.text = "친구랑 가고 싶은 곳"
                imageView.image = UIImage(named: "group_icon_4")
            default:
                break
            }
            
            scrapCountLB.text = "총 \(scrapCount.scrapCount)개"
            
        }
        
    }
    
    
    
    
}

