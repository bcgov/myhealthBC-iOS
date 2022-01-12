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

class BaseViewController: UIViewController, NavigationSetupProtocol {
    
    weak var navDelegate: NavigationSetupProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetup()
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
        let vc = SettingsViewController.constructSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


