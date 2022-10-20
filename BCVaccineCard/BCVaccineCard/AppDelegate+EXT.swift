//
//  AppDelegate+ExT.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-05-18.
//

import Foundation
import UIKit

// MARK: Toast Messages
extension AppDelegate {
    
    enum ToastStyle {
        case Warn
        case Default
    }
    
    func showToast(message: String, style: ToastStyle? = .Default) {
        DispatchQueue.main.async {
            self.showToastFromBottom(message: message, style: style ?? .Default)
        }
    }
    
    fileprivate func showToastFromBottom(message: String, style: ToastStyle) {
        guard let window = window else {return}
        let container = UIView(frame: .zero)
        let label = UILabel(frame: .zero)
        
        label.isAccessibilityElement = true
        label.accessibilityTraits = .staticText
        label.accessibilityValue = "\(message)"
        
        // Remove existing Toast / Container
        if let existing = window.viewWithTag(Constants.UI.Toast.tag) {
            if let labelView = existing.subviews.first(where: {$0 is UILabel}), let label = labelView as? UILabel {
                // If the same message is already being shown, return
                if label.text == message {
                    return
                }
            }
            existing.removeFromSuperview()
        }
        
        // Add subviews
        container.tag = Constants.UI.Toast.tag
        let labelTAG = Int.random(in: 4000..<9000)
        label.tag = labelTAG
        window.addSubview(container)
        container.addSubview(label)
        label.text = message
        
        let textPadding: CGFloat = Constants.UI.Toast.labelPadding
        let containerPadding: CGFloat = Constants.UI.Toast.containerPadding
        let bottomPadding: CGFloat = Constants.UI.Toast.bottomPadding
        let containerWidth: CGFloat = container.bounds.width - (containerPadding * 2)
        let messageHeight = label.text?.heightForView(font: Constants.UI.Toast.labelFont, width: containerWidth) ?? Constants.UI.Toast.defaultHeight
        let minHeight = messageHeight + (textPadding * 2)
        let ToastHeight = Constants.UI.Toast.defaultHeight > minHeight ? Constants.UI.Toast.defaultHeight : minHeight
        let bottomConstraintClosed =  bottomPadding + ToastHeight
        let bottomConstraintOpen = 0 - bottomPadding
        // Position container
        container.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = container.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: bottomConstraintClosed)
        bottomConstraint.isActive = true
        container.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: containerPadding).isActive = true
        container.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: 0 - containerPadding).isActive = true
        container.heightAnchor.constraint(equalToConstant: ToastHeight).isActive = true
        
        // Position Label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: textPadding).isActive = true
        label.bottomAnchor.constraint(greaterThanOrEqualTo: container.bottomAnchor, constant: 0 - textPadding).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: textPadding).isActive = true
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0 - textPadding).isActive = true
        label.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        // Style
        label.textAlignment = .left
        label.font = Constants.UI.Toast.labelFont
        switch style {
        case .Warn:
            container.backgroundColor = Constants.UI.Toast.WarnColors.backgroundColor
            label.textColor = Constants.UI.Toast.WarnColors.labelColor
        case .Default:
            container.backgroundColor = Constants.UI.Toast.defaultColors.backgroundColor
            label.textColor = Constants.UI.Toast.defaultColors.labelColor
        }
        
        container.layer.cornerRadius = Constants.UI.Theme.cornerRadiusRegular
        container.layer.shadowColor = Constants.UI.Toast.shadowColor
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = CGSize(width: -1, height: 5)
        container.layer.shadowRadius = 15
        container.layer.shadowPath = UIBezierPath(rect: container.bounds).cgPath
        
        // Prepare for presentation
        container.alpha = 0
        window.layoutIfNeeded()
        
        // Present from bottom
        UIView.animate(withDuration: Constants.UI.Theme.animationDuration, animations: {
            bottomConstraint.constant = bottomConstraintOpen
            container.alpha = 1
            container.layoutIfNeeded()
            window.layoutIfNeeded()
        }) { done in
            UIAccessibility.setFocusTo(label)
            // begin dismiss timer
            self.dismissToast(in: Constants.UI.Toast.displayDuration, view: container, bottomConstraint: bottomConstraint, closedContraintConstant: bottomConstraintClosed, labelTag: labelTAG)
        }
    }
    
    fileprivate func dismissToast(in time: Double, view: UIView, bottomConstraint: NSLayoutConstraint, closedContraintConstant: CGFloat, labelTag: Int) {
        // Remove Toast after x seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            // Animdate going down
            UIView.animate(withDuration: Constants.UI.Theme.animationDuration, animations: {
                bottomConstraint.constant = closedContraintConstant
                view.layoutIfNeeded()
                self.window?.layoutIfNeeded()
            }) { done in
                // Remove view
                guard let container = self.window?.viewWithTag(Constants.UI.Toast.tag),
                      container.viewWithTag(labelTag) != nil
                else {return}
                container.removeFromSuperview()
            }
        }
    }
}
