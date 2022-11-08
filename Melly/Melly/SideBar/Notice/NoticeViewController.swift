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
        $0.text = "알림"
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
    
    override func viewWillAppear(_ animated: Bool) {
        vm.input.initialObserver.accept(())
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
        
        noticeCV.rx.itemSelected
            .map { index in
                let cell = self.noticeCV.cellForItem(at: index) as! NoticeCell
                return cell.push!
            }.bind(to: vm.input.selectNoticeObserver)
            .disposed(by: disposeBag)
        
        backBT.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.noticeData
            .bind(to: noticeCV.rx.items(cellIdentifier: "cell", cellType: NoticeCell.self)) { row, element, cell in
                cell.push = element
            }.disposed(by: disposeBag)
        
        
    }
    
    private func bindOutput() {
        
        vm.output.errorValue.asDriver(onErrorJustReturn: "")
            .drive(onNext: { value in
                
                let alert = UIAlertController(title: "에러", message: value, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(alertAction)
                self.present(alert, animated: true)
                
            }).disposed(by: disposeBag)
        
        vm.output.selectMemory.subscribe(onNext: { value in
            
            let vm = MemoryDetailViewModel(value)
            let vc = MemoryDetailViewController(vm: vm)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }).disposed(by: disposeBag)
        
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
    
    var push:Push? {
        didSet {
            setData()
        }
    }
    
    let imageFrame = UIView().then {
        $0.layer.cornerRadius = 23
    }
    
    let imageView = UIImageView().then {
        $0.clipsToBounds = true
    }
    
    let titleLB = UILabel().then {
        $0.textColor = UIColor(red: 0.472, green: 0.503, blue: 0.55, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.text = "신고"
    }
    
    let contentLB = UILabel().then {
        $0.textColor = UIColor(red: 0.302, green: 0.329, blue: 0.376, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        $0.text = "메모리에 신고가 들어왔어요! 확인해보세요"
    }
    
    let dateLB = UILabel().then {
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
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
        
        addSubview(imageFrame)
        
        imageFrame.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(46)
        }
        
        imageFrame.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.width.equalTo(21)
        }
        
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.height.equalTo(19)
            $0.leading.equalTo(imageFrame.snp.trailing).offset(14)
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
            $0.leading.equalTo(imageFrame.snp.trailing).offset(14)
            $0.height.equalTo(22)
        }
        
    }
    
    func setData() {
        
        if let push = push {
            
            if push.type == "COMMENT" {
                titleLB.text = "댓글"
                imageView.image = UIImage(named: "push_comment")
                if push.checked {
                    imageFrame.backgroundColor = .clear
                    backgroundColor = .white
                } else {
                    imageFrame.backgroundColor = UIColor(red: 0.859, green: 0.863, blue: 0.957, alpha: 1)
                    backgroundColor = UIColor(red: 0.975, green: 0.979, blue: 0.988, alpha: 1)
                }
            } else {
                titleLB.text = "신고"
                imageView.image = UIImage(named: "push_report")
                if push.checked {
                    imageFrame.backgroundColor = .clear
                    backgroundColor = .white
                } else {
                    imageFrame.backgroundColor = UIColor(red: 0.988, green: 0.901, blue: 0.911, alpha: 1)
                    backgroundColor = UIColor(red: 0.941, green: 0.945, blue: 0.984, alpha: 1)
                }
            }
            
            contentLB.text = push.content
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmm"
            
            let date = dateFormatter.date(from: push.date) ?? Date()
            
            dateLB.text = date.timeAgoDisplay()
            
        }
        
    }
    
    
}
