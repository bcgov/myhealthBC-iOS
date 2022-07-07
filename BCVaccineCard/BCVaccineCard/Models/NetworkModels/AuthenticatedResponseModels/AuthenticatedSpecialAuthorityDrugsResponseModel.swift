//
//  AuthenticatedSpecialAuthorityDrugsResponseModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-07-07.
//

import Foundation

// MARK: - Welcome
struct AuthenticatedSpecialAuthorityDrugsResponseModel: Codable {
    let resourcePayload: [SpecialAuthorityDrug]?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct SpecialAuthorityDrug: Codable {
        let referenceNumber, drugName, requestStatus, prescriberFirstName, prescriberLastName: String?
        let requestedDate: String? //"2021-09-16T00:00:00Z"
        let effectiveDate: String? //"2021-09-16T00:00:00"
        let expiryDate: String? //Unsure on formatting for now
        
        // For now, not going to use this for request status
        //enum RequestStatus: String, Codable {
        //    case approved = "Approved"
        //    case notApproved = "Not Approved"
        //    case received = "Received"
        //}
    }
}
