//
//  ContentViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/13.
//

import UIKit
import FloatingPanel
import RxSwift
import RxCocoa


class RecommandViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    let data = Observable<[String]>.of(["", "", "", ""])
    
    let mainSV = UIScrollView().then {
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
    let contentView = UIView()
    
    let recomandLabel = UILabel().then {
        let text = "소피아에게 추천하는 메모리 장소"
        let attributedString = NSMutableAttributedString(string: text)
        let font = UIFont(name: "Pretendard-Medium", size: 20)!
        let color = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
    }
    
    let recommandSubLabel = UILabel().then {
        $0.text = "비슷한 연령대가 이 장소에서 메모리를 많이 작성했어요"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let recommandCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let separator = UIView().then {
        $0.backgroundColor = UIColor(red: 0.945, green: 0.953, blue: 0.961, alpha: 1)
    }
    
    let hotLabel = UILabel().then {
        let text = "요즘 핫한 메모리 장소"
        let attributedString = NSMutableAttributedString(string: text)
        let font = UIFont(name: "Pretendard-Medium", size: 20)!
        let color = UIColor(red: 0.098, green: 0.122, blue: 0.157, alpha: 1)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
    }
    
    let hotSubLabel = UILabel().then {
        $0.text = "동시간대 가장 많이 메모리가 작성되고 있는 장소예요"
        $0.textColor = UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    let hotLocationCV: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCV()
        setUI()
        bind()
        
    }
    
}

extension RecommandViewController {
    
    func setUI() {
        view.backgroundColor = .white
        
        safeArea.addSubview(mainSV)
        mainSV.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainSV.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(recomandLabel)
        recomandLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(43)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(recommandSubLabel)
        recommandSubLabel.snp.makeConstraints {
            $0.top.equalTo(recomandLabel.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(recommandCV)
        recommandCV.snp.makeConstraints {
            $0.top.equalTo(recommandSubLabel.snp.bottom)
            $0.leading.trailing.equalTo(safeArea)
            $0.height.equalTo(1134)
        }
        
        
        contentView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.leading.trailing.equalTo(safeArea)
            $0.height.equalTo(1)
            $0.top.equalTo(recommandCV.snp.bottom).offset(28)
        }
        
        contentView.addSubview(hotLabel)
        hotLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(hotSubLabel)
        hotSubLabel.snp.makeConstraints {
            $0.top.equalTo(hotLabel.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(30)
        }
        
        contentView.addSubview(hotLocationCV)
        hotLocationCV.snp.makeConstraints {
            $0.top.equalTo(hotSubLabel.snp.bottom)
            $0.leading.trailing.equalTo(safeArea)
            $0.height.equalTo(1139)
            $0.bottom.equalToSuperview()
        }
        
        //mainSV.updateContentSize()
    }
    
    func setCV() {
        recommandCV.dataSource = nil
        recommandCV.delegate = nil
        recommandCV.rx.setDelegate(self).disposed(by: disposeBag)
        recommandCV.register(RecommandCollectionViewCell.self, forCellWithReuseIdentifier: "recommand")
        
        data
            .bind(to: recommandCV.rx.items(cellIdentifier: "recommand", cellType: RecommandCollectionViewCell.self)) { row, element, cell in
                
            }.disposed(by: disposeBag)
        
        hotLocationCV.dataSource = nil
        hotLocationCV.delegate = nil
        hotLocationCV.rx.setDelegate(self).disposed(by: disposeBag)
        hotLocationCV.register(RecommandCollectionViewCell.self, forCellWithReuseIdentifier: "hot")
        data
            .bind(to: hotLocationCV.rx.items(cellIdentifier: "hot", cellType: RecommandCollectionViewCell.self)) { row, element, cell in
                
            }.disposed(by: disposeBag)
    }
    
    func bind() {
        bindInput()
        bindOutput()
    }
    
    func bindInput() {
        
    }
    
    func bindOutput() {
        
    }
    
}

extension RecommandViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 33, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width - 60
        return CGSize(width: width, height: 342)
    }
    
}
