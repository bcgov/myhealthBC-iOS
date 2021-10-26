//
//  Defaults.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-10.
//  

import Foundation

enum Defaults {
    enum Key: String {
        case vaccinePassports
        case initialOnboardingScreensSeen
        case cachedQueueItObject
    }
    
    static var vaccinePassports: [LocallyStoredVaccinePassportModel]? {
        get {
            guard let data = UserDefaults.standard.value(forKey: self.Key.vaccinePassports.rawValue) as? Data else { return nil }
            let order = try? PropertyListDecoder().decode([LocallyStoredVaccinePassportModel].self, from: data)
            return order
        }
        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.vaccinePassports.rawValue) }
    }
    
    static var initialOnboardingScreensSeen: [OnboardingScreenType]? {
        get {
            guard let data = UserDefaults.standard.value(forKey: self.Key.initialOnboardingScreensSeen.rawValue) as? Data else { return nil }
            let order = try? PropertyListDecoder().decode([OnboardingScreenType].self, from: data)
            return order
        }
        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.initialOnboardingScreensSeen.rawValue) }
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
