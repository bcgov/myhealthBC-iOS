//
//  UrlAccessor.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-08.
// https://dev.healthgateway.gov.bc.ca/swagger/index.html

import Foundation

/// This accessor helps accessing all the endpoints being used in the app.
protocol EndpointsAccessor {
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
    func getAuthenticatedLaboratoryOrderPDF(repordId: String) -> URL
    func validateProfile(hdid: String) -> URL
    func userProfile(hdid: String) -> URL
}

struct UrlAccessor {
    #if PROD
    let baseUrl = URL(string: "https://healthgateway.gov.bc.ca/")!
    #elseif DEV
    let baseUrl = URL(string: "https://dev.healthgateway.gov.bc.ca/")!
    // NOTE: For terms of service builds, please use mock endpoint
    // let baseUrl = URL(string: "https://mock.healthgateway.gov.bc.ca/")!
    #endif
    
    private var immunizationBaseUrl: URL {
        return self.baseUrl.appendingPathComponent("api/immunizationservice")
    }
    
    private var laboratoryServiceBaseURL: URL {
        return self.baseUrl.appendingPathComponent("api/laboratoryservice")
    }
    
    private var patientServiceBaseURL: URL {
        return self.baseUrl.appendingPathComponent("api/patientservice")
    }
    
    private var medicationServiceBaseURL: URL {
        return self.baseUrl.appendingPathComponent("api/medicationservice")
    }

}

extension UrlAccessor: EndpointsAccessor {
    
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
        return self.baseUrl.appendingPathComponent("v1/api/UserProfile/termsofservice")
    }
    
    var throttleHG: URL {
        return self.baseUrl.appendingPathComponent("v1/api/MobileConfiguration")
    }
    
    func getAuthenticatedPatientDetails(hdid: String) -> URL {
        return self.patientServiceBaseURL.appendingPathComponent("v1/api/Patient").appendingPathComponent(hdid)
    }
    
    func getAuthenticatedMedicationStatement(hdid: String) -> URL {
        return self.medicationServiceBaseURL.appendingPathComponent("v1/api/MedicationStatement").appendingPathComponent(hdid)
    }
    
    func authenticatedComments(hdid: String) -> URL {
        return self.baseUrl.appendingPathComponent("v1/api/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Comment")
    }
    
    func getAuthenticatedLaboratoryOrderPDF(repordId: String) -> URL {
        return self.laboratoryServiceBaseURL.appendingPathComponent("v1/api/Laboratory").appendingPathComponent(repordId).appendingPathComponent("Report")
    }
    
    func validateProfile(hdid: String) -> URL {
        return self.baseUrl.appendingPathComponent("v1/api/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Validate")
    }
    
    func userProfile(hdid: String) -> URL {
        return self.baseUrl.appendingPathComponent("v1/api/UserProfile").appendingPathComponent(hdid)
    }
}

