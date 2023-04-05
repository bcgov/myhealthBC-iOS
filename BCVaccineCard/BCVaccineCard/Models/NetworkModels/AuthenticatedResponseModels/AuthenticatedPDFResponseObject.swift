//
//  AuthenticatedPDFResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-08.
//

import Foundation

// MARK: - Welcome
struct AuthenticatedPDFResponseObject: BaseGatewayResponse, Codable {
    let resourcePayload: ResourcePayload?
    var totalResultCount, pageIndex, pageSize: Int?
    var resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let mediaType: String?
        let encoding: String?
        let data: String?
    }
}

struct AuthenticatedPDFRequestObject: Codable {
    let hdid: String
    let isCovid19: String
}
