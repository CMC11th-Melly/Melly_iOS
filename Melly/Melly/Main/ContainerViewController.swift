//
//  ContainerViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/13.
//

import UIKit

class ContainerViewController: UIViewController {

   
    
    private var menuState:MenuState = .closed
    
    let sideBarVC = SideBarViewController()
    let homeVC = MainMapViewController()
    var navVC:UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
}

extension ContainerViewController {
    
    func setUI() {
        view.backgroundColor = .white
        
        
        addChild(sideBarVC)
        view.addSubview(sideBarVC.view)
        sideBarVC.didMove(toParent: self)
        
        //Home
        homeVC.delegate = self
        let navVC = UINavigationController(rootViewController: homeVC)
        addChild(navVC)
        view.addSubview(navVC.view)
        navVC.didMove(toParent: self)
        self.navVC = navVC
        
    }
    
}

extension ContainerViewController: HomeViewControllerDelegate {
    
    func didTapMenuButton() {
        switch menuState {
        case .closed:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.navVC?.view.frame.origin.x = self.homeVC.view.frame.size.width - 100
            } completion: { done in
                if done {
                    self.menuState = .opened
                }
            }

        case .opened:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.navVC?.view.frame.origin.x = 0
            } completion: { done in
                if done {
                    self.menuState = .closed
                }
            }
        }
    }
    
}
