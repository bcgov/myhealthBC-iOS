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
    static let fedPassOnlyAdded = Notification.Name("FedPassOnlyAdded")
    
    static let refreshTokenExpired = Notification.Name("refreshTokenExpired")
    static let authTokenExpired = Notification.Name("authTokenExpired")
    
    static let launchedFromBackground = Notification.Name("launchedFromBackground")
    static let didEnterBackground = Notification.Name("didEnterBackground")
    static let shouldPerformLocalAuth = Notification.Name("shouldPerformLocalAuth")
    static let performedAuth = Notification.Name("performedAuth")
    
    static let authFetchComplete = Notification.Name("AuthFetchComplete") // <-
    
    static let settingsTableViewReload = Notification.Name("settingsTableViewReload")
    
    static let protectedWordRequired = Notification.Name("protectedWordRequired")
    static let protectedWordProvided = Notification.Name("protectedWordProvided")
    static let protectedWordFailedPromptAgain = Notification.Name("protectedWordFailedPromptAgain")
    static let authStatusChanged = Notification.Name("authStatusChanged")
    static let shouldSync = Notification.Name("shouldSync")
    static let syncPerformed = Notification.Name("syncPerformed")
    static let patientAPIFetched = Notification.Name("patientAPIFetched")
    static let reloadVCDueToUnderage = Notification.Name("reloadVCDueToUnderage")
    static let resetHealthRecordsScreenOnLogout = Notification.Name("resetHealthRecordsScreenOnLogout")
    
    static let showTermsOfService = Notification.Name("showTermsOfService")
    static let respondToTermsOfService = Notification.Name("respondToTermsOfService")
    
    static let queueItUIManuallyClosed = Notification.Name("queueItUIManuallyClosed")
    static let patientStored = Notification.Name("patientStored")
    static let applyQuickLinkFilter = Notification.Name("applyQuickLinkFilter")
}
