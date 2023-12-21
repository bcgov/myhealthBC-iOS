//
//  iPadAlertSplitVC.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-12-15.
//

import UIKit
// TODO: Configure properly for the settings flow
class iPadAlertSplitVC: UISplitViewController {
    
    class func construct(baseVC: UIViewController, secondVC: UIViewController?) -> iPadAlertSplitVC {
        var vc: iPadAlertSplitVC
        if #available(iOS 14.0, *) {
            vc = iPadAlertSplitVC(style: .doubleColumn)
        } else {
            vc = iPadAlertSplitVC()
        }
        vc.baseVC = baseVC
        vc.secondVC = secondVC
        return vc
    }
    
    private var baseVC: UIViewController?
    private var secondVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configuration()
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: .deviceDidRotate, object: nil)
        delegate = self
        presentsWithGesture = false
    }
    
    private func configuration() {
        var leftVC: UIViewController
        if let baseVC = baseVC {
            leftVC = baseVC
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
            leftVC = CustomNavigationController.init(rootViewController: UIViewController())
            if #available(iOS 14.0, *) {
                preferredDisplayMode = .secondaryOnly
            } else {
                preferredDisplayMode = .primaryHidden
            }
        }
        
        if #available(iOS 14.0, *) {
            setViewController(leftVC, for: .primary)
        } else {
            self.viewControllers = [leftVC]
        }
        
        // Setup Base VC
        if let secondVC = secondVC {
            if #available(iOS 14.0, *) {
                setViewController(secondVC, for: .secondary)
            } else {
                self.viewControllers.append(secondVC)
            }
        }
                
        if #available(iOS 14.0, *) {
            preferredSplitBehavior = .tile
        }
        
    }
    
}

extension iPadAlertSplitVC {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard Constants.deviceType == .iPad else { return }
        NotificationCenter.default.post(name: .deviceDidRotate, object: nil)
        if UIDevice.current.orientation.isLandscape {
//            adjustLayoutForPortraitToLandscapeRotation()
        }
        // TODO: Make more reusable
        
        if #available(iOS 14.0, *) {
            if UIDevice.current.orientation.isLandscape {
                if let _ = secondVC {
                    preferredDisplayMode = .oneBesideSecondary
                } else {
                    preferredDisplayMode = .secondaryOnly
                }
            } else {
                preferredDisplayMode = .secondaryOnly
            }
            
        } else {
            preferredDisplayMode = .allVisible
        }
        
    }
    // TODO: Add in logic for settings flow for proper navigation
    @objc private func deviceDidRotate(_ notification: Notification) {
        if !UIDevice.current.orientation.isLandscape {
            if #available(iOS 14.0, *) {
                hide(.primary)
            } else {
                
            }
        } else {
//            adjustLayoutForPortraitToLandscapeRotation()
        }
    }
}

extension iPadAlertSplitVC: UISplitViewControllerDelegate {
    
}
