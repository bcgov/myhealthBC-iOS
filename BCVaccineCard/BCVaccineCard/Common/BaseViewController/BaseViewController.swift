//
//  BaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

protocol NavigationSetupProtocol: AnyObject {
    func setNavigationBarWith(title: String, andImage image: UIImage?, action: Selector?)
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
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func setNavigationBarWith(title: String, andImage image: UIImage?, action: Selector?) {
        navigationItem.title = title
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        guard let action = action else {
                nav.hideRightBarButtonItem()
            return
        }
        nav.setImageAndTarget(image: image, action: action, target: self)
    }
}


