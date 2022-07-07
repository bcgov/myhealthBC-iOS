//
//  AuthenticatedHealthVisitsResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-07-05.
//

import Foundation

// MARK: - Welcome
struct AuthenticatedHealthVisitsResponseObject: Codable {
    let resourcePayload: [HealthVisit]?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
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

