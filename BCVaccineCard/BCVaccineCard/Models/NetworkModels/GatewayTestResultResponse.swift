//
//  GatewayTestResultResponse.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-26.
//

import Foundation

struct GatewayTestResultResponse: Codable, Equatable {
    static func == (lhs: GatewayTestResultResponse, rhs: GatewayTestResultResponse) -> Bool {
        if let rhsResponse = rhs.resourcePayload, let lshResponse = lhs.resourcePayload {
            return lshResponse.records.equals(other: rhsResponse.records)
        }
        return (rhs.resourcePayload == nil && lhs.resourcePayload == nil)
    }
    
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let loaded: Bool
        let retryin: Int
        let records: [GatewayTestResultResponseRecord]
    }
    
//    let records: [GatewayTestResultResponseRecord]
}

struct GatewayTestResultResponseRecord: Codable, Equatable {
    let patientDisplayName: String?
    let lab: String?
    let reportId: String?
    let collectionDateTime: Date?
    let resultDateTime: Date?
    let testName: String?
    let testType: String?
    let testStatus: String? // I'm assuming this will be equal to the enum that I created in the CovidTestResultModel
    let testOutcome: String? // Could also be here too??
    let resultTitle: String?
    let resultDescription: String?
    let resultLink: String?
}

extension Array where Element == GatewayTestResultResponseRecord {
    func equals(other: [GatewayTestResultResponseRecord]) -> Bool {
        for el in self {
            if !other.contains(where: { element in
                return element == el
            }) {
                return false
            }
        }
        return self.count == other.count
    }
}

