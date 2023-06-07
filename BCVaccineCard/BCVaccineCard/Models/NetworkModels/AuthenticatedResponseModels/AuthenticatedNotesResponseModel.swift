//
//  AuthenticatedNotesResponseModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-06.
//

import Foundation

// MARK: - AuthenticatedNotesResponseModel
struct AuthenticatedNotesResponseModel: BaseGatewayResponse, Codable {
    var resourcePayload: [Note]
    var totalResultCount, pageIndex, pageSize: Int?
    var resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct Note: Codable {
        let id, userProfileID, text, entryTypeCode: String?
        let parentEntryID: String?
        let version: Int?
        let createdDateTime, createdBy, updatedDateTime, updatedBy: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userProfileID = "userProfileId"
            case text, entryTypeCode
            case parentEntryID = "parentEntryId"
            case version, createdDateTime, createdBy, updatedDateTime, updatedBy
        }
    }
}
