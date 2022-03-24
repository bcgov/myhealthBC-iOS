//
//  AuthenticatedUserProfileResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-24.
//

import Foundation

// NOTE: For now, we really only need the hdId and acceptedTermsOfService fields - so that's all we're going to decode
struct AuthenticatedUserProfileResponseObject: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: ResourcePayload
    struct ResourcePayload: Codable {
        let hdid: String?
        let acceptedTermsOfService: Bool
        
        enum CodingKeys: String, CodingKey {
            case hdid = "hdId"
            case acceptedTermsOfService
        }
    }
}

struct AuthenticatedUserProfileRequestObject: Codable {
    let profile: ResourcePayload
    
    // MARK: ResourcePayload
    struct ResourcePayload: Codable {
        let hdid: String
        let acceptedTermsOfService: Bool
        
        enum CodingKeys: String, CodingKey {
            case hdid = "hdId"
            case acceptedTermsOfService
        }
    }
}
