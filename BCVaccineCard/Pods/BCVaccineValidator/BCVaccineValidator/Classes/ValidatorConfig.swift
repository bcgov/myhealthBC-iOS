//
//  ValidatorConfig.swift
//  BCVaccineValidator
//
//  Created by Mohamed Afsar on 17/01/22.
//

import Foundation

/// The type which holds the configs of BCVaccineValidator SDK.
public struct ValidatorConfig {
    static var `default`: ValidatorConfig {
        ValidatorConfig(issuersUrl: "https://smarthealthcard.phsa.ca/v1/trusted/.well-known/issuers.json",
               rulesUrl: "https://smarthealthcard.phsa.ca/v1/covid19proof/.well-known/rules.json")
    }
    
    /// The time interval to rely on the cached issuers.
    public var issuersCacheExpiryInMinutes: Double = 6 * 60 // 6 Hours
    /// The time interval to rely on the cached rules.
    public var rulesCacheExpiryInMinutes: Double = 6 * 60 // 6 Hours
    /// The bundle in which the bundled issuers, rules, keys, etc., files reside.
    public var resourceBundle: Bundle = .main
    /// The boolean that enables the remote fetch of issuers, rules, etc.
    public var enableRemoteFetch = true
    /// The boolean that enables the updation of rules and issuers when the internet connection fluctuates.
    public var shouldUpdateWhenOnline = false
    /// The issuers endpoint.
    public let issuersUrl: String
    /// The rules endpoint.
    public let rulesUrl: String
    /// Bundled issuers file name with extension.
    public var issuersFileNameWithExtension = "issuers.json"
    /// Bundled rules file name with extension.
    public var rulesFileNameWithExtension = "rules.json"
    /// The coding systems from which the exemptions are considered. For example, 'pvc.service.yukon.ca'.
    public var exemptionCodingSystems = [String]()
    
    public init(issuersUrl: String, rulesUrl: String) {
        self.issuersUrl = issuersUrl
        self.rulesUrl = rulesUrl
    }
}

extension ValidatorConfig: CustomStringConvertible {
    public var description: String {
        """
            issuersCacheExpiryInMinutes: \(issuersCacheExpiryInMinutes)
            rulesCacheExpiryInMinutes: \(rulesCacheExpiryInMinutes)
            resourceBundle: \(resourceBundle)
            enableRemoteFetch: \(enableRemoteFetch)
            shouldUpdateWhenOnline: \(shouldUpdateWhenOnline)
            issuersUrl: \(issuersUrl)
            rulesUrl: \(rulesUrl)
            issuersFileNameWithExtension: \(issuersFileNameWithExtension)
            rulesFileNameWithExtension: \(issuersCacheExpiryInMinutes)
            exemptionCodingSystems: \(exemptionCodingSystems)
        """
    }
}
