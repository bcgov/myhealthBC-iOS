//
//  ReusableSplitViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-11-21.
//

import UIKit
// NOTE: Not using for now, not until I can get things sorted
class ReusableSplitViewController: UISplitViewController {
    
    class func construct(masterVC: UIViewController, secondaryVC: UIViewController?) -> ReusableSplitViewController {
        if let vc =  Storyboard.iPadHome.instantiateViewController(withIdentifier: String(describing: ReusableSplitViewController.self)) as? ReusableSplitViewController {
            vc.masterVC = masterVC
            vc.secondaryVC = secondaryVC
            return vc
        }
        return ReusableSplitViewController()
    }
    
    private var masterVC: UIViewController?
    private var secondaryVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        delegate = self
        if let masterVC = masterVC {
            self.viewControllers = [masterVC]
        }
//        if let secondaryVC = secondaryVC {
//            self.viewControllers.append(secondaryVC)
//        }
        preferredDisplayMode = .oneBesideSecondary
        if #available(iOS 14.0, *) {
            preferredSplitBehavior = .tile
        }
        presentsWithGesture = false
        preferredPrimaryColumnWidthFraction = 2.0
    }
    
    func configure() {
        
    }

}

extension ReusableSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        return false
    }
}


class TestViewController: UIViewController {
    
    class func construct(tab: String) -> TestViewController {
        if let vc =  Storyboard.iPadHome.instantiateViewController(withIdentifier: String(describing: TestViewController.self)) as? TestViewController {
            vc.tab = tab
            return vc
        }
        return TestViewController()
    }
    
    private var tab: String!
    
    @IBOutlet weak private var labelTab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup(tab: tab)
        self.view.backgroundColor = .green
    }
    
    private func setup(tab: String) {
        labelTab.text = tab
    }
}
