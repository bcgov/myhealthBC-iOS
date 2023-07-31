//
//  ManageHomeScreenViewModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-26.
//

import Foundation

extension ManageHomeScreenViewController {
    struct ViewModel {
        let dataSource: DataSource
        
        func createDataSource() {
            let coreDataQuickLinks = StorageService.shared.fetchQuickLinksPreferences()
            let convertedQuickLinks = convertCoreDataQuickLinks(coreDataModel: coreDataQuickLinks)
            
        }
        
        private func convertCoreDataQuickLinks(coreDataModel: [QuickLinkPreferences]) -> [QuickLinksNames] {
            var links: [QuickLinksNames] = []
            for model in coreDataModel {
                if let name = model.quickLink, let link = QuickLinksNames(rawValue: name) {
                    links.append(link)
                }
            }
            return links
        }
    }
    
    enum DataSource {
        case introText(text: String)
        case healthRecord(types: [QuickLinksNames])
        case service(types: [QuickLinksNames])
    }
    
    enum QuickLinksNames: String, Codable {
        case MyNotes = "My Notes"
        case Immunizations = "Immunizations"
        case Medications = "Medications"
        case LabResults = "Lab Results"
        case COVID19Tests = "COVID-19 Tests"
        case SpecialAuthority = "Special Authority"
        case HospitalVisits = "Hospital Visits"
        case ClinicalDocuments = "Clinical Documents"
        case ImagingReports = "Imaging Reports"
        case OrganDonor = "Organ Donor"
        
        enum Section: Codable {
            case HealthRecord
            case Service
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
            case .ClinicalDocuments: return "Clinical\nDocuments"
            case .ImagingReports: return "Imaging\nReports"
            case .OrganDonor: return "Organ\nDonor"
            }
        }
        // TODO: Get the icon used on the list of health records for the record type
        var getHomeScreenIconStringName: String? {
            switch self {
            case .MyNotes: return "blue-bg-notes-icon"
            case .Immunizations: return "blue-bg-vaccine-record-icon"
            case .Medications: return "blue-bg-medication-record-icon"
            case .LabResults: return "blue-bg-laboratory-record-icon"
            case .COVID19Tests: return "blue-bg-test-result-icon"
            case .SpecialAuthority: return "blue-bg-special-authority-icon"
            case .HospitalVisits: return "blue-bg-health-visit-icon"
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
            case .MyNotes, .Immunizations, .Medications, .LabResults, .COVID19Tests, .SpecialAuthority, .HospitalVisits, .ClinicalDocuments, .ImagingReports: return .HealthRecord
            case .OrganDonor: return .Service
            }
        }
    }
    
}






//        let filter: Filter?

//        enum FilterTypes: String, Codable {
//            case Immunization = "Immunization"
//            case Medication = "Medication"
//            case AllLaboratory = "AllLaboratory"
//            case Laboratory = "Laboratory"
//            case Encounter = "Encounter"
//            case Note = "Note"
//            case MedicationRequest = "MedicationRequest"
//            case ClinicalDocument = "ClinicalDocument"
//            case HospitalVisit = "HospitalVisit"
//            case DiagnosticImaging = "DiagnosticImaging"
//        }
//        struct Filter: Codable {
//            let modules: [String]
//
//            var getModules: [FilterTypes] {
//                var mod: [FilterTypes] = []
//                for module in modules {
//                    if let filterType = FilterTypes(rawValue: module) {
//                        mod.append(filterType)
//                    }
//                }
//                return mod
//            }
//        }
