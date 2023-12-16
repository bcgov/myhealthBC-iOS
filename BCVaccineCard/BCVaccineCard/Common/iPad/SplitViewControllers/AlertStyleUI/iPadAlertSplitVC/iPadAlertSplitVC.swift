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
