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
    var totalResultCount, pageIndex, pageSize: Int?
    var resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let hdid, personalhealthnumber, firstname, lastname: String?
        let birthdate, gender: String?
        let physicalAddress, postalAddress: Address?
        let responseCode: String?
    }
    
    struct Address: Codable {
        let streetLines: [String]?
        let city, state, postalCode, country: String?
        var getAddressString: String? {
            var street = ""
            if let streetLines = streetLines, let first = streetLines.first, first.count > 0 {
                street = first + ", "
            }
            var cit = ""
            if let city = city, city.count > 0 {
                cit = city + ", "
            }
            var stat = ""
            if let state = state, state.count > 0 {
                stat = state + " "
            }
            var postal = ""
            if let postalCode = postalCode {
                postal = postalCode
            }
            let addyString = street + cit.capitalized + stat.uppercased() + postal.uppercased()
            return addyString.count > 0 ? addyString : nil
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
    let totalResultCount, pageIndex, pageSize: Int?
    let resultError: ResultError?
}


