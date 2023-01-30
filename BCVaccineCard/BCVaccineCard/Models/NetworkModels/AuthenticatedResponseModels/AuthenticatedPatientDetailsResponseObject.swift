//
//  AuthenticatedPatientDetailsResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-26.
//

import Foundation

// MARK: - AuthenticatedPatientDetailsResponseObject
struct AuthenticatedPatientDetailsResponseObject: BaseGatewayResponse, Codable {
    let resourcePayload: ResourcePayload?
    var totalResultCount, pageIndex, pageSize, resultStatus: Int?
    var resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let hdid, personalhealthnumber, firstname, lastname: String?
        let birthdate, gender: String?
        let physicalAddress: Address?
        let postalAddress: Address?
        let responseCode: String? // Not adding this to core data yet
        // Birthday format: "1967-06-02T00:00:00"
    }
    
    struct Address: Codable {
        let streetLines: [String]?
        let city: String
        let state: String
        let postalCode: String
        let country: String
        
        var getAddressString: String {
            var street = ""
            if let streetLines = streetLines, let first = streetLines.first, first.count > 0 {
                street = first + " ,"
            }
            return street + city.capitalized + ", " + state.uppercased() + " " + postalCode.uppercased()
        }
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
    
    var getBdayDate: Date? {
        guard let birthdate = resourcePayload?.birthdate else { return nil }
        return Date.Formatter.gatewayDateAndTime.date(from: birthdate)
    }
    
//    func isUserEqualToOrOlderThan(ageInYears age: Int) -> Bool {
//        guard let birthdate = resourcePayload?.birthdate, let birthday = Date.Formatter.gatewayDateAndTime.date(from: birthdate) else { return false }
//        if let referenceDate = Calendar.current.date(byAdding: .year, value: -age, to: Date()) {
//            return birthday <= referenceDate
//        }
//        return false
//    }

}

struct AuthenticatedValidAgeCheck: Codable {
    let resourcePayload: Bool?
    let totalResultCount, pageIndex, pageSize, resultStatus: Int?
    let resultError: ResultError?
}


