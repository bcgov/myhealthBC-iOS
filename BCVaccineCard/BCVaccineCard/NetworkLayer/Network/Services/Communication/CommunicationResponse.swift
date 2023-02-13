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
    let pageIndex, pageSize: Int?
    let resultStatus: Int
    let resultError: ResultError?
}

// MARK: - ResourcePayload
struct CommunicationResponseResourcePayload: Codable {
    let communicationID, text, subject, effectiveDateTime: String
    let expiryDateTime: String
    let scheduledDateTime: String?
    let communicationTypeCode, communicationStatusCode: String
    let priority: Int
    let createdBy, createdDateTime, updatedBy, updatedDateTime: String
    let version: Int

    enum CodingKeys: String, CodingKey {
        case communicationID = "CommunicationId"
        case text, subject, effectiveDateTime, expiryDateTime, scheduledDateTime, communicationTypeCode, communicationStatusCode, priority, createdBy, createdDateTime, updatedBy, updatedDateTime, version
    }
}

typealias CommunicationBanner = CommunicationResponseResourcePayload


//extension CommunicationBanner {
//    var testText: String {
//        return "<p><strong>Send</strong> <em>email to</em> <del>this</del> <u>email to weee</u>A Blue Heading Health Gateway provides secure and convenient access to your health records in <a href=\"https://dev.healthgateway.gov.bc.ca/\">British Columbia</a>. <strong>Send</strong> <em>email to</em> <a href=\"mailto:aravind@freshworks.io\">aravind@freshworks.io</a>&nbsp; <h1 style=\"color:blue;\">A Blue Heading</h1></p>"
//    }
//}

