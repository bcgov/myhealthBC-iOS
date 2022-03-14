//
//  AuthenticatedPDFResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-08.
//

import Foundation

// MARK: - Welcome
struct AuthenticatedPDFResponseObject: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let mediaType: String?
        let encoding: String?
        let data: String?
    }
}
