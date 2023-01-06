//
//  AuthenticatedLaboratoryOrdersResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-02-17.
//

import Foundation

enum LabTestType {
    case normal
    case covid
    
    var getBoolStringValue: String {
        switch self {
        case .normal:
            return "false"
        case .covid:
            return "true"
        }
    }
}

// MARK: - Welcome
struct AuthenticatedLaboratoryOrdersResponseObject: BaseGatewayResponse, Codable {
    let resourcePayload: ResourcePayload?
    var totalResultCount, pageIndex, pageSize, resultStatus: Int?
    var resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let loaded: Bool?
        let retryin: Int?
        let orders: [Order]
        
        // MARK: - Order
        struct Order: Codable {
            let labPdfId, reportingSource, reportID, collectionDateTime, timelineDateTime: String?
            let commonName, orderingProvider, orderStatus, testStatus: String?
            let reportAvailable: Bool?
            let laboratoryTests: [LaboratoryTest]?

            enum CodingKeys: String, CodingKey {
                case labPdfId
                case reportingSource
                case reportID = "reportId"
                case collectionDateTime, timelineDateTime, commonName, orderingProvider, testStatus, reportAvailable, laboratoryTests, orderStatus
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
