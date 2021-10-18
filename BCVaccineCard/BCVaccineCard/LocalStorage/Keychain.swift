//
//  Keychain.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-18.
//
// TODO: Adjust User Default logic below for Keychain Access - will need to be a little more in-depth than this:
//https://stackoverflow.com/questions/37539997/save-and-load-from-keychain-swift
// This one is likely better: https://www.advancedswift.com/secure-private-data-keychain-swift/


//import Foundation
//
//enum Keychain {
//    enum Key: String {
//        case vaccinePassports
//        case hasSeenInitialOnboardingScreens
//        case cachedQueueItObject
//    }
//
//    static var vaccinePassports: [LocallyStoredVaccinePassportModel]? {
//        get {
//            guard let data = UserDefaults.standard.value(forKey: self.Key.vaccinePassports.rawValue) as? Data else { return nil }
//            let order = try? PropertyListDecoder().decode([LocallyStoredVaccinePassportModel].self, from: data)
//            return order
//        }
//        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.vaccinePassports.rawValue) }
//    }
//
//    static var hasSeenInitialOnboardingScreens: Bool {
//        get {
//            return UserDefaults.standard.bool(forKey: self.Key.hasSeenInitialOnboardingScreens.rawValue)
//        }
//        set { UserDefaults.standard.set(newValue, forKey: self.Key.hasSeenInitialOnboardingScreens.rawValue) }
//    }
//
//    static var cachedQueueItObject: QueueItCachedObject? {
//        get {
//            guard let data = UserDefaults.standard.value(forKey: self.Key.cachedQueueItObject.rawValue) as? Data else { return nil }
//            let cached = try? PropertyListDecoder().decode(QueueItCachedObject.self, from: data)
//            return cached
//        }
//        set { UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: self.Key.cachedQueueItObject.rawValue) }
//    }
//}
