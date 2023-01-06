//
//  AuthenticatedHospitalVIsitsResponseObject.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

// MARK: - MobileConfigurationResponseObject
struct AuthenticatedHospitalVisitsResponseObject: BaseGatewayResponse, Codable {
    let resourcePayload: [HospitalVisits]?
    var totalResultCount, pageIndex, pageSize, resultStatus: Int?
    var resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct HospitalVisits: Codable {
        let id, encounterDate, specialtyDescription, practitionerName: String
        let clinic: Clinic
    }

    // MARK: - Clinic
    struct Clinic: Codable {
        let name: String
    }
    
}
