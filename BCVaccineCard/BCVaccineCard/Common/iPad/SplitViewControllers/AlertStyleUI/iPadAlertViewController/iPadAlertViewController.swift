//
//  iPadAlertViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-12-15.
//

import UIKit

class iPadAlertViewController: UIViewController {
    
    class func construct(with splitVC: iPadAlertSplitVC) -> iPadAlertViewController {
        var vc = iPadAlertViewController()
        vc.splitVC = splitVC
        return vc
    }
    
    private weak var splitVC: iPadAlertSplitVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = AppColours.backgroundGray
        addSplitVCToSelf()
    }
    
    private func addSplitVCToSelf() {
        guard let splitVC = splitVC else { return }
        self.view.addSubview(splitVC.view)
    }
}
