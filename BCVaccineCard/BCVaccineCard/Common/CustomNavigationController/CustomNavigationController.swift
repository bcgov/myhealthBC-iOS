//
//  CustomNavigationController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-27.
// TODO: remove non-native buttons being added and scaled and create a more reusable nav controller for the whole app. Use this as base branch

import UIKit

struct Accessibility {
    let traits: UIAccessibilityTraits?
    let label: String?
    let hint: String?
}

struct NavButton {
    let image: UIImage?
    let action: Selector
    let accessibility: Accessibility
}
// Note: Using switch statements here instead of a ternary operation in the event designs change and we have more than two styles - easier to adjust logic with a switch statment
enum NavStyle {
    case large, small
    
    var largeTitles: Bool {
        switch self {
        case .large: return true
        case .small: return false
        }
    }
    
    var itemTintColor: UIColor {
        switch self {
        case .large: return AppColours.appBlue
        case .small: return AppColours.appBlue
        }
    }
    
    var navBarColor: UIColor {
        switch self {
        case .large: return .white
        case .small: return .white
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .large: return AppColours.appBlue
        case .small: return AppColours.appBlue
        }
    }
    
}

class CustomNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    private func setup() {
        navigationBar.prefersLargeTitles = true
        navigationBar.sizeToFit()
    }
    
    private func setupAppearance(navStyle: NavStyle) {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navStyle.navBarColor
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navStyle.textColor]
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navStyle.textColor]
            if let image = UIImage(named: "app-back-arrow") {
                appearance.setBackIndicatorImage(image, transitionMaskImage: image)
            }
//            appearance.shadowImage = nil
            navigationBar.standardAppearance = appearance
//            if navStyle == .small {
//                navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
//            } else {
//                navigationBar.scrollEdgeAppearance = navigationBar.scrollEdgeAppearance
//            }
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            // FIXME: Find a safe way to change color of status bar background color (just stays white here)
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navStyle.textColor]
            navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navStyle.textColor]
            navigationBar.backgroundColor = navStyle.navBarColor
            if let image = UIImage(named: "app-back-arrow") {
                navigationBar.backIndicatorImage = image
                navigationBar.backIndicatorTransitionMaskImage = image
            }
//            navigationBar.shadowImage = UIImage()
        }
        
    }
    
    func setupNavigation(leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, targetVC vc: UIViewController) {
        vc.navigationItem.largeTitleDisplayMode = navStyle.largeTitles ? .always : .never
        setupAppearance(navStyle: navStyle)
        navigationBar.tintColor = navStyle.itemTintColor
        if let right = right {
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(image: right.image, style: .plain, target: vc, action: right.action)
            if let trait = right.accessibility.traits {
                vc.navigationItem.rightBarButtonItem?.accessibilityTraits = trait
            }
            vc.navigationItem.rightBarButtonItem?.accessibilityLabel = right.accessibility.label
            vc.navigationItem.rightBarButtonItem?.accessibilityHint = right.accessibility.hint
        }
        if let left = left {
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: left.image, style: .plain, target: vc, action: left.action)
            if let trait = left.accessibility.traits {
                vc.navigationItem.rightBarButtonItem?.accessibilityTraits = trait
            }
            vc.navigationItem.rightBarButtonItem?.accessibilityLabel = left.accessibility.label
            vc.navigationItem.rightBarButtonItem?.accessibilityHint = left.accessibility.hint
        }
        vc.navigationItem.backButtonTitle = ""
    }
    
    func getRightBarButtonItem() -> UIBarButtonItem? {
        return self.navigationItem.rightBarButtonItem
    }
    
    func getLeftBarButtonItem() -> UIBarButtonItem? {
        return self.navigationItem.leftBarButtonItem
    }
    
}

extension CustomNavigationController {
   open override var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}

