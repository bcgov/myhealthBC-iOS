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
    
    func transformResponseIntoLocallyStoredVaccinePassportModel() -> LocallyStoredVaccinePassportModel? {
        guard let code = self.resourcePayload?.qrCode?.data,
              let birthdateInitialString = self.resourcePayload?.birthdate,
              let doses = self.resourcePayload?.doses else {
                  return nil
              }
        // Just adding this here instead of unwrapping, as I don't want a date format issue to prevent a user from getting their QR code - worst case, they are able to get a duplicate QR code, which isn't the end of the world
        let birthdateDate = Date.Formatter.gatewayDateAndTime.date(from: birthdateInitialString) ?? Date()
        let birthdate = Date.Formatter.yearMonthDay.string(from: birthdateDate)
        let initialName = (self.resourcePayload?.firstname ?? "") + " " + (self.resourcePayload?.lastname ?? "")
        let name = initialName.trimWhiteSpacesAndNewLines.count > 0 ? initialName : "No Name"
        let issueDate = Date().timeIntervalSince1970
        let status: VaccineStatus = doses > 0 ? (doses > 1 ? .fully : .partially) : .notVaxed
        return LocallyStoredVaccinePassportModel(code: code, birthdate: birthdate, name: name, issueDate: issueDate, status: status, source: .healthGateway)
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


