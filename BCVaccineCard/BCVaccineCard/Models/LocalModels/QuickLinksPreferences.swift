//
//  QuickLinksPreferences.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-08-15.
//

import Foundation


struct QuickLinksPreferences: Codable {
    let name: QuickLinksNames
    var enabled: Bool
    var addedDate: Date?
    var includedInFeatureToggle: Bool?
    
//    enum Keys: CodingKey {
//        case name
//        case enabled
//        case addedDate
//        case includedInFeatureToggle
//      }
//    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        name = try container.decode(QuickLinksNames.self, forKey: .name)
//        enabled = try container.decode(Bool.self, forKey: .enabled)
//        addedDate = try container.decode(Date.self, forKey: .addedDate)
//        includedInFeatureToggle = try container.decodeIfPresent(Bool.self, forKey: .includedInFeatureToggle) ?? false
//    }
    
    enum QuickLinksNames: String, Codable {
        case MyNotes = "My Notes"
        case Immunizations = "Immunizations"
        case Medications = "Medications"
        case LabResults = "Lab Results"
        case COVID19Tests = "COVID-19 Tests"
        case SpecialAuthority = "Special Authority"
        case HospitalVisits = "Hospital Visits"
        case HealthVisits = "Health Visits"
        case ClinicalDocuments = "Clinical Documents"
        case ImagingReports = "Imaging Reports"
        case OrganDonor = "Organ Donor"
        case BCCancerScreening = "BC Cancer Screening"
        
        enum Section: String, Codable {
            case HealthRecord = "Health Record"
            case Service = "Service"
        }
        
        var getHomeScreenDisplayableName: String {
            switch self {
            case .MyNotes: return .myNotesHome
            case .Immunizations: return .immunizationsHome
            case .Medications: return .medicationsHome
            case .LabResults: return .labResultsHome
            case .COVID19Tests: return .covid19TestsHome
            case .SpecialAuthority: return .specialAuthorityHome
            case .HospitalVisits: return .hospitalVisitsHome
            case .HealthVisits: return .healthVisitsHome
            case .ClinicalDocuments: return .clinicalDocumentsHome
            case .ImagingReports: return .imagingReportsHome
            case .OrganDonor: return .organDonorHome
            case .BCCancerScreening: return .bcCancerScreeningHome
            }
        }
        
        var getManageScreenDisplayableName: String {
            switch self {
            case .MyNotes: return .myNotesManage
            case .Immunizations: return .immunizationsManage
            case .Medications: return .medicationsManage
            case .LabResults: return .labResultsManage
            case .COVID19Tests: return .covid19TestsManage
            case .SpecialAuthority: return .specialAuthorityManage
            case .HospitalVisits: return .hospitalVisitsManage
            case .HealthVisits: return .healthVisitsManage
            case .ClinicalDocuments: return .clinicalDocumentsManage
            case .ImagingReports: return .imagingReportsManage
            case .OrganDonor: return .organDonorManage
            case .BCCancerScreening: return .bcCancerScreeningManage
            }
        }

        var getHomeScreenIconStringName: String? {
            switch self {
            case .MyNotes: return "blue-bg-notes-icon"
            case .Immunizations: return "blue-bg-vaccine-record-icon"
            case .Medications: return "blue-bg-medication-record-icon"
            case .LabResults: return "blue-bg-laboratory-record-icon"
            case .COVID19Tests: return "blue-bg-test-result-icon"
            case .SpecialAuthority: return "blue-bg-special-authority-icon"
            case .HospitalVisits: return "blue-bg-hospital-visits-icon"
            case .HealthVisits: return "blue-bg-health-visit-icon"
            case .ClinicalDocuments: return "blue-bg-clinical-documents-icon"
            case .ImagingReports: return "blue-bg-diagnostic-imaging-icon"
            case .OrganDonor: return "ogran-donor-logo" // Note: Should probably fix the spelling error here"
            case .BCCancerScreening: return "blue-bg-cancer-screening-icon"
            }
        }
        
        var getFilterType: RecordsFilter? {
            var currentFilter: RecordsFilter? = RecordsFilter()
            switch self {
            case .MyNotes:
                currentFilter?.recordTypes = [.Notes]
            case .Immunizations:
                currentFilter?.recordTypes = [.Immunizations]
            case .Medications:
                currentFilter?.recordTypes = [.Medication]
            case .LabResults:
                currentFilter?.recordTypes = [.LabTests]
            case .COVID19Tests:
                currentFilter?.recordTypes = [.Covid]
            case .SpecialAuthority:
                currentFilter?.recordTypes = [.SpecialAuthorityDrugs]
            case .HospitalVisits:
                currentFilter?.recordTypes = [.HospitalVisits]
            case .HealthVisits:
                currentFilter?.recordTypes = [.HeathVisits]
            case .ClinicalDocuments:
                currentFilter?.recordTypes = [.ClinicalDocuments]
            case .ImagingReports:
                currentFilter?.recordTypes = [.DiagnosticImaging]
            case .OrganDonor:
                currentFilter = nil
            case .BCCancerScreening:
                currentFilter?.recordTypes = [.CancerScreening]
            }
            return currentFilter
        }
        
        var getSection: Section {
            switch self {
            case .MyNotes, .Immunizations, .Medications, .LabResults, .COVID19Tests, .SpecialAuthority, .HospitalVisits, .HealthVisits, .ClinicalDocuments, .ImagingReports, .BCCancerScreening: return .HealthRecord
            case .OrganDonor: return .Service
            }
        }
        
    }
    
    // NOTE: For now, we have to manually set this, until we refine and come up with a better way (case iterable, use int raw values, then have a get function to get the string name)
    static func constructEmptyPreferences() -> [QuickLinksPreferences] {
        let records = QuickLinksPreferences.convertFeatureToggleToQuickLinksPreferences(for: .HealthRecord)
        let services = QuickLinksPreferences.convertFeatureToggleToQuickLinksPreferences(for: .Service)
        return [
            QuickLinksPreferences(name: .MyNotes, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .MyNotes, enabledTypes: records)),
            QuickLinksPreferences(name: .Immunizations, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .Immunizations, enabledTypes: records)),
            QuickLinksPreferences(name: .Medications, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .Medications, enabledTypes: records)),
            QuickLinksPreferences(name: .LabResults, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .LabResults, enabledTypes: records)),
            QuickLinksPreferences(name: .COVID19Tests, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .COVID19Tests, enabledTypes: records)),
            QuickLinksPreferences(name: .SpecialAuthority, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .SpecialAuthority, enabledTypes: records)),
            QuickLinksPreferences(name: .HospitalVisits, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .HospitalVisits, enabledTypes: records)),
            QuickLinksPreferences(name: .HealthVisits, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .HealthVisits, enabledTypes: records)),
            QuickLinksPreferences(name: .ClinicalDocuments, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .ClinicalDocuments, enabledTypes: records)),
            QuickLinksPreferences(name: .ImagingReports, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .ImagingReports, enabledTypes: records)),
            QuickLinksPreferences(name: .BCCancerScreening, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .BCCancerScreening, enabledTypes: records)),
            QuickLinksPreferences(name: .OrganDonor, enabled: false, addedDate: nil,
                                  includedInFeatureToggle: QuickLinksPreferences.isFeatureEnabled(feature: .OrganDonor, enabledTypes: services))
            
        ]
    }
    
    static func convertFeatureToggleToQuickLinksPreferences(for section: QuickLinksPreferences.QuickLinksNames.Section) -> [QuickLinksPreferences.QuickLinksNames] {
        guard let enabledTypes = Defaults.enabledTypes else { return [] }
        switch section {
        case .HealthRecord:
            var types = enabledTypes.datasets.compactMap { $0.getQuickLinksNameType }
            let updatedTypes: [QuickLinksPreferences.QuickLinksNames]
            if !HealthRecordConstants.notesEnabled {
                updatedTypes = types.filter({ $0 != .MyNotes })
            } else {
                updatedTypes = types
            }
            return updatedTypes
        case .Service:
            return enabledTypes.services.compactMap { $0.getQuickLinksNameType }
        }
    }
    
    static func isFeatureEnabled(feature: QuickLinksNames, enabledTypes: [QuickLinksNames]) -> Bool {
        return enabledTypes.contains(feature)
    }
    
}

struct LocalDictionaryQuickLinksPreferences: Codable {
    var storedPreferences: [String: [QuickLinksPreferences]]
}
