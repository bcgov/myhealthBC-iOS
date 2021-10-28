//
//  Defaults.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//  

import Foundation

enum Defaults {
    enum Key: String {
        case hasSeenInitialOnboardingScreens
        case cachedQueueItObject
    }
    
    static var hasSeenInitialOnboardingScreens: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.Key.hasSeenInitialOnboardingScreens.rawValue)
        }
        set { UserDefaults.standard.set(newValue, forKey: self.Key.hasSeenInitialOnboardingScreens.rawValue) }
    }
    
    static var cachedQueueItObject: QueueItCachedObject? {
        get {
            guard let data = UserDefaults.standard.value(forKey: self.Key.cachedQueueItObject.rawValue) as? Data else { return nil }
            let cached = try? PropertyListDecoder().decode(QueueItCachedObject.self, from: data)
            return cached
        }
        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.cachedQueueItObject.rawValue) }
    }
}
