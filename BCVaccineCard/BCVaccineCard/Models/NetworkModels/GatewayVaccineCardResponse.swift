//
//  GatewayVaccineCard.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//

import Foundation

// MARK: - GatewayVaccineCardResponse
struct GatewayVaccineCardResponse: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let id: String?
        let loaded: Bool?
        let retryin: Int?
        let personalhealthnumber, firstname, lastname, birthdate: String?
        let vaccinedate: String?
        let doses, state: Int?
        let qrCode: QrCode?
        
        // MARK: - QrCode
        struct QrCode: Codable {
            let mediaType, encoding, data: String?
        }
    }
}

// MARK: - ResultError
// For now this can go here
struct ResultError: Codable {
    let resultMessage, errorCode, traceID, actionCode: String?

    enum CodingKeys: String, CodingKey {
        case resultMessage, errorCode
        case traceID = "traceId"
        case actionCode
    }
}

extension ResultError: Error {
    
}


