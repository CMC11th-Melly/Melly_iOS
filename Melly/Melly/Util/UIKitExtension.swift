//
//  UIKitExtension.swift
//  Melly
//
//  Created by Jun on 2022/09/07.
//

import Foundation
import UIKit

extension UIViewController {
    
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
}

extension UIScrollView {
    func updateContentSize() {
        let unionCalculatedTotalRect = recursiveUnionInDepthFor(view: self)
        
        // 계산된 크기로 컨텐츠 사이즈 설정
        self.contentSize = CGSize(width: unionCalculatedTotalRect.width + 5, height: 192)
    }
    
    private func recursiveUnionInDepthFor(view: UIView) -> CGRect {
        var totalRect: CGRect = .zero
        
        // 모든 자식 View의 컨트롤의 크기를 재귀적으로 호출하며 최종 영역의 크기를 설정
        for subView in view.subviews {
            totalRect = totalRect.union(recursiveUnionInDepthFor(view: subView))
        }
        
        // 최종 계산 영역의 크기를 반환
        return totalRect.union(view.frame)
    }
}

extension UIImage {
    
    class func getSegRect(color: CGColor, size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        context?.fill(rectangle)
        
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
    
    
}

extension UISegmentedControl {
    
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
    
    //tap hightLight when select
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
    
    //set the position of bottom underline
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
