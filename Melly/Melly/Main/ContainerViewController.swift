//
//  ContainerViewController.swift
//  Melly
//
//  Created by Jun on 2022/09/13.
//

import UIKit
import RxCocoa
import RxSwift

class ContainerViewController: UIViewController {

   
    private let disposeBag = DisposeBag()
    let vm = ContainerViewModel.instance
    private var menuState:MenuState = .closed
    
    let sideBarVC = SideBarViewController()
    let homeVC = MainMapViewController()
    var navVC:UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bind()
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToInviteGroup), name: NSNotification.InviteGroupNotification, object: nil)
        
    }
    
}

extension ContainerViewController {
    
    @objc func goToInviteGroup(_ notification: Notification) {
        
        if let value = notification.object as? [String] {
            let vm = InviteGroupViewModel(userId: value[1], groupId: value[0])
            let vc = InviteGroupViewController(vm: vm)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        
        
    }
    
    private func setUI() {
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
    
    private func bind() {
        
        vm.output.errorValue.asDriver(onErrorJustReturn: "")
            .drive(onNext: { value in
                let alert = UIAlertController(title: "에러", message: value, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.logoutValue
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        vm.output.withDrawValue
            .subscribe(onNext: {
                UserDefaults.standard.set(nil, forKey: "loginUser")
                UserDefaults.standard.set(nil, forKey: "token")
                User.loginedUser = nil
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
    }
    
}

//MARK: - Home Custom Delegate
extension ContainerViewController: HomeViewControllerDelegate {
    
    /**
     sidebar를 열고 닫는 함수
     - Parameters:None
     - Throws: None
     - Returns:None
     */
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
