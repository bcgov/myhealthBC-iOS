//
//  QuickLinksPreferences.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-08-15.
//

import Foundation


struct QuickLinksPreferences: Codable {
    let type: QuickLinksNames
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
            case .MyNotes: return "My\nNotes"
            case .Immunizations: return rawValue
            case .Medications: return rawValue
            case .LabResults: return "Lab\nResults"
            case .COVID19Tests: return "COVID-19\nTests"
            case .SpecialAuthority: return "Special\nAuthority"
            case .HospitalVisits: return "Hospital\nVisits"
            case .HealthVisits: return "Health\nVisits"
            case .ClinicalDocuments: return "Clinical\nDocuments"
            case .ImagingReports: return "Imaging\nReports"
            case .OrganDonor: return "Organ\nDonor"
            }
        }
        
        var getManageScreenDisplayableName: String {
            switch self {
            case .MyNotes: return "My Notes"
            case .Immunizations: return "Immunization"
            case .Medications: return "Medications"
            case .LabResults: return "Lab Results"
            case .COVID19Tests: return "COVID-19 Tests"
            case .SpecialAuthority: return "Special Authority"
            case .HospitalVisits: return "Hospital Visits"
            case .HealthVisits: return "Health Visits"
            case .ClinicalDocuments: return "Clinical Documents"
            case .ImagingReports: return "Imaging Reports"
            case .OrganDonor: return "Organ Donor"
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
            QuickLinksPreferences(type: .MyNotes, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .Immunizations, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .Medications, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .LabResults, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .COVID19Tests, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .SpecialAuthority, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .HospitalVisits, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .HealthVisits, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .ClinicalDocuments, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .ImagingReports, enabled: false, addedDate: nil),
            QuickLinksPreferences(type: .OrganDonor, enabled: false, addedDate: nil)
        ]
    }
    
}

struct LocalDictionaryQuickLinksPreferences: Codable {
    var storedPreferences: [String: [QuickLinksPreferences]]
}
