//
//  UpdateManagerStorage.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-03.
//

import Foundation
import KeychainAccess

struct UpdateServiceStorage {
    
    private enum Key: String {
        case appCofigVersion
        case storedAppVersion
    }
    
    private static let keychain = Keychain(service: "ca.bc.gov.myhealth")
    public static var updateDilogShownThisSession = false
    
    public static var appCofigVersion: Int? {
        guard let versionString = keychain[Key.appCofigVersion.rawValue],
              let versionInt = Int(versionString)
        else {
            return nil
        }
        return versionInt
    }
    
    public static var storedAppVersion: String? {
        guard let versionString = keychain[Key.storedAppVersion.rawValue] else {
            return nil
        }
        return versionString
    }
    
    public static var currentAppVersion: String? {
        guard let bundleInfo = Bundle.main.infoDictionary else {
            return nil
        }
        return  bundleInfo["CFBundleShortVersionString"] as? String
    }
    
    public static var bundleId: String? {
        guard let bundleInfo = Bundle.main.infoDictionary else {
            return nil
        }
        return bundleInfo["CFBundleIdentifier"] as? String
    }
    
    // check if app has been updated since last launch
    public static var appWasUpdated: Bool {
        guard let stored = storedAppVersion else {
            return true
        }
        return stored != currentAppVersion
    }
    
    public static func setOrResetstoredAppVersion() {
        guard let stored = storedAppVersion else {
            storeCurrentAppVersion()
            return
        }
        if stored != currentAppVersion {
            do {
                try keychain.remove(Key.storedAppVersion.rawValue)
                try keychain.remove(Key.appCofigVersion.rawValue)
            }
            catch let error {
                Logger.log(string: error.localizedDescription, type: .Auth)
            }
        }
    }
    
    public static func storeConfig(version: Int) {
        do {
            try keychain.set("\(version)", key: Key.appCofigVersion.rawValue)
            storeCurrentAppVersion()
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }

    public static func storeCurrentAppVersion() {
        guard let version = currentAppVersion else {return}
        do {
            try keychain.set(version, key: Key.storedAppVersion.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
}
