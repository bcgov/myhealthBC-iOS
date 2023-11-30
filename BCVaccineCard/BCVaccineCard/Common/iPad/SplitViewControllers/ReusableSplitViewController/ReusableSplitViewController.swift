//
//  ReusableSplitViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-11-21.
//

import UIKit
// NOTE: Not using for now, not until I can get things sorted
class ReusableSplitViewController: UISplitViewController {
    
//    class func construct(baseVC: UIViewController, secondVC: UIViewController?, tabIndex: Int) -> ReusableSplitViewController {
//        if let vc =  Storyboard.iPadHome.instantiateViewController(withIdentifier: String(describing: ReusableSplitViewController.self)) as? ReusableSplitViewController {
//            vc.tabIndex = tabIndex
//            vc.baseVC = baseVC
//            vc.secondVC = secondVC
//            return vc
//        }
//        return ReusableSplitViewController()
//    }
    
    class func construct(baseVC: UIViewController, secondVC: UIViewController?, tabIndex: Int) -> ReusableSplitViewController {
        var vc: ReusableSplitViewController
        if #available(iOS 14.0, *) {
            vc = ReusableSplitViewController(style: .doubleColumn)
        } else {
            vc = ReusableSplitViewController()
        }
        vc.baseVC = baseVC
        vc.secondVC = secondVC
        vc.tabIndex = tabIndex
        return vc
    }
    
    private var tabIndex: Int = 0
    private var baseVC: UIViewController?
    private var secondVC: UIViewController?
    
    private var masterVC: iPadSideTabTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    // TODO: Modify:
    // 340 width for primary - reversed
    // configure for both compact and landscape
    private func setup() {
        delegate = self
        masterVC = iPadSideTabTableViewController.construct(with: tabIndex)
        if #available(iOS 14.0, *) {
            setViewController(masterVC!, for: .primary)
        } else {
            self.viewControllers = [masterVC!]
        }
        if let baseVC = baseVC {
//            self.viewControllers.append(baseVC)
            if #available(iOS 14.0, *) {
                setViewController(baseVC, for: .supplementary)
            } else {
                self.viewControllers.append(baseVC)
            }
        }
        if let secondVC = secondVC {
            if #available(iOS 14.0, *) {
//                self.viewControllers.append(secondVC)
                setViewController(secondVC, for: .secondary)
            } else {
                self.viewControllers.append(secondVC)
            }
        }
                
        if #available(iOS 14.0, *) {
            preferredDisplayMode = .twoBesideSecondary
        } else {
            preferredDisplayMode = .oneBesideSecondary
        }
        if #available(iOS 14.0, *) {
            preferredSplitBehavior = .tile
        }
        presentsWithGesture = false
        if #available(iOS 14.0, *) {
            self.preferredPrimaryColumnWidth = 92
            if self.viewControllers.count > 2 {
                preferredSupplementaryColumnWidth = 621
//                preferredSupplementaryColumnWidthFraction = 621/self.view.frame.width
                minimumSupplementaryColumnWidth = 600
            }
        } else {
            self.preferredPrimaryColumnWidthFraction = 92/self.view.frame.width
        }
        
        primaryEdge = .trailing
    }
    
    func configure() {
        
    }

}

extension ReusableSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        return true
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
