//
//  NotificationManager.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-17.
//
//TODO: Refactor by adding other notifications throughout the app to this file, so that we can have them all in one place

import Foundation
import UIKit

class NotificationManager {}

// MARK: For clearing data due to unauth user for various reasons (under 12)
extension NotificationManager {
    static func postLoginDataClearedOnLoginRejection(sourceVC: LoginVCSource) {
        let name = Notification.Name.reloadVCDueToUnderage
        let key = Constants.SourceVCReloadKey.key
        let info: [String: String] = [key: sourceVC.rawValue]
        NotificationCenter.default.post(name: name, object: nil, userInfo: info)
    }
    
    static func listenToLoginDataClearedOnLoginRejection(observer: UIViewController, selector: Selector) {
        let name = Notification.Name.reloadVCDueToUnderage
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
}

//MARK: For terms of service
extension NotificationManager {
    static func showTermsOfService() {
        let name = Notification.Name.showTermsOfService
        NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
    }
    
    static func listenToShowTermsOfService(observer: UIViewController, selector: Selector) {
        let name = Notification.Name.showTermsOfService
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    static func respondToTermsOfService(accepted: Bool?, error: String?) {
        let name = Notification.Name.respondToTermsOfService
        let key = Constants.TermsOfServiceResponseKey.key
        let errorKey = Constants.GenericErrorKey.key
        let info: [String: Any?] = [
            key: accepted,
            errorKey: error
        ]
        NotificationCenter.default.post(name: name, object: nil, userInfo: info as [AnyHashable : Any])
    }
    
    static func listenToTermsOfServiceResponse(observer: UIViewController, selector: Selector) {
        let name = Notification.Name.respondToTermsOfService
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
}
