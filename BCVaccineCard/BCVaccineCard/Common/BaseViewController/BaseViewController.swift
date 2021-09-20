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
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColours.appBlue]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColours.appBlue]
        navigationController?.navigationBar.tintColor = AppColours.appBlue
        navigationController?.navigationBar.barTintColor = .white
        self.navDelegate = self
    }
    
    func setNavigationBarWith(title: String, andImage image: UIImage?, action: Selector?) {
        navigationItem.title = title
        let rightButton = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
        navigationItem.rightBarButtonItem = rightButton
    }
}

//MARK: Pop-back functions
extension BaseViewController {
    //Position in stack popback
    func popBackBy(_ x: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < x else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - x], animated: true)
                return
            }
        }
    }
    
    //Specific VC in stack
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        if var viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            viewControllers = viewControllers.reversed()
            for currentViewController in viewControllers {
                if currentViewController .isKind(of: toControllerType) {
                    self.navigationController?.popToViewController(currentViewController, animated: true)
                    break
                }
            }
        }
    }
}
