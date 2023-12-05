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
