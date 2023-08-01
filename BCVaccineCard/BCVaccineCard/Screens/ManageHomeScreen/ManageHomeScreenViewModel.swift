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
            // TODO: Finish this
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
        
        static func constructJsonStringForAPIPreferences(quickLinks: [QuickLinksNames]) -> String? {
            var quickLinksModel: [QuickLinksModelForPreferences] = []
            for link in quickLinks {
                let module = link.getAPIFilterType?.rawValue ?? ""
                let filter = QuickLinksModelForPreferences.Filter(modules: [module])
                let preference = QuickLinksModelForPreferences(name: link.rawValue, filter: filter)
                quickLinksModel.append(preference)
            }
            return quickLinksModel.toJsonString()
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
        case HealthVisits = "Health Visits"
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
            case .HealthVisits: return "Health\nVisits"
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
        
        var getAPIFilterType: APIFilterTypes? {
            switch self {
            case .MyNotes: return .Note
            case .Immunizations: return .Immunization
            case .Medications: return .Medication
            case .LabResults: return .AllLaboratory
            case .COVID19Tests: return .Laboratory
            case .SpecialAuthority: return .MedicationRequest
            case .HospitalVisits: return .HospitalVisit
            case .HealthVisits: return .Encounter
            case .ClinicalDocuments: return .ClinicalDocument
            case .ImagingReports: return .DiagnosticImaging
            case .OrganDonor: return nil
            }
        }
        
        enum APIFilterTypes: String, Codable {
            case Immunization = "Immunization"
            case Medication = "Medication"
            case AllLaboratory = "AllLaboratory"
            case Laboratory = "Laboratory"
            case Encounter = "Encounter"
            case Note = "Note"
            case MedicationRequest = "MedicationRequest"
            case ClinicalDocument = "ClinicalDocument"
            case HospitalVisit = "HospitalVisit"
            case DiagnosticImaging = "DiagnosticImaging"
        }
//        struct Filter: Codable {
//            let modules: [String]
//
//            var getModules: [APIFilterTypes] {
//                var mod: [APIFilterTypes] = []
//                for module in modules {
//                    if let filterType = APIFilterTypes(rawValue: module) {
//                        mod.append(filterType)
//                    }
//                }
//                return mod
//            }
//        }
        
    }
    
}


        
