//
//  BaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

protocol NavigationSetupProtocol: AnyObject {
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, targetVC vc: UIViewController, backButtonHintString: String?)
}

class BaseViewController: UIViewController, NavigationSetupProtocol, Theme {
    
    weak var navDelegate: NavigationSetupProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetup()
        performLocalAuthIfNeeded()
        listenToLocalAuthNotification()
    }
    
    func listenToLocalAuthNotification() {
        Notification.Name.shouldPerformLocalAuth.onPost(object: nil, queue: .main) {[weak self] _ in
            guard let `self` = self, UIApplication.topViewController() == self else {return}
            self.performLocalAuthIfNeeded()
        }
    }
    
    func performLocalAuthIfNeeded() {
        if LocalAuthManager.shouldAuthenticate {
            showLocalAuth()
        }
    }
    
}

// MARK: Navigation setup
extension BaseViewController {
    private func navigationSetup() {
        self.navDelegate = self
    }
    
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, targetVC vc: UIViewController, backButtonHintString: String?) {
        navigationItem.title = title
       
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        nav.setupNavigation(leftNavButton: left, rightNavButton: right, navStyle: navStyle, targetVC: vc, backButtonHintString: backButtonHintString)
    }
}

// MARK: For Settings Navigation
extension BaseViewController {
    @objc func settingsButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        goToSettingsScreen()
    }
    
    private func goToSettingsScreen() {
        let vc = profileAndSettingsViewController.constructProfileAndSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


