//
//  ScrapViewController.swift
//  Melly
//
//  Created by Jun on 2022/10/11.
//

import UIKit
import RxCocoa
import RxSwift
import Then



class ScrapViewController: UIViewController {

    let disposeBag = DisposeBag()
    let vm = PopUpViewModel.instance
    
    let contentView = UIView()
    let place:Place
    
    let bookmarkCV:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let buttonView = UIView()
    
    let cancelBT = DefaultButton("취소", false)
    
    // MARK: 스크랩 선택 안했을경우 색으로 구분
    let confirmBT = CustomButton(title: "스크랩 저장").then {
        $0.isEnabled = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
    }
    
    init(_ place: Place) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension ScrapViewController {
    
    private func setUI() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(buttonView)
        buttonView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(110)
        }
        
        buttonView.addSubview(cancelBT)
        cancelBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo((self.view.frame.width - 70) / 2)
            $0.height.equalTo(56)
        }
        
        buttonView.addSubview(confirmBT)
        confirmBT.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalTo(cancelBT.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(56)
        }
        
        contentView.addSubview(bookmarkCV)
        bookmarkCV.snp.makeConstraints {
            $0.top.equalToSuperview().offset(51)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonView.snp.top)
        }
        
    }
    
    private func bind() {
        
        bookmarkCV.dataSource = nil
        bookmarkCV.delegate = nil
        bookmarkCV.rx.setDelegate(self).disposed(by: disposeBag)
        bookmarkCV.register(BookmarkCell.self, forCellWithReuseIdentifier: "cell")
        
        vm.output.bookmarkObserver
            .bind(to: bookmarkCV.rx.items(cellIdentifier: "cell", cellType: BookmarkCell.self)) { row, element, cell in
                cell.group = element
            }.disposed(by: disposeBag)
        
        bookmarkCV.rx.itemSelected
            .map { index in
                let cell = self.bookmarkCV.cellForItem(at: index) as! BookmarkCell
                return cell.group?.rawValue
            }
            .bind(to: vm.input.filterObserver)
            .disposed(by: disposeBag)
        
        cancelBT.rx.tap
            .bind(to: vm.input.hideBookmarkPopUpObserver)
            .disposed(by: disposeBag)
        
        vm.output.bmButtonEnable.asDriver(onErrorJustReturn: false)
            .drive(onNext: { value in
                if value {
                    self.confirmBT.isEnabled = true
                } else {
                    self.confirmBT.isEnabled = false
                }
            }).disposed(by: disposeBag)
        
        confirmBT.rx.tap
            .map { self.place }
            .bind(to: vm.input.addBookmarkObserver)
            .disposed(by: disposeBag)
        
    }
    
}

extension ScrapViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
           guard let cell = collectionView.cellForItem(at: indexPath) as? BookmarkCell else {
               return true
           }
           if cell.isSelected {
               collectionView.deselectItem(at: indexPath, animated: true)
               vm.input.filterObserver.accept(nil)
               return false
           } else {
               return true
           }
       }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width - 60
        return CGSize(width: width, height: 56)
    }
    
}



class BookmarkCell: UICollectionViewCell {
    
    var group:GroupFilter? {
        didSet {
            switch group {
            case .company:
                titleLB.text = "동료랑 가고 싶은 곳"
            case .couple:
                titleLB.text = "연인이랑 가고 싶은 곳"
            case .family:
                titleLB.text = "가족이랑 가고 싶은 곳"
            case .friend:
                titleLB.text = "친구랑 가고 싶은 곳"
            default:
                break
            }
        }
    }
    
    let imageView = UIImageView(image: UIImage(named: "scrap_unselected"))
    let titleLB = UILabel().then {
        $0.text = "친구랑 가고 싶은 곳"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1).cgColor
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(27)
            $0.width.height.equalTo(22)
        }
        
        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(17)
            $0.height.equalTo(19)
        }
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.image = UIImage(named: "scrap_selected")
                titleLB.textColor = .white
                backgroundColor = UIColor(red: 0.249, green: 0.161, blue: 0.788, alpha: 1)
            } else {
                imageView.image = UIImage(named: "scrap_unselected")
                titleLB.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
                backgroundColor = .white
            }
        }
    }
}
