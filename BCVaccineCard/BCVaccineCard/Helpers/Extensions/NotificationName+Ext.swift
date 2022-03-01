//
//  NotificationName+Ext.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-12.
//

import Foundation

extension Notification.Name {
    static let tabChanged = Notification.Name("TabChanged")
    static let reloadNewsFeed = Notification.Name("ReloadNewsFeed")
    static let cardAddedNotification = Notification.Name("cardAddedNotification")
    static let storageChangeEvent = Notification.Name("StorageChangeEvent")
    static let doubleTappedTab = Notification.Name("DoubleTappedTab")
    
    static let refreshTokenExpired = Notification.Name("refreshTokenExpired")
    static let authTokenExpired = Notification.Name("authTokenExpired")
    
    static let launchedFromBackground = Notification.Name("launchedFromBackground")
    static let shouldPerformLocalAuth = Notification.Name("shouldPerformLocalAuth")
    
    static let backgroundAuthFetch = Notification.Name("backgroundAuthFetch")
    
    static let settingsTableViewReload = Notification.Name("settingsTableViewReload")
}
