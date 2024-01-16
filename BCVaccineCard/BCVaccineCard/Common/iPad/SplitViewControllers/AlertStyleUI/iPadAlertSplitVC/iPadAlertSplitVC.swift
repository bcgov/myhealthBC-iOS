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
    
    enum ViewControllerStackOptions: String {
        case ProfileAndSettingsViewControllerString
        case SecurityAndDataViewControllerString
        case ProfileDetailsViewControllerString
        case FeedbackViewControllerString
        case PrivacyPolicyViewControllerString
        
        func instantiateViewController() -> UIViewController? {
            var vc: UIViewController?
            switch self {
            case .ProfileAndSettingsViewControllerString:
                vc = ProfileAndSettingsViewController.construct()
            case .SecurityAndDataViewControllerString:
                vc = SecurityAndDataViewController.construct()
            case .ProfileDetailsViewControllerString:
                guard let patient = StorageService.shared.fetchAuthenticatedPatient() else { return nil }
                let vm = ProfileDetailsViewController.ViewModel(type: .PatientProfile(patient: patient))
                vc = ProfileDetailsViewController.construct(viewModel: vm)
            case .FeedbackViewControllerString:
                vc = FeedbackViewController.construct()
            case .PrivacyPolicyViewControllerString:
                vc = PrivacyPolicyViewController.construct(with: Constants.PrivacyPolicy.urlString)
            }
            return vc
        }
    }
    
    private var baseVC: UIViewController?
    private var secondVC: UIViewController?
    
    private var vcStack: [ViewControllerStackOptions] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configuration()
//        baseVC?.navigationController?.setNavigationBarHidden(true, animated: false)
//        secondVC?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: .deviceDidRotate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(iPadSettingsSelection), name: .iPadSettingsSelection, object: nil)
        delegate = self
        presentsWithGesture = false
    }
    
    private func newConfiguration() {
        // Configuration rules:
        
        // 1 - In Landscape view, have settings on left, and whatever was on the top of the stack on the right. Default is profile details
        // 2 - When rotating - show whatever was last shown in portrait mode, if just one shown, then it's base settings screen - track nav stack with enum
        // 3 - When unauthenticated, only show base screen, and navigation will work normally
        
        
    }
    
    private func updateVCStack() {
        // Here we want to see if there is another VC ontop of baseVC stack, and if so, set it to the top-most VC of secondVCStack
        guard let topMostVC = (baseVC as? CustomNavigationController)?.topViewController, !(topMostVC is ProfileAndSettingsViewController) else { return }
        if let newVC = (baseVC as? CustomNavigationController)?.popViewController(animated: false) {
            (secondVC as? CustomNavigationController)?.popToRootViewController(animated: false)
            (secondVC as? CustomNavigationController)?.pushViewController(newVC, animated: false)
        }
        
        
    }
    
    private func configuration() {
        var leftVC: UIViewController
        if let baseVC = baseVC {
            leftVC = baseVC
            preferredPrimaryColumnWidthFraction = 1.0
            if #available(iOS 14.0, *) {
                if UIDevice.current.orientation.isLandscape {
                    preferredDisplayMode = secondVC != nil ? .oneBesideSecondary : .secondaryOnly
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
            let splitViewColumn: UISplitViewController.Column = secondVC == nil || !UIDevice.current.orientation.isLandscape ? .secondary : .primary
            setViewController(leftVC, for: splitViewColumn)
        } else {
            self.viewControllers = [leftVC]
        }
        
        // Setup Base VC
        if let secondVC = secondVC, UIDevice.current.orientation.isLandscape {
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
            updateVCStack()
        }
        
        configuration()
//        if #available(iOS 14.0, *) {
//            if UIDevice.current.orientation.isLandscape {
//                if let _ = secondVC {
//                    preferredDisplayMode = .oneBesideSecondary
//                } else {
//                    preferredDisplayMode = .secondaryOnly
//                }
//            } else {
//                preferredDisplayMode = .secondaryOnly
//            }
//            
//        } else {
//            preferredDisplayMode = .allVisible
//        }
        
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

// MARK: Reconfigure nav stack
extension iPadAlertSplitVC {
    
    @objc private func iPadSettingsSelection(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String],
              let screen = userInfo["screen"],
              let type = ViewControllerStackOptions(rawValue: screen),
              let vc = type.instantiateViewController() else { return }
        let baseVC = ProfileAndSettingsViewController.construct()
        var nav: CustomNavigationController
        if vc is ProfileAndSettingsViewController {
            nav = CustomNavigationController(rootViewController: vc)
        } else {
            nav = CustomNavigationController(rootViewController: baseVC)
            nav.pushViewController(vc, animated: false)
        }
//        nav = CustomNavigationController(rootViewController: vc)
        secondVC = nav
        configuration()
        
    }
}

extension iPadAlertSplitVC: UISplitViewControllerDelegate {
    
}
