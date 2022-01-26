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
        let messageDateTime: Date?
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
            let collectedDateTime: Date?
            let testStatus, labResultOutcome: String?
            let resultDescription: [String]?
            let resultLink: String?
            let receivedDateTime, resultDateTime: Date?
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

// TODO: Map to local data source below (for time being - need to discuss with Amir
