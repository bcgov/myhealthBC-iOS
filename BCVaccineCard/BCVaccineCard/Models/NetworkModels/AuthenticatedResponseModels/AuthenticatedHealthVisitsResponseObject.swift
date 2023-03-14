//
//  AuthenticatedHealthVisitsResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-07-05.
//

import Foundation

// MARK: - Welcome
struct AuthenticatedHealthVisitsResponseObject: BaseGatewayResponse, Codable {
    let resourcePayload: [HealthVisit]?
    var totalResultCount, pageIndex, pageSize: Int?
    var resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct HealthVisit: Codable {
        let id, encounterDate, specialtyDescription, practitionerName: String?
        let clinic: Clinic?
        
        // MARK: - Clinic
        struct Clinic: Codable {
            let name: String?
        }
    }
}

