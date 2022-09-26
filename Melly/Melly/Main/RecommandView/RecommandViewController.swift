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

    let mainSV = UIScrollView().then {
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        mainSV.addSubview(recomandLabel)
        recomandLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(43)
            $0.leading.equalToSuperview().offset(30)
        }
        
        mainSV.addSubview(recommandSubLabel)
        recommandSubLabel.snp.makeConstraints {
            $0.top.equalTo(recomandLabel.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(30)
        }
        
        mainSV.updateContentSize()
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
