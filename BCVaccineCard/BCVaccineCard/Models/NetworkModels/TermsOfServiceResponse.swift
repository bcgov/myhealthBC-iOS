//
//  TermsOfServiceResponse.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-24.
//

import Foundation

// MARK: - GatewayVaccineCardResponse
struct TermsOfServiceResponse: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let id: String?
        let content: String?
        let effectiveDate: String? // Format is: "2021-01-07T00:00:00"
    }
}
