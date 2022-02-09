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
        case cachedQueueItObject
        case rememberGatewayDetails
        case isBiometricSetup
    }
    
    static var cachedQueueItObject: QueueItCachedObject? {
        get {
            guard let data = UserDefaults.standard.value(forKey: self.Key.cachedQueueItObject.rawValue) as? Data else { return nil }
            let cached = try? PropertyListDecoder().decode(QueueItCachedObject.self, from: data)
            return cached
        }
        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.cachedQueueItObject.rawValue) }
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
            print(error)
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
            print(error)
            return
        }
    }
    
    static func setBiometricSetupDone() {
        UserDefaults.standard.set(true, forKey: self.Key.isBiometricSetup.rawValue)
    }

    static var isBiometricSetupDone: Bool {
        return UserDefaults.standard.bool(forKey: self.Key.isBiometricSetup.rawValue)
    }
}
