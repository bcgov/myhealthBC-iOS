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
    let totalResultCount, pageIndex, pageSize: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: BaseRetryableGatewayResponse, Codable {
        var loaded: Bool?
        var retryin: Int?
        let records: [GatewayTestResultResponseRecord]
        let reportAvailable: Bool?
        let id: String?
    }
}

struct GatewayTestResultResponseRecord: Codable, Equatable {
    let patientDisplayName: String?
    let lab: String?
    let reportId: String?
    let collectionDateTime: String?
    let resultDateTime: String?
    let testName: String?
    let testType: String?
    let testStatus: String?
    let testOutcome: String?
    let resultTitle: String?
    let resultDescription: [String]?
    let resultLink: String?
    
    var collectionDateTimeDate: Date? {
        guard let dateString = self.collectionDateTime else { return nil }
        if let date = Date.Formatter.yearMonthDay.date(from: dateString) {
            return date
        } else {
            return Date.Formatter.gatewayDateAndTime.date(from: dateString)
        }
    }
    
    var resultDateTimeDate: Date? {
        guard let dateString = self.resultDateTime else { return nil }
        if let date = Date.Formatter.yearMonthDay.date(from: dateString) {
            return date
        } else {
            return Date.Formatter.gatewayDateAndTime.date(from: dateString)
        }
    }
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

extension GatewayTestResultResponseRecord {
    enum ResponseStatusTypes: String, Codable {
        case pending = "Pending"
        case final = "Final"
        case statusChange = "StatusChange"
        case amended = "Amended"
        case corrected = "Corrected"
    }
    
    enum ResponseOutcomeTypes: String, Codable {
        case notSet = "NotSet"
        case other = "Other"
        case pending = "Pending"
        case indeterminate = "Indeterminate"
        case negative = "Negative"
        case positive = "Positive"
        case cancelled = "Cancelled"
    }
}

