//
//  CustomNavigationController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-27.
// TODO: remove non-native buttons being added and scaled and create a more reusable nav controller for the whole app. Use this as base branch

import UIKit

class CustomNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    private func setup() {
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationBar.sizeToFit()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColours.appBlue]
        navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColours.appBlue]
        navigationBar.tintColor = AppColours.appBlue
        navigationController?.navigationBar.barTintColor = .white
    }
    
    func setImageAndTarget(image: UIImage?, action: Selector, target: UIViewController?) {
        guard let vc = target else { return }
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
    }
    
    func getRightBarButtonItem() -> UIBarButtonItem? {
        return self.navigationItem.rightBarButtonItem
    }
    
    func hideRightBarButtonItem() {
        self.navigationItem.rightBarButtonItem = nil
    }

}

