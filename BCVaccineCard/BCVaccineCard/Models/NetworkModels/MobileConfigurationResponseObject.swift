//
//  MobileConfigurationResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-28.
//

import Foundation

struct MobileConfigurationResponseObject: Codable {
    let online: Bool
    let baseURL, openIDURL: String?
    let openIDClientID: String?
    let version: Int?

    enum CodingKeys: String, CodingKey {
        case online
        case baseURL = "baseUrl"
        case openIDURL = "openIdUrl"
        case openIDClientID = "openIdClientId"
        case version
    }
}
