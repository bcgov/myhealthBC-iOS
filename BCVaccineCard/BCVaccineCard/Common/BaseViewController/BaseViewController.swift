//
//  BaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

protocol NavigationSetupProtocol: AnyObject {
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, targetVC vc: UIViewController)
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
    
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, targetVC vc: UIViewController) {
        navigationItem.title = title
       
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        nav.setupNavigation(leftNavButton: left, rightNavButton: right, navStyle: navStyle, targetVC: vc)
    }
}


