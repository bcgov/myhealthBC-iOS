//
//  AuthenticatedClinicalDocumentResponse.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

struct AuthenticatedClinicalDocumentResponseObject: BaseGatewayResponse, Codable {
    var resourcePayload: [ClinicalDocument]?
    var totalResultCount: Int?
    var pageIndex: Int?
    var pageSize: Int?
    var resultStatus: Int?
    var resultError: ResultError?
    
    struct ClinicalDocument: Codable {
        let id, fileID, name, type: String?
        let facilityName, discipline, serviceDate: String?

        enum CodingKeys: String, CodingKey {
            case id
            case fileID = "fileId"
            case name, type, facilityName, discipline, serviceDate
        }
    }
}
