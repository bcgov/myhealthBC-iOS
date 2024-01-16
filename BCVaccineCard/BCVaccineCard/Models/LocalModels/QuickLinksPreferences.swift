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
            }
            return currentFilter
        }
        
        var getSection: Section {
            switch self {
            case .MyNotes, .Immunizations, .Medications, .LabResults, .COVID19Tests, .SpecialAuthority, .HospitalVisits, .HealthVisits, .ClinicalDocuments, .ImagingReports: return .HealthRecord
            case .OrganDonor: return .Service
            }
        }
        
    }
    
    // NOTE: For now, we have to manually set this, until we refine and come up with a better way (case iterable, use int raw values, then have a get function to get the string name)
    static func constructEmptyPreferences() -> [QuickLinksPreferences] {
        return [
            QuickLinksPreferences(name: .MyNotes, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .Immunizations, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .Medications, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .LabResults, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .COVID19Tests, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .SpecialAuthority, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .HospitalVisits, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .HealthVisits, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .ClinicalDocuments, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .ImagingReports, enabled: false, addedDate: nil),
            QuickLinksPreferences(name: .OrganDonor, enabled: false, addedDate: nil)
        ]
    }
    
}

struct LocalDictionaryQuickLinksPreferences: Codable {
    var storedPreferences: [String: [QuickLinksPreferences]]
}

extension QuickLinksPreferences: Equatable {
//    static func ==(lhs: QuickLinksPreferences, rhs: QuickLinksPreferences) -> Bool {
//        return lhs.name == rhs.name && lhs.enabled == rhs.enabled
//    }
}
