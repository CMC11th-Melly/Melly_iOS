//
//  UIKitExtension.swift
//  Melly
//
//  Created by Jun on 2022/09/07.
//

import Foundation
import UIKit

extension UIViewController {
    
    //safeArea 영역의 view를 생성
    var safeArea:UIView {
        get {
            guard let safeArea = self.view.viewWithTag(Int(INT_MAX)) else {
                let guide = self.view.safeAreaLayoutGuide
                let view = UIView()
                view.tag = Int(INT_MAX)
                self.view.addSubview(view)
                view.snp.makeConstraints {
                    $0.edges.equalTo(guide)
                }
                return view
            }
            return safeArea
        }
    }
    
    var apiLoadingView:UIAlertController {
        get {
            let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
            
            let indicator = UIActivityIndicatorView(frame: .zero).then {
                $0.style = .large
                $0.hidesWhenStopped = true
                $0.startAnimating()
                $0.tintColor =  UIColor(red: 0.274, green: 0.173, blue: 0.9, alpha: 1)
            }
            
            alert.view.addSubview(indicator)
            indicator.snp.makeConstraints {
                $0.centerY.centerX.equalToSuperview()
                $0.width.height.equalTo(50)
            }
            
            
            
            return alert
        }
    }
    
    
}



extension UISegmentedControl {
    
    //기존에 있던 보더라인 삭제
    func removeBorder() {
        let background = UIImage()
        self.setBackgroundImage(background, for: .normal, barMetrics: .default)
        self.setBackgroundImage(background, for: .selected, barMetrics: .default)
        self.setBackgroundImage(background, for: .highlighted, barMetrics: .default)
        
        self.setDividerImage(background, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 0.694, green: 0.722, blue: 0.753, alpha: 1)], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 0.427, green: 0.459, blue: 0.506, alpha: 1)], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 16)!], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 16)!], for: .normal)
    }
    
    //클릭시 하이라이트 표현
    func highlightSelectedSegment() {
        removeBorder()
        let lineWidth:CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let lineHeight:CGFloat = 2.0 // setheight of underline height
        let lineXPosition = CGFloat(selectedSegmentIndex*Int(lineWidth))
        let lineYPosition = self.bounds.size.height
        let underLineFrame = CGRect(x: lineXPosition, y: lineYPosition, width: lineWidth, height: lineHeight)
        let underLine = UIView(frame: underLineFrame)
        underLine.backgroundColor = UIColor(red: 0.427, green: 0.459, blue: 0.506, alpha: 1)
        underLine.tag = 1
        self.addSubview(underLine)
        
        
    }
    
    //세그먼트 바텀 라인에 밑줄 만들기
    func underlinePosition() {
        
        guard let underLine = self.viewWithTag(1) else { return }
        let xPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut) {
            underLine.frame.origin.x = xPosition
        }
        
    }
}

extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}

