//
//  MobileConfigStorage.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-04.
//

import Foundation
import KeychainAccess

struct MobileConfigStorage {
    
    struct CachedConfig {
        let datetime: Date
        let config: MobileConfigurationResponseObject
    }
    
    private enum Key: String {
        case baseURL
        case configVersion
        case authEndpoint
        case authClientID
        case authRedirectURI
        case authIdentityProviderID
    }
    
    public static var cachedConfig: CachedConfig? = nil
    
    private static let keychain = Keychain(service: "ca.bc.gov.myhealth")
    
    public static var version: Int? {
        guard let versionString = keychain[Key.configVersion.rawValue],
              let versionInt = Int(versionString)
        else {
            return nil
        }
        return versionInt
    }
    
    
    public static var baseURL: String? {
        guard let urlString = keychain[Key.baseURL.rawValue]
        else {
            return nil
        }
        return urlString
    }
    
    public static var authEndpoint: String? {
        guard let urlString = keychain[Key.authEndpoint.rawValue] else {
            return nil
        }
        return urlString
    }
    
    public static var authClientID: String? {
        guard let idString = keychain[Key.authClientID.rawValue]
        else {
            return nil
        }
        return idString
    }
    
    public static var authRedirectURI: String? {
        guard let idString = keychain[Key.authClientID.rawValue]
        else {
            return nil
        }
        return idString
    }
    
    public static var authIdentityProviderID: String? {
        guard let idString = keychain[Key.authIdentityProviderID.rawValue]
        else {
            return nil
        }
        return idString
    }
    
    public static var offlineConfig: MobileConfigurationResponseObject {
        let authConfig = AuthenticationConfig(endpoint: authEndpoint,
                                              identityProviderID: authIdentityProviderID,
                                              clientID: authClientID,
                                              redirectURI: authRedirectURI)
        return MobileConfigurationResponseObject(online: false,
                                                 baseURL: baseURL,
                                                 authentication: authConfig,
                                                 version: version)
    }
    
    public static func store(config: MobileConfigurationResponseObject) {
        cachedConfig = CachedConfig(datetime: Date(), config: config)
        if let baseUrl = config.baseURL {
            store(baseURL: baseUrl)
        }
        
        if let version = config.version {
            store(version: version)
        }
        
        if let endpoint = config.authentication?.endpoint {
            store(authEndpoint: endpoint)
        }
        
        if let clientID = config.authentication?.clientID {
            store(authClientID: clientID)
        }
        
        if let redirectURI = config.authentication?.redirectURI {
            store(authRedirectURI: redirectURI)
        }
        
        if let identityProviderID = config.authentication?.identityProviderID {
            store(authIdentityProviderID: identityProviderID)
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
    
    private static func store(baseURL: String) {
        do {
            try keychain.set(baseURL, key: Key.baseURL.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private static func store(authEndpoint: String) {
        do {
            try keychain.set(authEndpoint, key: Key.authEndpoint.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private static func store(authClientID: String) {
        do {
            try keychain.set(authClientID, key: Key.authClientID.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private static func store(authRedirectURI: String) {
        do {
            try keychain.set(authRedirectURI, key: Key.authRedirectURI.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private static func store(authIdentityProviderID: String) {
        do {
            try keychain.set(authIdentityProviderID, key: Key.authIdentityProviderID.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    
}
