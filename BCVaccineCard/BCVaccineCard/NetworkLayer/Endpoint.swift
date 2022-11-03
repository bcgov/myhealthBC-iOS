//
//  UrlAccessor.swift
//  BCVaccineCard
// https://hg-dev.api.gov.bc.ca/api/laboratoryservice/swagger/index.html
//  Created by Connor Ogilvie on 2021-10-08.
// https://dev.healthgateway.gov.bc.ca/swagger/index.html

import Foundation

/// This accessor helps accessing all the endpoints being used in the app.
protocol EndpointsAccessor {
    var getBaseURL: URL { get }
    var getVaccineCard: URL { get }
    var getTestResults: URL { get }
    var getAuthenticatedVaccineCard: URL { get }
    var getAuthenticatedTestResults: URL { get }
    var getAuthenticatedLaboratoryOrders: URL { get }
    var getAuthenticatedImmunizations: URL { get }
    var getTermsOfService: URL { get }
    var communicationsMobile: URL { get }
    var throttleHG: URL { get }
    func getAuthenticatedPatientDetails(hdid: String) -> URL
    func getAuthenticatedMedicationStatement(hdid: String) -> URL
    func getAuthenticatedMedicationRequest(hdid: String) -> URL
    func getAuthenticatedHealthVisits(hdid: String) -> URL
    func authenticatedComments(hdid: String) -> URL
    func getAuthenticatedLabTestPDF(repordId: String) -> URL
    func validateProfile(hdid: String) -> URL
    func userProfile(hdid: String) -> URL
    func listOfDependents(hdid: String) -> URL
}

struct UrlAccessor {
    #if PROD
//    let baseUrl = URL(string: "https://hg.api.gov.bc.ca/")!
    static let mobileConfigURL = URL(string: "https://healthgateway.gov.bc.ca/mobileconfiguration")!
//    let webClientURL = URL(string: "https://healthgateway.gov.bc.ca/")!
//    let fallbackBaseUrl = URL(string: "https://healthgateway.gov.bc.ca/")!
    let baseURL = BaseURLWorker.shared.baseURL ?? URL(string: "https://healthgateway.gov.bc.ca/")!
    #elseif TEST
    static let mobileConfigURL = URL(string: "https://test.healthgateway.gov.bc.ca/mobileconfiguration")!
    let baseURL = BaseURLWorker.shared.baseURL ?? URL(string: "https://test.healthgateway.gov.bc.ca/")!
    #elseif DEV
//    let baseUrl = URL(string: "https://hg-dev.api.gov.bc.ca/")!
    static let mobileConfigURL = URL(string: "https://dev.healthgateway.gov.bc.ca/mobileconfiguration")!
//    let webClientURL = URL(string: "https://dev.healthgateway.gov.bc.ca/")!
//    let fallbackBaseUrl = URL(string: "https://dev.healthgateway.gov.bc.ca/")!
    let baseURL = BaseURLWorker.shared.baseURL ?? URL(string: "https://dev.healthgateway.gov.bc.ca/")!
    // NOTE: For terms of service builds, please use mock endpoint
    // let baseUrl = URL(string: "https://mock.healthgateway.gov.bc.ca/")!
    #endif
    
    private var immunizationBaseUrl: URL {
        return baseURL.appendingPathComponent("api/immunizationservice")
    }
    
    private var laboratoryServiceBaseURL: URL {
        return baseURL.appendingPathComponent("api/laboratoryservice")
    }
    
    private var patientServiceBaseURL: URL {
        return baseURL.appendingPathComponent("api/patientservice")
    }
    
    private var medicationServiceBaseURL: URL {
        return baseURL.appendingPathComponent("api/medicationservice")
    }
    
    private var encounterServiceBaseURL: URL {
        return baseURL.appendingPathComponent("api/encounterservice")
    }

}

extension UrlAccessor: EndpointsAccessor {
    
    var getBaseURL: URL {
        return UrlAccessor.mobileConfigURL
    }
    
    var getVaccineCard: URL {
        return self.immunizationBaseUrl.appendingPathComponent("PublicVaccineStatus")
    }
    
    var getTestResults: URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("PublicLaboratory/CovidTests")
    }
    
    var getAuthenticatedVaccineCard: URL {
        return self.immunizationBaseUrl.appendingPathComponent("AuthenticatedVaccineStatus")
    }
    
    var getAuthenticatedTestResults: URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("Laboratory/Covid19Orders")
    }
    
    var getAuthenticatedLaboratoryOrders: URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("Laboratory/LaboratoryOrders")
    }
    
    var getAuthenticatedImmunizations: URL {
        return self.immunizationBaseUrl.appendingPathComponent("Immunization")
    }
    
    var getTermsOfService: URL {
        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile/termsofservice")
    }
    
    var throttleHG: URL {
//        return self.baseURL.appendingPathComponent("api/gatewayapiservice/MobileConfiguration")
        return UrlAccessor.mobileConfigURL
    }
    
    var communicationsMobile: URL {
        return self.baseURL.appendingPathComponent("api/gatewayapiservice/Communication/Mobile")
//        return self.baseURL.appendingPathComponent("api/gatewayapiservice/Communication/Banner")
    }
    
    func getAuthenticatedPatientDetails(hdid: String) -> URL {
        return self.patientServiceBaseURL.appendingPathComponent("Patient").appendingPathComponent(hdid)
    }
    
    func getAuthenticatedMedicationStatement(hdid: String) -> URL {
        return self.medicationServiceBaseURL.appendingPathComponent("MedicationStatement").appendingPathComponent(hdid)
    }
    
    func getAuthenticatedMedicationRequest(hdid: String) -> URL {
        return self.medicationServiceBaseURL.appendingPathComponent("MedicationRequest").appendingPathComponent(hdid)
    }
    
    func getAuthenticatedHealthVisits(hdid: String) -> URL {
        return self.encounterServiceBaseURL.appendingPathComponent("Encounter").appendingPathComponent(hdid)
    }
    
    func authenticatedComments(hdid: String) -> URL {
        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Comment")
    }
    
    func getAuthenticatedLabTestPDF(repordId: String) -> URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("Laboratory").appendingPathComponent(repordId).appendingPathComponent("Report")
    }
    
    func validateProfile(hdid: String) -> URL {
        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Validate")
    }
    
    func userProfile(hdid: String) -> URL {
        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(hdid)
    }
    
    func listOfDependents(hdid: String) -> URL {
        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Dependent")
    }
    
    func deleteDependent(hdid: String, dependentHdid: String) -> URL {
        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Dependent").appendingPathComponent(dependentHdid)
    }
}

