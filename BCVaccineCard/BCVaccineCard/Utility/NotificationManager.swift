//
//  NotificationManager.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-17.
//
//TODO: Refactor by adding other notifications throughout the app to this file, so that we can have them all in one place

import Foundation
import UIKit

class NotificationManager {
    
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
