//
//  Defaults.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//

import Foundation

struct Defaults {
    enum Key: String {
        case initialOnboardingScreensSeen
        case rememberGatewayDetails
        case enabledTypes
        case hasAppLaunchedBefore
        case loginProcessStatus
        case hasSeenFirstLogin
        case quickLinksPreferences
    }
    
    // Temporary measure until I can get keychain working properly
    static var rememberGatewayDetails: RememberedGatewayDetails? {
        get {
            guard let data = UserDefaults.standard.value(forKey: self.Key.rememberGatewayDetails.rawValue) as? Data else { return nil }
            let details = try? PropertyListDecoder().decode(RememberedGatewayDetails.self, from: data)
            return details
        }
        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.rememberGatewayDetails.rawValue) }
    }
    
    static var enabledTypes: EnabledTypes? {
        get {
            guard let data = UserDefaults.standard.value(forKey: self.Key.enabledTypes.rawValue) as? Data else { return nil }
            let types = try? PropertyListDecoder().decode(EnabledTypes.self, from: data)
            return types
        }
        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.enabledTypes.rawValue) }
    }
    
    static var hasAppLaunchedBefore: Bool {
        get { return UserDefaults.standard.bool(forKey: self.Key.hasAppLaunchedBefore.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: self.Key.hasAppLaunchedBefore.rawValue) }
    }
    
    static var hasSeenFirstLogin: Bool {
        get { return UserDefaults.standard.bool(forKey: self.Key.hasSeenFirstLogin.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: self.Key.hasSeenFirstLogin.rawValue) }
    }
    
    // Note: This is to handle edge cases where user kills the app during the login flow and we have to handle logging a user out when app is launched again, or fetching records when app is launched again
    static var loginProcessStatus: LoginProcessStatus? {
        get {
            guard let data = UserDefaults.standard.value(forKey: self.Key.loginProcessStatus.rawValue) as? Data else { return nil }
            let loginProcess = try? PropertyListDecoder().decode(LoginProcessStatus.self, from: data)
            return loginProcess
        }
        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.loginProcessStatus.rawValue) }
    }
    
    static func unseenOnBoardingScreens() -> [OnboardingScreenType] {
        let allSeen = getStoredOnBoardingScreensSeen()
        var unseen: [OnboardingScreenType] = []
        for each in OnboardingScreenType.allCases {
            if !allSeen.contains(where: ({$0.version == Constants.onBoardingScreenLatestVersion(for: each) && $0.geTypeEnum() == each})) {
                unseen.append(each)
            }
        }
        return unseen.sorted(by: {$0.rawValue < $1.rawValue})
    }
    
    static func getStoredOnBoardingScreensSeen() -> [VisitedOnboardingScreen] {
        guard let data = UserDefaults.standard.value(forKey: self.Key.initialOnboardingScreensSeen.rawValue) as? Data else {
            return []
        }
        do {
            let decoded = try PropertyListDecoder().decode([VisitedOnboardingScreen].self, from: data)
            return decoded
        } catch {
            Logger.log(string: error.localizedDescription, type: .general)
            return []
        }
        
    }
    
    static func storeInitialOnboardingScreensSeen(types: [OnboardingScreenType]) {
        let newVisits = types.map({VisitedOnboardingScreen(type: $0.toScreenTypeID().rawValue, version: Constants.onBoardingScreenLatestVersion(for: $0))})
        var allVisits = getStoredOnBoardingScreensSeen()
        allVisits.append(contentsOf: newVisits)
        do {
            let encoded = try PropertyListEncoder().encode(allVisits)
            UserDefaults.standard.set(encoded, forKey: self.Key.initialOnboardingScreensSeen.rawValue)
        } catch {
            Logger.log(string: error.localizedDescription, type: .general)
            return
        }
    }
    
    static func getStoresPreferencesFor(phn: String) -> [QuickLinksPreferences] {
        guard let data = UserDefaults.standard.value(forKey: self.Key.quickLinksPreferences.rawValue) as? Data else {
            return []
        }
        do {
            let decoded = try PropertyListDecoder().decode(LocalDictionaryQuickLinksPreferences.self, from: data)
            guard let preferences = decoded.storedPreferences[phn] else {
                return []
            }
            return preferences
        } catch {
            Logger.log(string: error.localizedDescription, type: .general)
            return []
        }
    }
    
    static func updateStoredPreferences(phn: String, newPreferences: [QuickLinksPreferences]) {
        guard let data = UserDefaults.standard.value(forKey: self.Key.quickLinksPreferences.rawValue) as? Data else {
            let localPreferences = LocalDictionaryQuickLinksPreferences(storedPreferences: [phn: newPreferences])
            UserDefaults.standard.set(try? PropertyListEncoder().encode(localPreferences), forKey: self.Key.quickLinksPreferences.rawValue)
            return
        }
        do {
            var decoded = try PropertyListDecoder().decode(LocalDictionaryQuickLinksPreferences.self, from: data)
            decoded.storedPreferences[phn] = newPreferences
            UserDefaults.standard.set(try? PropertyListEncoder().encode(decoded), forKey: self.Key.quickLinksPreferences.rawValue)
        } catch {
            Logger.log(string: error.localizedDescription, type: .general)
            return
        }
    }
}
