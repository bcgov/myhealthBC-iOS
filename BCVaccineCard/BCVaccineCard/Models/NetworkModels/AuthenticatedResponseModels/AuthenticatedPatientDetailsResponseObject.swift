//
//  AuthenticatedPatientDetailsResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-26.
//

import Foundation

// MARK: - AuthenticatedPatientDetailsResponseObject
struct AuthenticatedPatientDetailsResponseObject: Codable {
    let resourcePayload: ResourcePayload?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let hdid, personalhealthnumber, firstname, lastname: String?
        let birthdate, gender: String?
    }
    
    var getFullName: String {
        guard let payload = resourcePayload else { return "" }
        var name = ""
        if let first = payload.firstname {
            name.append(first)
        }
        if let last = payload.lastname {
            if !name.isEmpty {
                name.append(" ")
            }
            name.append(last)
        }
        return name
    }
}


