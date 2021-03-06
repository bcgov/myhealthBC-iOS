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
    var title: String? = nil
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
    // TODO: We can use custom font here
    private func setupAppearance(navStyle: NavStyle, backButtonHintString: String?, largeTitleFontSize: CGFloat = 34) {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navStyle.navBarColor
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navStyle.textColor]
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navStyle.textColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: largeTitleFontSize, weight: .bold)]
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
            if let hint = backButtonHintString {
                // NOTE: This logic isn't working, but I'm leaving it in here for now, just in case QA pushes it back
                navigationBar.standardAppearance.backIndicatorImage.isAccessibilityElement = true
                navigationBar.standardAppearance.backIndicatorImage.accessibilityTraits = .button
                navigationBar.standardAppearance.backIndicatorImage.accessibilityLabel = AccessibilityLabels.Navigation.backButtonTitle
                navigationBar.standardAppearance.backIndicatorImage.accessibilityHint = AccessibilityLabels.Navigation.backButtonHint + "\(hint)"
            }
            
        } else {
            // FIXME: Find a safe way to change color of status bar background color (just stays white here)
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navStyle.textColor]
            navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navStyle.textColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: largeTitleFontSize, weight: .bold)]
            navigationBar.backgroundColor = navStyle.navBarColor
            if let image = UIImage(named: "app-back-arrow") {
                navigationBar.backIndicatorImage = image
                navigationBar.backIndicatorTransitionMaskImage = image
                if let hint = backButtonHintString {
                    navigationBar.backIndicatorImage?.isAccessibilityElement = true
                    navigationBar.backIndicatorImage?.accessibilityTraits = .button
                    navigationBar.backIndicatorImage?.accessibilityLabel = AccessibilityLabels.Navigation.backButtonTitle
                    navigationBar.backIndicatorImage?.accessibilityHint = AccessibilityLabels.Navigation.backButtonHint + "\(hint)"
                }
            }
//            navigationBar.shadowImage = UIImage()
        }
        
    }
    
    func setupNavigation(leftNavButton left: NavButton?, rightNavButtons right: [NavButton], navStyle: NavStyle, targetVC vc: UIViewController, backButtonHintString: String?, largeTitleFontSize: CGFloat = 34) {
        vc.navigationItem.largeTitleDisplayMode = navStyle.largeTitles ? .always : .never
        setupAppearance(navStyle: navStyle, backButtonHintString: backButtonHintString, largeTitleFontSize: largeTitleFontSize)
        navigationBar.tintColor = navStyle.itemTintColor
        
        var rightNavButtons: [UIBarButtonItem] = []
        for rightButton in right {
            var barButton: UIBarButtonItem? = nil
            if let btnTitle = rightButton.title {
               barButton = UIBarButtonItem(title: btnTitle, style: .plain, target: vc, action: rightButton.action)
            } else {
                barButton = UIBarButtonItem(image: rightButton.image, style: .plain, target: vc, action: rightButton.action)
            }
            
            if let trait = rightButton.accessibility.traits {
                barButton?.accessibilityTraits = trait
            }
            barButton?.accessibilityLabel = rightButton.accessibility.label
            barButton?.accessibilityHint = rightButton.accessibility.hint
            if let button = barButton {
                rightNavButtons.append(button)
            }
        }
        vc.navigationItem.rightBarButtonItems = rightNavButtons
        
        if let left = left {
            if let title = left.title {
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: vc, action: left.action)
            } else {
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: left.image, style: .plain, target: vc, action: left.action)
            }
            if let trait = left.accessibility.traits {
                vc.navigationItem.leftBarButtonItem?.accessibilityTraits = trait
            }
            vc.navigationItem.leftBarButtonItem?.accessibilityLabel = left.accessibility.label
            vc.navigationItem.leftBarButtonItem?.accessibilityHint = left.accessibility.hint
        }
        vc.navigationItem.setBackItemTitle(with: "")
    }
    
    func getRightBarButtonItem() -> UIBarButtonItem? {
        return self.navigationItem.rightBarButtonItem
    }
    
    func getLeftBarButtonItem() -> UIBarButtonItem? {
        return self.navigationItem.leftBarButtonItem
    }
    
    func adjustNavStyleForPDF(targetVC vc: UIViewController) {
        vc.navigationItem.largeTitleDisplayMode = .never
    }
    
}

extension CustomNavigationController {
   open override var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}

