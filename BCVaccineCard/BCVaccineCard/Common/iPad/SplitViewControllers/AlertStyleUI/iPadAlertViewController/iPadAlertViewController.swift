//
//  iPadAlertViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-12-15.
//

import UIKit

class iPadAlertViewController: BaseViewController {
    
    class func construct(with splitVC: iPadAlertSplitVC) -> iPadAlertViewController {
        let vc = iPadAlertViewController()
        vc.splitVC = splitVC
        return vc
    }
    
    private weak var splitVC: iPadAlertSplitVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = AppColours.disabledGray
        addSplitVCToSelf()
    }
    
    private func addSplitVCToSelf() {
        guard let splitVC = splitVC else { return }
//        let navController = CustomNavigationController(rootViewController: splitVC)
        addChild(splitVC)
        self.view.addSubview(splitVC.view)
        splitVC.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        splitVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 100).isActive = true
        splitVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        splitVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 100).isActive = true
        
        splitVC.didMove(toParent: self)
    }
}
