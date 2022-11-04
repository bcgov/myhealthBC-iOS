//
//  MobileConfigStorage.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-04.
//

import Foundation

import KeychainAccess

struct MobileConfigStorage {
    
    private enum Key: String {
        case baseURL
        case openIDURL
        case openIDClientID
        case configVersion
    }
    
    private static let keychain = Keychain(service: "ca.bc.gov.myhealth")
    
    public static var version: Int? {
        guard let versionString = keychain[Key.configVersion.rawValue],
              let versionInt = Int(versionString)
        else {
            return nil
        }
        return versionInt
    }
    
    public static var openIDURL: String? {
        guard let urlString = keychain[Key.openIDURL.rawValue] else {
            return nil
        }
        return urlString
    }
    
    public static var openIDClientID: String? {
        guard let idString = keychain[Key.openIDClientID.rawValue]
        else {
            return nil
        }
        return idString
    }
    
    public static var baseURL: String? {
        guard let urlString = keychain[Key.baseURL.rawValue]
        else {
            return nil
        }
        return urlString
    }
    
    public static var cachedConfig: MobileConfigurationResponseObject {
        return MobileConfigurationResponseObject(online: false,
                                                 baseURL: baseURL,
                                                 openIDURL: openIDURL,
                                                 openIDClientID: openIDClientID,
                                                 version: version)
    }
    
    public static func store(config: MobileConfigurationResponseObject) {
        if let baseUrl = config.baseURL {
            store(baseURL: baseUrl)
        }
        if let openIDURL = config.openIDURL {
            store(openIDURL: openIDURL)
        }
        if let openIDClientID = config.openIDClientID {
            store(openIDClientID: openIDClientID)
        }
        if let version = config.version {
            store(version: version)
        }
    }
    
    private static func store(version: Int) {
        do {
            try keychain.set("\(version)", key: Key.configVersion.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private static func store(openIDURL: String) {
        do {
            try keychain.set(openIDURL, key: Key.openIDURL.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private static func store(openIDClientID: String) {
        do {
            try keychain.set(openIDClientID, key: Key.openIDClientID.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private static func store(baseURL: String) {
        do {
            try keychain.set(baseURL, key: Key.baseURL.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
}
