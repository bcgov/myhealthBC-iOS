//
//  AuthenticatedMedicationResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-02-04.
//

import Foundation
// MARK: - Welcome
struct AuthenticatedMedicationResponseObject: Codable {
    let resourcePayload: [ResourcePayload]
    let totalResultCount, pageIndex, pageSize, resultStatus: Int
    let resultError: ResultError?
    
    // MARK: - ResourcePayload
    struct ResourcePayload: Codable {
        let prescriptionIdentifier: String
        let prescriptionStatus: String
        let dispensedDate, practitionerSurname, directions: String
        let dateEntered: String?
        let pharmacyID: String
        let medicationSummary: MedicationSummary
        let dispensingPharmacy: DispensingPharmacy

        enum CodingKeys: String, CodingKey {
            case prescriptionIdentifier, prescriptionStatus, dispensedDate, practitionerSurname, directions, dateEntered
            case pharmacyID = "pharmacyId"
            case medicationSummary, dispensingPharmacy
        }
        
        // MARK: - DispensingPharmacy
        struct DispensingPharmacy: Codable {
            let pharmacyID: String
            let name: String
            let addressLine1: String
            let addressLine2: String
            let city: String
            let province: String
            let postalCode: String
            let countryCode: String
            let phoneNumber: String
            let faxNumber: String

            enum CodingKeys: String, CodingKey {
                case pharmacyID = "pharmacyId"
                case name, addressLine1, addressLine2, city, province, postalCode, countryCode, phoneNumber, faxNumber
            }
        }
        
        // MARK: - MedicationSummary
        struct MedicationSummary: Codable {
            let din, brandName, genericName: String
            let quantity: Double
            let maxDailyDosage: Int
            let drugDiscontinuedDate: String?
            let form: String
            let manufacturer, strength: String
            let strengthUnit: String
            let isPin: Bool
        }
    }
}
