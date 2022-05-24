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
    var getTermsOfService: URL { get }
    var throttleHG: URL { get }
    func getAuthenticatedPatientDetails(hdid: String) -> URL
    func getAuthenticatedMedicationStatement(hdid: String) -> URL
    func authenticatedComments(hdid: String) -> URL
    func getAuthenticatedLabTestPDF(repordId: String) -> URL
    func validateProfile(hdid: String) -> URL
    func userProfile(hdid: String) -> URL
}

struct UrlAccessor {
    #if PROD
//    let baseUrl = URL(string: "https://hg.api.gov.bc.ca/")!
    let mobileConfigURL = URL(string: "https://healthgateway.gov.bc.ca/mobileconfiguration")!
//    let webClientURL = URL(string: "https://healthgateway.gov.bc.ca/")!
//    let fallbackBaseUrl = URL(string: "https://healthgateway.gov.bc.ca/")!
    let baseURL = BaseURLWorker.shared.baseURL ?? URL(string: "https://healthgateway.gov.bc.ca/")!
    #elseif DEV
//    let baseUrl = URL(string: "https://hg-dev.api.gov.bc.ca/")!
    let mobileConfigURL = URL(string: "https://dev.healthgateway.gov.bc.ca/mobileconfiguration")!
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

}

extension UrlAccessor: EndpointsAccessor {
    
    var getBaseURL: URL {
        return mobileConfigURL
    }
    
    var getVaccineCard: URL {
        return self.immunizationBaseUrl.appendingPathComponent("v1/api/PublicVaccineStatus")
    }
    
    var getTestResults: URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("v1/api/PublicLaboratory/CovidTests")
    }
    
    var getAuthenticatedVaccineCard: URL {
        return self.immunizationBaseUrl.appendingPathComponent("v1/api/AuthenticatedVaccineStatus")
    }
    
    var getAuthenticatedTestResults: URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("v1/api/Laboratory/Covid19Orders")
    }
    
    var getAuthenticatedLaboratoryOrders: URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("v1/api/Laboratory/LaboratoryOrders")
    }
    
    var getTermsOfService: URL {
        return self.baseURL.appendingPathComponent("v1/api/UserProfile/termsofservice")
    }
    
    var throttleHG: URL {
        return self.baseURL.appendingPathComponent("v1/api/MobileConfiguration")
    }
    
    func getAuthenticatedPatientDetails(hdid: String) -> URL {
        return self.patientServiceBaseURL.appendingPathComponent("v1/api/Patient").appendingPathComponent(hdid)
    }
    
    func getAuthenticatedMedicationStatement(hdid: String) -> URL {
        return self.medicationServiceBaseURL.appendingPathComponent("v1/api/MedicationStatement").appendingPathComponent(hdid)
    }
    
    func authenticatedComments(hdid: String) -> URL {
        return self.baseURL.appendingPathComponent("v1/api/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Comment")
    }
    
    func getAuthenticatedLabTestPDF(repordId: String) -> URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("v1/api/Laboratory").appendingPathComponent(repordId).appendingPathComponent("Report")
    }
    
    func validateProfile(hdid: String) -> URL {
        return self.baseURL.appendingPathComponent("v1/api/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Validate")
    }
    
    func userProfile(hdid: String) -> URL {
        return self.baseURL.appendingPathComponent("v1/api/UserProfile").appendingPathComponent(hdid)
    }
}

