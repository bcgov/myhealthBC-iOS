//
//  GatewayVaccineCard.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
//

import Foundation
import BCVaccineValidator

// MARK: - GatewayVaccineCardResponse
struct GatewayVaccineCardResponse: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let id: String?
        let loaded: Bool? // This is for fed pass fetch, will be true or false. Max retry fetches set to 3
        let retryin: Int? // this is for fed pass fetch, in milliseconds
        let personalhealthnumber, firstname, lastname, birthdate: String?
        let vaccinedate: String?
        let doses, state: Int?
        let qrCode: QrPayload?
        let federalVaccineProof: QrPayload?
        
        // MARK: - QR Payload
        struct QrPayload: Codable {
            let mediaType, encoding, data: String?
        }
    }
    
    func transformResponseIntoQRCode() -> (qrString: String?, error: String?) {
        guard let qrCode = self.resourcePayload?.qrCode?.data,
              let image = qrCode.toImage() else {
                  return (nil, "There was an error with your request")
              }
        guard let codes = image.findQRCodes(),
              !codes.isEmpty else {
                  return (nil, "No QR found")
              }
        guard codes.count == 1,
              let code = codes.first else {
                  return (nil, "Multiple QR codes. Image must have only 1 code")
              }
        return (code, nil)
    }
}

// MARK: - ResultError
// For now this can go here
struct ResultError: Codable {
    let resultMessage: String?
    let errorCode: String? = nil
    let traceID: String? = nil
    let actionCode: String? = nil

    enum CodingKeys: String, CodingKey {
        case resultMessage, errorCode
        case traceID = "traceId"
        case actionCode
    }
}

extension ResultError: Error {
    
}


