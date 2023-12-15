//
//  MobileConfigurationResponseObject.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-28.
//

import Foundation

// MARK: - MobileConfigurationResponseObject
struct MobileConfigurationResponseObject: Codable {
    let online: Bool
    let baseURL: String?
    let authentication: AuthenticationConfig?
    let version: Int?
    let datasets: [String]
    let dependentDatasets: [String]
    let services: [String]

    enum CodingKeys: String, CodingKey {
        case online
        case baseURL = "baseUrl"
        case authentication, version, datasets, dependentDatasets, services
    }
}

// MARK: - Authentication
struct AuthenticationConfig: Codable {
    let endpoint: String?
    let identityProviderID, clientID, redirectURI: String?

    enum CodingKeys: String, CodingKey {
        case endpoint
        case identityProviderID = "identityProviderId"
        case clientID = "clientId"
        case redirectURI = "redirectUri"
    }
}

// MARK: To be stored in user defaults
struct EnabledTypes: Codable {
    enum DataSetValues: String, Codable {
        case Covid19TestResult = "covid19TestResult"
        case ClinicalDocument = "clinicalDocument"
        case DiagnosticImaging = "diagnosticImaging"
        case HealthVisit = "healthVisit"
        case HospitalVisit = "hospitalVisit"
        case Immunization = "immunization"
        case LabResult = "labResult"
        case Medication = "medication"
        case Note = "note"
        case SpecialAuthorityRequest = "specialAuthorityRequest"
        case BcCancerScreening = "bcCancerScreening"
        case UnknownValue = "UnknownValue"
        
        var getHealthRecordType: StorageService.HealthRecordType? {
            switch self {
            case .Covid19TestResult: return .CovidTest
            case .ClinicalDocument: return .ClinicalDocument
            case .DiagnosticImaging: return .DiagnosticImaging
            case .HealthVisit: return .HealthVisit
            case .HospitalVisit: return .HospitalVisit
            case .Immunization: return .Immunization
            case .LabResult: return .LaboratoryOrder
            case .Medication: return .Prescription
            case .Note: return .Notes
            case .SpecialAuthorityRequest: return .SpecialAuthorityDrug
            case .BcCancerScreening: return nil
            case .UnknownValue: return nil
            }
        }
        
        var getRecordFilterType: RecordsFilter.RecordType? {
            switch self {
            case .Covid19TestResult: return .Covid
            case .ClinicalDocument: return .ClinicalDocuments
            case .DiagnosticImaging: return .DiagnosticImaging
            case .HealthVisit: return .HeathVisits
            case .HospitalVisit: return .HospitalVisits
            case .Immunization: return .Immunizations
            case .LabResult: return .LabTests
            case .Medication: return .Medication
            case .Note: return .Notes
            case .SpecialAuthorityRequest: return .SpecialAuthorityDrugs
            case .BcCancerScreening: return nil
            case .UnknownValue: return nil
            }
        }
    }
    
    enum ServiceTypes: String, Codable {
        case OrganDonorRegistration = "organDonorRegistration"
        case HealthConnectRegistry = "healthConnectRegistry"
        case UnknownValue = "UnknownValue"
    }
    
    let datasets: [DataSetValues]
    let dependentDatasets: [DataSetValues]
    let services: [ServiceTypes]
    
    func contains(dataset: DataSetValues? = nil, dependentDataset: DataSetValues? = nil, service: ServiceTypes? = nil) -> Bool {
        if let dataset = dataset, self.datasets.contains(dataset) {
            return true
        }
        if let dependentDataset = dependentDataset, self.dependentDatasets.contains(dependentDataset) {
            return true
        }
        if let service = service, self.services.contains(service) {
            return true
        }
        return false
    }
    
    static func convertToHealthRecordType(types: [DataSetValues]) -> [StorageService.HealthRecordType] {
        var recordTypes: [StorageService.HealthRecordType] = []
        
        for type in types {
            if let record = type.getHealthRecordType {
                recordTypes.append(record)
            }
        }
        // NOTE: Doing this manually here because it doesn't seem to be included in the list - should check with Aravind here if theres a bug - but I believe we should fetch this regardless - or perhaps only fetch if immunizations are enabled
        if !recordTypes.contains(.VaccineCard) {
            recordTypes.append(.VaccineCard)
        }
        return recordTypes
    }
    
    static func convertToFilterType(types: [DataSetValues]) -> [RecordsFilter.RecordType]  {
        var filterTypes: [RecordsFilter.RecordType]  = []
        
        for type in types {
            if let record = type.getRecordFilterType {
                filterTypes.append(record)
            }
        }
        return filterTypes
    }
    
}

extension MobileConfigurationResponseObject {
    func getEnabledTypes() -> EnabledTypes {
        let datasets = self.datasets.map { rawValue in
            if let data = EnabledTypes.DataSetValues.init(rawValue: rawValue) {
                return data
            } else {
                return EnabledTypes.DataSetValues.UnknownValue
            }
        }
        
        let dependentDatasets = self.dependentDatasets.map { rawValue in
            if let data = EnabledTypes.DataSetValues.init(rawValue: rawValue) {
                return data
            } else {
                return EnabledTypes.DataSetValues.UnknownValue
            }
        }
        
        let services = self.services.map { rawValue in
            if let data = EnabledTypes.ServiceTypes.init(rawValue: rawValue) {
                return data
            } else {
                return EnabledTypes.ServiceTypes.UnknownValue
            }
        }
        
        return EnabledTypes(datasets: datasets, dependentDatasets: dependentDatasets, services: services)
    }
}
