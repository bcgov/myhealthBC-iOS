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
              let birthdateDate = Date.Formatter.gatewayDateAndTime.date(from: birthdateInitialString),
              let vaxDateString = self.resourcePayload?.vaccinedate,
              let vaxDate = Date.Formatter.gatewayDateAndTime.date(from: vaxDateString),
              let doses = self.resourcePayload?.doses else {
                  return nil
              }
        let birthdate = Date.Formatter.yearMonthDay.string(from: birthdateDate)
        let initialName = (self.resourcePayload?.firstname ?? "") + " " + (self.resourcePayload?.lastname ?? "")
        let name = initialName.trimWhiteSpacesAndNewLines.count > 0 ? initialName : "No Name"
        let issueDate = vaxDate.timeIntervalSince1970
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


