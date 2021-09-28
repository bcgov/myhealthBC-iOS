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
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.sizeToFit()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColours.appBlue]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColours.appBlue]
        navigationController?.navigationBar.tintColor = AppColours.appBlue
        navigationController?.navigationBar.barTintColor = .white
        self.navDelegate = self
    }
    
    func setNavigationBarWith(title: String, andImage image: UIImage?, action: Selector?) {
        navigationItem.title = title
        guard let action = action else { return }
        let rightButton = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
        navigationItem.rightBarButtonItem = rightButton
    }
}
