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
