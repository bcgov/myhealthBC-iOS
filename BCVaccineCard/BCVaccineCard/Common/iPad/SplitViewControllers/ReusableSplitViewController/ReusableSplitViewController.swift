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
    
    class func construct(baseVC: UIViewController, secondVC: UIViewController?, tabIndex: Int, tabType: AppTabs) -> ReusableSplitViewController {
        var vc: ReusableSplitViewController
        if #available(iOS 14.0, *) {
            vc = ReusableSplitViewController(style: .doubleColumn)
        } else {
            vc = ReusableSplitViewController()
        }
        vc.baseVC = baseVC
        vc.secondVC = secondVC
        vc.tabIndex = tabIndex
        vc.tabType = tabType
        return vc
    }
    
    private var tabIndex: Int = 0
    private var baseVC: UIViewController?
    private var secondVC: UIViewController?
    private var tabType: AppTabs = .Home
    
    private var masterVC: iPadSideTabTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    // TODO: Cleanup
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: .deviceDidRotate, object: nil)
        delegate = self
        var rightVC: UIViewController
        if let secondVC = secondVC {
            rightVC = secondVC
        } else {
            rightVC = CustomNavigationController.init(rootViewController: UIViewController())
        }
        
        if #available(iOS 14.0, *) {
            setViewController(rightVC, for: .primary)
        } else {
            self.viewControllers = [rightVC]
        }
        if let baseVC = baseVC {
            if #available(iOS 14.0, *) {
                setViewController(baseVC, for: .secondary)
            } else {
                self.viewControllers.append(baseVC)
            }
        }
                
        if #available(iOS 14.0, *) {
            preferredSplitBehavior = .tile
        }
        presentsWithGesture = false
        primaryEdge = .trailing
        if secondVC != nil {
            preferredPrimaryColumnWidthFraction = 1.0
            if #available(iOS 14.0, *) {
                if UIDevice.current.orientation.isLandscape {
                    preferredDisplayMode = .oneBesideSecondary
                } else {
                    preferredDisplayMode = .secondaryOnly
                }
                
            } else {
                preferredDisplayMode = .allVisible
            }
        } else {
            if #available(iOS 14.0, *) {
                preferredDisplayMode = .secondaryOnly
            } else {
                preferredDisplayMode = .primaryHidden
            }
        }
        
        
    }
    
    func configure() {
        
    }
    
    // TODO: Create function to reload primary VC for when device is in landscape mode
    
    func isVCAlreadyShown(viewController: UIViewController) -> Bool {
        guard let nav = self.secondVC as? CustomNavigationController, let rightVC = nav.viewControllers.first else { return false }
        return type(of: viewController) == type(of: rightVC)
    }
    
    func adjustFarRightVC(viewController: UIViewController) {
        let nav = CustomNavigationController(rootViewController: viewController)
        self.secondVC = nav
        guard let rightVC = self.secondVC else { return }
        if #available(iOS 14.0, *) {
            setViewController(rightVC, for: .primary)
        } else {
            self.viewControllers.insert(rightVC, at: 0)
        }
    }
    

}

extension ReusableSplitViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard Constants.deviceType == .iPad else { return }
        NotificationCenter.default.post(name: .deviceDidRotate, object: nil)
    }
    
    @objc private func deviceDidRotate(_ notification: Notification) {
        if !UIDevice.current.orientation.isLandscape {
            if #available(iOS 14.0, *) {
                hide(.primary)
            } else {
                
            }
        }
    }
}

extension ReusableSplitViewController: UISplitViewControllerDelegate {
//    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
//        return false
//    }
//    @available(iOS 14.0, *)
//    func splitViewController(_ svc: UISplitViewController, displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode) -> UISplitViewController.DisplayMode {
//        return .secondaryOnly
//    }
//    
//    @available(iOS 14.0, *)
//    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
//        print("CONNOR: COLLAPSED")
//    }
//    
//    @available(iOS 14.0, *)
//    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
//        print("CONNOR: DID EXPAND")
//    }
    
}

