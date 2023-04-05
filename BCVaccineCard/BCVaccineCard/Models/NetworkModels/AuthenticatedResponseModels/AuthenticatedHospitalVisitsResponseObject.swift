//
//  AuthenticatedHospitalVIsitsResponseObject.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

// MARK: - MobileConfigurationResponseObject
struct AuthenticatedHospitalVisitsResponseObject: BaseGatewayResponse, Codable {
    let resourcePayload: ResourcePayload?
    var totalResultCount, pageIndex, pageSize: Int?
    var resultError: ResultError?
    
    // MARK: - HospitalVisits
    struct ResourcePayload: BaseRetryableGatewayResponse, Codable {
        var loaded: Bool?
        var retryin: Int?
        let hospitalVisits: [HospitalVisit]?
    }

    // MARK: - HospitalVisit
    struct HospitalVisit: Codable {
        let encounterID, facility, healthService, visitType: String?
        let healthAuthority, admitDateTime, endDateTime, provider: String?

        enum CodingKeys: String, CodingKey {
            case encounterID = "encounterId"
            case facility, healthService, visitType, healthAuthority, admitDateTime, endDateTime, provider
        }
    }
}
