//
//  BaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

enum BarButtonType {
    case none, back, search, edit, done, close, clearAll, viewOptions
}

protocol NavigationSetupProtocol: AnyObject {
    func setNavigationBarWith(title: String, andImage image: UIImage?, action: Selector?)
}

class BaseViewController: UIViewController, NavigationSetupProtocol {
    
    weak var navDelegate: NavigationSetupProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetup()
    }
    
    private func setup() {
        navigationSetup()
    }
    
}

// MARK: Navigation setup
extension BaseViewController {
    private func navigationSetup() {
        navigationItem.backItemTitle(with: "")
        self.navDelegate = self
    }
    
    func setNavigationBarWith(title: String, andImage image: UIImage?, action: Selector?) {
        let rightButton = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
        navigationItem.rightBarButtonItem = rightButton
    }
}
