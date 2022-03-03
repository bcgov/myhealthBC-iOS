//
//  AuthenticatedLaboratoryOrdersResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-02-17.
//

import Foundation

// MARK: - Welcome
struct AuthenticatedLaboratoryOrdersResponseObject: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let loaded: Bool?
        let retryin: Int?
        let orders: [Order]
        
        // MARK: - Order
        struct Order: Codable {
            let laboratoryReportID, reportingSource, reportID, collectionDateTime: String?
            let commonName, orderingProvider, testStatus: String?
            let reportAvailable: Bool?
            let laboratoryTests: [LaboratoryTest]?

            enum CodingKeys: String, CodingKey {
                case laboratoryReportID = "laboratoryReportId"
                case reportingSource
                case reportID = "reportId"
                case collectionDateTime, commonName, orderingProvider, testStatus, reportAvailable, laboratoryTests
            }
            
            // MARK: - LaboratoryTest
            struct LaboratoryTest: Codable {
                let batteryType, obxID: String?
                let outOfRange: Bool?
                let loinc, testStatus: String?

                enum CodingKeys: String, CodingKey {
                    case batteryType
                    case obxID = "obxId"
                    case outOfRange, loinc, testStatus
                }
            }
        }
    }
}