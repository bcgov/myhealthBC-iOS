//
//  AuthenticatedCommentResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-02.
//

import Foundation

// MARK: - AuthenticatedCommentResponseObject
struct AuthenticatedCommentResponseObject: BaseGatewayResponse, Codable {
    let resourcePayload: [String: [Comment]]
    var totalResultCount, pageIndex, pageSize, resultStatus: Int?
    var resultError: ResultError?
    
    // MARK: - ResourcePayload
    // TODO: Once we have comments available, check what the name of the keys will be, and what each one means
    struct Comment: Codable {
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
