//
//  AuthenticatedTestResultsResponseModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-26.
//

import Foundation

struct AuthenticatedTestResultsResponseModel: Codable {
    let resourcePayload: [ResourcePayload]?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let id: String?
        let phn: String?
        let orderingProviderIDS, orderingProviders, reportingLab, location: String?
        let ormOrOru: ORMOrOru?
        let messageDateTime: String?
        let messageID: String?
        let additionalData: String?
        let reportAvailable: Bool?
        let labResults: [LabResult]?

        enum CodingKeys: String, CodingKey {
            case id, phn
            case orderingProviderIDS = "orderingProviderIds"
            case orderingProviders, reportingLab, location, ormOrOru, messageDateTime
            case messageID = "messageId"
            case additionalData, reportAvailable, labResults
        }
        
        // MARK: - LabResult
        struct LabResult: Codable {
            let id: String?
            let testType: String?
            let outOfRange: Bool?
            let collectedDateTime: String?
            let testStatus, labResultOutcome: String?
            let resultDescription: [String]?
            let resultLink: String?
            let receivedDateTime, resultDateTime: String?
            let loinc: String?
            let loincName: String?
        }

        //enum Loinc: String, Codable {
        //    case the943092 = "94309-2"
        //    case xxx1927 = "XXX-1927"
        //    case xxx3286 = "XXX-3286"
        //}

        enum ORMOrOru: String, Codable {
            case orm = "ORM"
            case oru = "ORU"
        }
    }
    
    
}

// MARK: Mapping functions to convert into model that we use for Core Data
// NOTE: For Amir...This will likely have to be adjusted in the future as a new table in Core Data (AuthenticatedTestResults) or something like that
extension AuthenticatedTestResultsResponseModel {
    
    
}


//struct GatewayTestResultResponse: Codable, Equatable {
//    static func == (lhs: GatewayTestResultResponse, rhs: GatewayTestResultResponse) -> Bool {
//        if let rhsResponse = rhs.resourcePayload, let lshResponse = lhs.resourcePayload {
//            return lshResponse.records.equals(other: rhsResponse.records)
//        }
//        return (rhs.resourcePayload == nil && lhs.resourcePayload == nil)
//    }
//
//    let resourcePayload: ResourcePayload?
//    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
//    let resultError: ResultError?
//
//    // MARK: - ResourcePayload
//    struct ResourcePayload: Codable {
//        let loaded: Bool
//        let retryin: Int
//        let records: [GatewayTestResultResponseRecord]
//    }
//}
//
//struct GatewayTestResultResponseRecord: Codable, Equatable {
//    let patientDisplayName: String?
//    let lab: String?
//    let reportId: String?
//    let collectionDateTime: String?
//    let resultDateTime: String?
//    let testName: String?
//    let testType: String?
//    let testStatus: String?
//    let testOutcome: String?
//    let resultTitle: String?
//    let resultDescription: [String]?
//    let resultLink: String?
//
//    var collectionDateTimeDate: Date? {
//        guard let dateString = self.collectionDateTime else { return nil }
//        return Date.Formatter.gatewayDateAndTime.date(from: dateString)
//    }
//
//    var resultDateTimeDate: Date? {
//        guard let dateString = self.resultDateTime else { return nil }
//        return Date.Formatter.gatewayDateAndTime.date(from: dateString)
//    }
//}
//
//extension Array where Element == GatewayTestResultResponseRecord {
//    func equals(other: [GatewayTestResultResponseRecord]) -> Bool {
//        for el in self {
//            if !other.contains(where: { element in
//                return element == el
//            }) {
//                return false
//            }
//        }
//        return self.count == other.count
//    }
//}
//
//extension GatewayTestResultResponseRecord {
//    enum ResponseStatusTypes: String, Codable {
//        case pending = "Pending"
//        case final = "Final"
//        case statusChange = "Status Change" //To Check here
//    }
//
//    enum ResponseOutcomeTypes: String, Codable {
//        case notSet = "Not Set" // To Check here
//        case other = "Other"
//        case pending = "Pending"
//        case indeterminate = "Indeterminate"
//        case negative = "Negative"
//        case positive = "Positive"
//        case cancelled = "Cancelled"
//    }
//}
