//
//  HealthRecordUtils.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-10.
//

import Foundation

struct HealthRecordConstants {
    static var enabledTypes: [RecordType] {
        return [
            .covidImmunizationRecord,
            .covidTestResultRecord,
            .medication,
            .laboratoryOrder,
            .immunization,
            .healthVisit,
            .specialAuthorityDrug,
            .hospitalVisit,
            .clinicalDocument
        ]
    }
    // TODO:
//    static var enabledDependentTypes: [RecordType] {
//    }
}

extension HealthRecordConstants {
    enum RecordType {
        case covidImmunizationRecord
        case covidTestResultRecord
        case medication
        case laboratoryOrder
        case immunization
        case healthVisit
        case specialAuthorityDrug
        case hospitalVisit
        case clinicalDocument
    }
}

extension HealthRecordConstants.RecordType {
    func toRecordsFilterType() -> RecordsFilter.RecordType? {
        switch self {
        case .covidImmunizationRecord:
            return .Covid
        case .covidTestResultRecord:
            return .LabTests
        case .medication:
            return .Medication
        case .laboratoryOrder:
            return .LabTests
        case .immunization:
            return .Immunizations
        case .healthVisit:
            return .HeathVisits
        case .specialAuthorityDrug:
            return .SpecialAuthorityDrugs
        case .hospitalVisit:
            return .HospitalVisits
        case .clinicalDocument:
            return .ClinicalDocuments
        }
    }
}

struct RecordsFilter {
    enum RecordType: String, CaseIterable {
        case HeathVisits = "Health Visits"
        case LabTests = "Lab Tests"
        case Medication = "Medications"
        case ClinicalDocuments = "Clinical Docs"
        case Covid = "COVID-19 Tests"
        case Immunizations = "Immunizations"
        case SpecialAuthorityDrugs = "Special Authority"
        case HospitalVisits = "Hospital Visits"
    }
    
    var fromDate: Date?
    var toDate: Date?
    var recordTypes: [RecordType] = []
    
    var exists: Bool {
        return fromDate != nil || toDate != nil || !recordTypes.isEmpty
    }
}

extension RecordsFilter.RecordType {
    static var avaiableFilters: [RecordsFilter.RecordType] {
        let availableTypes = HealthRecordConstants.enabledTypes
        return availableTypes.compactMap({$0.toRecordsFilterType()})
    }
}
