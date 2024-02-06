//
//  AuthenticatedPatientDetailsResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-26.
//

import Foundation

// MARK: - AuthenticatedPatientDetailsResponseObject
struct AuthenticatedPatientDetailsResponseObject: Codable {
    let hdid, personalHealthNumber: String?
    let commonName, legalName, preferredName: Name?
    let birthdate, gender: String?
    let physicalAddress, postalAddress: Address?
    let responseCode: String?
    
    struct Name: Codable {
        let givenName, surname: String?
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
        var name = ""
        if let first = preferredName?.givenName {
            name.append(first)
        }
        if let last = preferredName?.surname {
            if !name.isEmpty {
                name.append(" ")
            }
            name.append(last)
        }
        return name
    }
    
    var getBdayDate: Date? {
        guard let birthdate = birthdate else { return nil }
        if let date = Date.Formatter.yearMonthDay.date(from: birthdate) {
            return date
        } else {
            return Date.Formatter.gatewayDateAndTime.date(from: birthdate)
        }
        
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


