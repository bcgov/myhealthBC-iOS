//
//  AppDelegate+ExT.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-05-18.
//

import Foundation
import UIKit


// MARK: Loading UI
extension AppDelegate {
    // Triggered by dataLoadCount
    internal func showLoader() {
        // If already shown, dont do anything
        if (self.window?.viewWithTag(dataLoadTag)) != nil {
            return
        }
        
        if window?.rootViewController?.presentedViewController is UIAlertController {
            print("An alert is being hidden")
            // Should handle this OR remove the alert saying data is being fetched afrer login
        }
        
        // if somehow you're here and its already shown... remove it
        self.window?.viewWithTag(dataLoadTag)?.removeFromSuperview()
        print("showing loader")
        // create container and add it to the window
        let loaderView: UIView = UIView(frame: self.window?.bounds ?? .zero)
        self.window?.addSubview(loaderView)
        loaderView.tag = dataLoadTag
        
        // Create subviews for indicator and label
        let indicator = UIActivityIndicatorView(frame: .zero)
        let label = UILabel(frame: .zero)
        
        loaderView.addSubview(indicator)
        loaderView.addSubview(label)
        indicator.center(in: loaderView, width: 30, height: 30)
        label.center(in: loaderView, width: loaderView.bounds.width, height: 32, verticalOffset: 32, horizontalOffset: 0)
        
        // Style
        loaderView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        label.textColor = AppColours.appBlue
        label.text = "Syncing Recods"
        label.font = UIFont.bcSansBoldWithSize(size: 17)
        label.textAlignment = .center
        
        indicator.tintColor = AppColours.appBlue
        indicator.color = AppColours.appBlue
        indicator.startAnimating()
    }
    
    // Triggered by dataLoadCount
    @objc internal func hideLoaded() {
        self.window?.viewWithTag(self.dataLoadTag)?.removeFromSuperview()
    }
}

// MARK: Toast Messages
extension AppDelegate {
    enum ToastStyle {
        case Top, Bottom
    }
    
    func showToast(message: String, style: ToastStyle) {
        
    }
    
    func hideToast() {
        
    }
}
