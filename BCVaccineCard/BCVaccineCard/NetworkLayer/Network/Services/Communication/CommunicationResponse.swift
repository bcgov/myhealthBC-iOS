//
//  CommunicationResponse.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-09-14.
//

import Foundation


// MARK: -CommunicationResponse
struct CommunicationResponse: Codable {
    let resourcePayload: CommunicationResponseResourcePayload?
    let totalResultCount: Int
    let pageIndex, pageSize: JSONNull?
    let resultStatus: Int
    let resultError: JSONNull?
}

// MARK: - ResourcePayload
struct CommunicationResponseResourcePayload: Codable {
    let communicationID, text, subject, effectiveDateTime: String
    let expiryDateTime: String
    let scheduledDateTime: JSONNull?
    let communicationTypeCode: String
    let communicationStatusCode, priority: Int
    let createdBy, createdDateTime, updatedBy, updatedDateTime: String
    let version: Int

    enum CodingKeys: String, CodingKey {
        case communicationID = "CommunicationId"
        case text, subject, effectiveDateTime, expiryDateTime, scheduledDateTime, communicationTypeCode, communicationStatusCode, priority, createdBy, createdDateTime, updatedBy, updatedDateTime, version
    }
}

typealias CommunicationBanner = CommunicationResponseResourcePayload


