//
//  AuthenticatedTestResultsResponseModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-26.
//

import Foundation

struct AuthenticatedTestResultsResponseModel: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: ResourcePayload
    struct ResourcePayload: Codable {
        let loaded: Bool
        let retryin: Int
        let orders: [Order]
        
        // MARK: - Order
        struct Order: Codable {
            let id: String?
            let phn: String?
            let orderingProviderIDS, orderingProviders, reportingLab, location: String?
            let labType: ORMOrOru?
            let messageDateTime: String?
            let messageID: String?
            let additionalData: String?
            let reportAvailable: Bool?
            let labResults: [LabResult]?
            
            enum CodingKeys: String, CodingKey {
                case id, phn
                case orderingProviderIDS = "orderingProviderIds"
                case orderingProviders, reportingLab, location, labType, messageDateTime
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
    
    
    
    
}

// MARK: Mapping functions to convert into model that we use for Core Data
// NOTE: For Amir...This will likely have to be adjusted in the future as a new table in Core Data (AuthenticatedTestResults) or something like that
extension AuthenticatedTestResultsResponseModel {
    // TODO: Check on values here
    static func transformToGatewayTestResultResponse(model: AuthenticatedTestResultsResponseModel.ResourcePayload.Order, patient: AuthenticatedPatientDetailsResponseObject) -> GatewayTestResultResponse {
        var records: [GatewayTestResultResponseRecord] = []
        model.labResults?.forEach({ labResult in
            let record = GatewayTestResultResponseRecord(patientDisplayName: patient.getFullName, lab: model.reportingLab, reportId: labResult.id, collectionDateTime: labResult.collectedDateTime, resultDateTime: labResult.resultDateTime, testName: labResult.loincName, testType: labResult.testType, testStatus: labResult.testStatus, testOutcome: labResult.labResultOutcome, resultTitle: labResult.loincName, resultDescription: labResult.resultDescription, resultLink: labResult.resultLink)
            records.append(record)
        })
        let resourcePayload = GatewayTestResultResponse.ResourcePayload(loaded: true, retryin: 0, records: records)
        let gatewayResponse = GatewayTestResultResponse(resourcePayload: resourcePayload, totalResultCount: nil, pageIndex: nil, pageSize: nil, resultStatus: nil, resultError: nil)
        return gatewayResponse
    }
}
