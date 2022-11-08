//
//  MobileConfigurationResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-28.
//

import Foundation

// MARK: - MobileConfigurationResponseObject
struct MobileConfigurationResponseObject: Codable {
    let online: Bool
    let baseURL: String?
    let authentication: AuthenticationConfig?
    let version: Int?

    enum CodingKeys: String, CodingKey {
        case online
        case baseURL = "baseUrl"
        case authentication, version
    }
}

// MARK: - Authentication
struct AuthenticationConfig: Codable {
    let endpoint: String?
    let identityProviderID, clientID, redirectURI: String?

    enum CodingKeys: String, CodingKey {
        case endpoint
        case identityProviderID = "identityProviderId"
        case clientID = "clientId"
        case redirectURI = "redirectUri"
    }
}

