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
        var types: [RecordType] = [
            .covidImmunizationRecord,
            .covidTestResultRecord,
            .medication,
            .laboratoryOrder,
            .immunization,
            .healthVisit,
            .specialAuthorityDrug,
            .hospitalVisit,
            .clinicalDocument,
            .diagnosticImaging,
            .notes
        ]
        if !HealthRecordConstants.notesEnabled {
            if let index = types.firstIndex(of: .notes) {
                types.remove(at: index)
            }
        }
        return types
    }
    
    // ENABLE AND DISABLE DEPENDENT RECORD TYPES
    static var enabledDepententRecordTypes: [RecordType] {
        return [.covidTestResultRecord, .immunization]
    }
    
    // ENABLE AND DISABLE COMMENTS
    static var commentsEnabled: Bool {
        return false
    }
    
    // ENABLE AND DISABLE SEARCH RECORDS
    static var searchRecordsEnabled: Bool {
        return true
    }
    
    // ENABLE AND DISABLE PROFILE DETAILS SCREEN
    static var profileDetailsEnabled: Bool {
        return true
    }
    
    // ENABLE AND DISABLE NOTES
    static var notesEnabled: Bool {
        return true
    }
}

extension AppTabBarController {
    // CHANGE TABS FOR AUTHENTICATED USER
    var authenticatedTabs: [AppTabs] {
        return [.Home, .AuthenticatedRecords, .Services, .Dependents]
    }
    // CHANGE TABS FOR UNAUTHENTICATED USER
    var unAuthenticatedTabs: [AppTabs] {
        return [.Home, .UnAuthenticatedRecords, .Services, .Dependents]
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
        case diagnosticImaging
        case notes
    }
}

extension StorageService {
    enum HealthRecordType: CaseIterable {
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
        case DiagnosticImaging
        case Notes
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
        case .diagnosticImaging:
            return .DiagnosticImaging
        case .notes:
            return .Notes
        }
    }
    
    func toStorageType() -> StorageService.HealthRecordType? {
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
        case .diagnosticImaging:
            return .DiagnosticImaging
        case .notes:
            return .Notes
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
        case DiagnosticImaging = "Imaging reports"
        case Notes = "Notes"
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
