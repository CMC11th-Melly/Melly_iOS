//
//  NoticeViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/28.
//

import UIKit
import RxCocoa
import RxSwift

class NoticeViewController: UIViewController {
    let vm = NoticeViewModel()
    private let disposeBag = DisposeBag()
    let backBT = BackButton()
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.208, green: 0.235, blue: 0.286, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        $0.text = "설정"
    }
    
    let noticeCV:UICollectionView = {
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
    

}

extension NoticeViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        safeArea.addSubview(backBT)
        backBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(27)
        }
        
        safeArea.addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalTo(backBT.snp.trailing).offset(12)
        }
        
        safeArea.addSubview(noticeCV)
        noticeCV.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(33)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        
        noticeCV.delegate = nil
        noticeCV.dataSource = nil
        noticeCV.rx.setDelegate(self).disposed(by: disposeBag)
        noticeCV.register(NoticeCell.self, forCellWithReuseIdentifier: "cell")
        
//        noticeCV.rx.itemSelected
//            .map { index in
//                let cell = self.ageCV.cellForItem(at: index) as? SignUpCell
//                return cell?.textLB.text ?? ""
//            }.bind(to: vm.input.ageObserver)
//            .disposed(by: disposeBag)
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.noticeData
            .bind(to: noticeCV.rx.items(cellIdentifier: "cell", cellType: NoticeCell.self)) { row, element, cell in
                
            }.disposed(by: disposeBag)
        
        
    }
    
    private func bindOutput() {
        
    }
    
}


extension NoticeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: self.view.frame.width, height: 92)
    }
    
    
}

final class NoticeCell: UICollectionViewCell {
    
    lazy var imageView = UIImageView()
    
    lazy var titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.text = "신고"
    }
    
    lazy var contentLB = UILabel().then {
        $0.textColor = UIColor(red: 0.42, green: 0.463, blue: 0.518, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        $0.text = "메모리에 신고가 들어왔어요! 확인해보세요"
    }
    
    lazy var dateLB = UILabel().then {
        $0.textColor = UIColor(red: 0.588, green: 0.623, blue: 0.663, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.text = "1시간 전"
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
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(30)
            $0.height.width.equalTo(46)
        }
        
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.height.equalTo(19)
            $0.leading.equalTo(imageView.snp.trailing).offset(14)
        }
        
        addSubview(dateLB)
        dateLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.height.equalTo(19)
            $0.trailing.equalToSuperview().offset(-30)
        }
        
        addSubview(contentLB)
        contentLB.snp.makeConstraints {
            $0.top.equalTo(titleLB.snp.bottom).offset(4)
            $0.leading.equalTo(imageView.snp.trailing).offset(14)
        }
        
    }
    
    
}
