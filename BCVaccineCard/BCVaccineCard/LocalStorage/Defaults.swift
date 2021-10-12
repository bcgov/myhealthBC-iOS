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
        case hasSeenInitialOnboardingScreens
    }
    
    static var vaccinePassports: [LocallyStoredVaccinePassportModel]? {
        get {
            guard let data = UserDefaults.standard.value(forKey: self.Key.vaccinePassports.rawValue) as? Data else { return nil }
            let order = try? PropertyListDecoder().decode([LocallyStoredVaccinePassportModel].self, from: data)
            return order
        }
        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.vaccinePassports.rawValue) }
    }
    
    static var hasSeenInitialOnboardingScreens: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.Key.hasSeenInitialOnboardingScreens.rawValue)
        }
        set { UserDefaults.standard.set(newValue, forKey: self.Key.hasSeenInitialOnboardingScreens.rawValue) }
    }
}
