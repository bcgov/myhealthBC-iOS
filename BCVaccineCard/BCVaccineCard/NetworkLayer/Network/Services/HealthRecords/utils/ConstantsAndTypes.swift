//
//  HealthRecordUtils.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-10.
//

import Foundation

struct HealthRecordConstants {
    // ENABLE AND DISABLE PRIMARY PATIENT RECORD TYPES
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
    
    // ENABLE AND DISABLE DEPENDENT RECORD TYPES
    static var enabledDepententRecordTypes: [RecordType] {
        return [.covidTestResultRecord, .immunization]
    }
    
    // ENABLE AND DISABLE COMMENTS
    static var commentsEnabled: Bool {
        return true
    }
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

extension StorageService {
    enum healthRecordType: CaseIterable {
        case CovidTest
        case VaccineCard
        case Prescription
        case LaboratoryOrder
        case Immunization
        case Recommendation
        case HealthVisit
        case SpecialAuthorityDrug
        case HospitalVisit
        case ClinicalDocument
    }
}

extension HealthRecordConstants.RecordType {
    func toRecordsFilterType() -> RecordsFilter.RecordType? {
        switch self {
        case .covidImmunizationRecord:
            return nil
        case .covidTestResultRecord:
            return .Covid
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
    
    func toStorageType() -> StorageService.healthRecordType? {
        switch self {
        case .covidImmunizationRecord:
            return .Immunization
        case .covidTestResultRecord:
            return .CovidTest
        case .medication:
            return .Prescription
        case .laboratoryOrder:
            return .LaboratoryOrder
        case .immunization:
            return .Immunization
        case .healthVisit:
            return .HealthVisit
        case .specialAuthorityDrug:
            return .SpecialAuthorityDrug
        case .hospitalVisit:
            return .HospitalVisit
        case .clinicalDocument:
            return .ClinicalDocument
        }
    }
}

struct RecordsFilter {
    enum RecordType: String, CaseIterable {
        case HeathVisits = "Health Visits"
        case LabTests = "Lab Results"
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
    // Patient filters - set based on HealthRecordConstants.enabledTypes
    static var avaiableFilters: [RecordsFilter.RecordType] {
        let availableTypes = HealthRecordConstants.enabledTypes
        return availableTypes.compactMap({$0.toRecordsFilterType()})
    }
    
    // Dependent filters - set based on HealthRecordConstants.enabledDepententRecordTypes
    static var dependentFilters: [RecordsFilter.RecordType] {
        let availableTypes = HealthRecordConstants.enabledDepententRecordTypes
        return availableTypes.compactMap({$0.toRecordsFilterType()})
    }
}
