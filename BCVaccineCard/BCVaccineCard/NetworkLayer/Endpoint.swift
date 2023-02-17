//
//  UrlAccessor.swift
//  BCVaccineCard
// https://hg-dev.api.gov.bc.ca/api/laboratoryservice/swagger/index.html
//  Created by Connor Ogilvie on 2021-10-08.
// https://dev.healthgateway.gov.bc.ca/swagger/index.html

import Foundation

/// This accessor helps accessing all the endpoints being used in the app.
protocol EndpointsAccessor {
    func clinicalDocuments(base url: URL, hdid: String) -> URL
    func hospitalVisits(base url: URL, hdid: String) -> URL
    func laboratoryOrders(base url: URL) -> URL
    func covidTestResults(base url: URL) -> URL
    func immunizations(base url: URL) -> URL
    func medicationStatement(base url: URL, hdid: String) -> URL
    func healthVisits(base url: URL, hdid: String) -> URL
    func communication(base url: URL) -> URL
    ////
    func vaccineCard(base url: URL) -> URL
//    var getAuthenticatedVaccineCard: URL { get }
    func termsOfService(base url: URL) -> URL
    func patientDetails(base url: URL, hdid: String) -> URL
    func comments(base url: URL, hdid: String) -> URL
    func clinicalDocumentPDF(fileID: String, base url: URL, hdid: String) -> URL
    func labTestPDF(base url: URL, reportID: String) -> URL
    func validateProfile(base url: URL, hdid: String) -> URL
    func userProfile(base url: URL, hdid: String) -> URL
    func listOfDependents(base url: URL, hdid: String) -> URL
    func deleteDependent(base url: URL, dependentHdid: String, guardian: String) -> URL
    ////
//    var getBaseURL: URL { get }
//    var getVaccineCard: URL { get }
//    var getTestResults: URL { get }
//    var getAuthenticatedVaccineCard: URL { get }
//    var getAuthenticatedTestResults: URL { get }
//    var getAuthenticatedLaboratoryOrders: URL { get }
//    var getAuthenticatedImmunizations: URL { get }
//    var getTermsOfService: URL { get }
//    var communicationsMobile: URL { get }
//    var throttleHG: URL { get }
//    func getAuthenticatedPatientDetails(hdid: String) -> URL
//    func getAuthenticatedMedicationStatement(hdid: String) -> URL
//    func getAuthenticatedMedicationRequest(hdid: String) -> URL
//    func getAuthenticatedHealthVisits(hdid: String) -> URL
//    func getAuthenticatedHospitalVisits(hdid: String) -> URL
//    func authenticatedComments(hdid: String) -> URL
//    func authenticatedClinicalDocuments(hdid: String) -> URL
//    func authenticatedClinicalDocumentPDF(hdid: String, fileID: String) -> URL
//    func getAuthenticatedLabTestPDF(repordId: String) -> URL
//    func validateProfile(hdid: String) -> URL
//    func userProfile(hdid: String) -> URL
//    func listOfDependents(hdid: String) -> URL
//    func deleteDependent(dependentHdid: String, guardian: String) -> URL
}
//
//struct UrlAccessor {
//    #if PROD
////    let baseUrl = URL(string: "https://hg.api.gov.bc.ca/")!
//    static let mobileConfigURL = URL(string: "https://healthgateway.gov.bc.ca/mobileconfiguration")!
////    let webClientURL = URL(string: "https://healthgateway.gov.bc.ca/")!
////    let fallbackBaseUrl = URL(string: "https://healthgateway.gov.bc.ca/")!
//    let baseURL = BaseURLWorker.shared.baseURL ?? URL(string: "https://healthgateway.gov.bc.ca/")!
//    #elseif TEST
//    static let mobileConfigURL = URL(string: "https://test.healthgateway.gov.bc.ca/mobileconfiguration")!
//    let baseURL = BaseURLWorker.shared.baseURL ?? URL(string: "https://test.healthgateway.gov.bc.ca/")!
//    #elseif DEV
////    let baseUrl = URL(string: "https://hg-dev.api.gov.bc.ca/")!
//    static let mobileConfigURL = URL(string: "https://dev.healthgateway.gov.bc.ca/mobileconfiguration")!
////    let webClientURL = URL(string: "https://dev.healthgateway.gov.bc.ca/")!
////    let fallbackBaseUrl = URL(string: "https://dev.healthgateway.gov.bc.ca/")!
//    let baseURL = BaseURLWorker.shared.baseURL ?? URL(string: "https://dev.healthgateway.gov.bc.ca/")!
//    // NOTE: For terms of service builds, please use mock endpoint
//    // let baseUrl = URL(string: "https://mock.healthgateway.gov.bc.ca/")!
//    #endif
//    
//    private var immunizationBaseUrl: URL {
//        return baseURL.appendingPathComponent("api/immunizationservice")
//    }
//    
//    private var laboratoryServiceBaseURL: URL {
//        return baseURL.appendingPathComponent("api/laboratoryservice")
//    }
//    
//    private var patientServiceBaseURL: URL {
//        return baseURL.appendingPathComponent("api/patientservice")
//    }
//    
//    private var medicationServiceBaseURL: URL {
//        return baseURL.appendingPathComponent("api/medicationservice")
//    }
//    
//    private var encounterServiceBaseURL: URL {
//        return baseURL.appendingPathComponent("api/encounterservice")
//    }
//    
//    private var clinicaldocumentserviceBaseURL: URL {
//        return baseURL.appendingPathComponent("api/clinicaldocumentservice")
//    }
//
//}
//
//extension UrlAccessor: EndpointsAccessor {
//    
//    var getBaseURL: URL {
//        return UrlAccessor.mobileConfigURL
//    }
//    
//    var getVaccineCard: URL {
//        return self.immunizationBaseUrl.appendingPathComponent("PublicVaccineStatus")
//    }
//    
//    var getTestResults: URL {
//        return self.laboratoryServiceBaseURL.appendingPathComponent("PublicLaboratory/CovidTests")
//    }
//    
//    var getAuthenticatedVaccineCard: URL {
//        return self.immunizationBaseUrl.appendingPathComponent("AuthenticatedVaccineStatus")
//    }
//    
//    var getAuthenticatedTestResults: URL {
//        return self.laboratoryServiceBaseURL.appendingPathComponent("Laboratory/Covid19Orders")
//    }
//    
//    var getAuthenticatedLaboratoryOrders: URL {
//        return self.laboratoryServiceBaseURL.appendingPathComponent("Laboratory/LaboratoryOrders")
//    }
//    
//    var getAuthenticatedImmunizations: URL {
//        return self.immunizationBaseUrl.appendingPathComponent("Immunization")
//    }
//    
//    var getTermsOfService: URL {
//        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile/termsofservice")
//    }
//    
//    var throttleHG: URL {
////        return self.baseURL.appendingPathComponent("api/gatewayapiservice/MobileConfiguration")
//        return UrlAccessor.mobileConfigURL
//    }
//    
//    var communicationsMobile: URL {
//        return self.baseURL.appendingPathComponent("api/gatewayapiservice/Communication/Mobile")
////        return self.baseURL.appendingPathComponent("api/gatewayapiservice/Communication/Banner")
//    }
//    
//    func getAuthenticatedPatientDetails(hdid: String) -> URL {
//        return self.patientServiceBaseURL.appendingPathComponent("Patient").appendingPathComponent(hdid)
//    }
//    
//    func getAuthenticatedMedicationStatement(hdid: String) -> URL {
//        return self.medicationServiceBaseURL.appendingPathComponent("MedicationStatement").appendingPathComponent(hdid)
//    }
//    
//    func getAuthenticatedMedicationRequest(hdid: String) -> URL {
//        return self.medicationServiceBaseURL.appendingPathComponent("MedicationRequest").appendingPathComponent(hdid)
//    }
//    
//    func getAuthenticatedHealthVisits(hdid: String) -> URL {
//        return self.encounterServiceBaseURL.appendingPathComponent("Encounter").appendingPathComponent(hdid)
//    }
//    
//    func getAuthenticatedHospitalVisits(hdid: String) -> URL {
//        return self.encounterServiceBaseURL.appendingPathComponent("Encounter").appendingPathComponent("HospitalVisit").appendingPathComponent(hdid)
//    }
//    
//    func authenticatedComments(hdid: String) -> URL {
//        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Comment")
//    }
//    
//    func authenticatedClinicalDocuments(hdid: String) -> URL {
//        return self.clinicaldocumentserviceBaseURL.appendingPathComponent("ClinicalDocument").appendingPathComponent(hdid)
//    }
//    
//    func authenticatedClinicalDocumentPDF(hdid: String, fileID: String) -> URL {
//        return self.authenticatedClinicalDocuments(hdid: hdid).appendingPathComponent("file").appendingPathComponent(fileID)
//    }
//    
//    func getAuthenticatedLabTestPDF(repordId: String) -> URL {
//        return self.laboratoryServiceBaseURL.appendingPathComponent("Laboratory").appendingPathComponent(repordId).appendingPathComponent("Report")
//    }
//    
//    func validateProfile(hdid: String) -> URL {
//        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Validate")
//    }
//    
//    func userProfile(hdid: String) -> URL {
//        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(hdid)
//    }
//    
//    func listOfDependents(hdid: String) -> URL {
//        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(hdid).appendingPathComponent("Dependent")
//    }
//    
//    func deleteDependent(dependentHdid: String, guardian: String) -> URL {
//        return self.baseURL.appendingPathComponent("api/gatewayapiservice/UserProfile").appendingPathComponent(guardian).appendingPathComponent("Dependent").appendingPathComponent(dependentHdid)
//    }
//}

struct UrlAccessor: EndpointsAccessor {
    // MARK: Services
    private func gatewayAPIService(base url: URL) -> URL {
        return url.appendingPathComponent("api/gatewayapiservice")
    }
    
    private func patientServiceBaseURL(base url: URL) -> URL {
        return url.appendingPathComponent("api/patientservice")
    }
    
    private func clinicalDocumentService(base url: URL) -> URL {
        return url.appendingPathComponent("api/clinicaldocumentservice")
    }
    
    private func encounterService(base url: URL) -> URL {
        return url.appendingPathComponent("api/encounterservice")
    }
    
    private func laboratoryService(base url: URL) -> URL {
        return url.appendingPathComponent("api/laboratoryservice")
    }
    
    private func immunizationBaseUrl(base url: URL) -> URL {
        return url.appendingPathComponent("api/immunizationservice")
    }
    
    private func medicationServiceBaseURL(base url: URL) -> URL {
        return url.appendingPathComponent("api/medicationservice")
    }
    
    // MARK: Records
    func clinicalDocuments(base url: URL, hdid: String) -> URL {
        clinicalDocumentService(base: url).appendingPathComponent("ClinicalDocument").appendingPathComponent(hdid)
    }
    
    func hospitalVisits(base url: URL, hdid: String) -> URL {
        encounterService(base: url).appendingPathComponent("Encounter").appendingPathComponent("HospitalVisit").appendingPathComponent(hdid)
    }
    
    func healthVisits(base url: URL, hdid: String) -> URL {
        encounterService(base: url).appendingPathComponent("Encounter").appendingPathComponent(hdid)
    }
    
    func medicationStatement(base url: URL, hdid: String) -> URL {
        medicationServiceBaseURL(base: url).appendingPathComponent("MedicationStatement").appendingPathComponent(hdid)
    }
    
    func laboratoryOrders(base url: URL) -> URL {
        laboratoryService(base: url).appendingPathComponent("Laboratory/LaboratoryOrders")
    }
    
    func covidTestResults(base url: URL) -> URL {
        laboratoryService(base: url).appendingPathComponent("Laboratory/Covid19Orders")
    }
    
    func immunizations(base url: URL) -> URL {
        immunizationBaseUrl(base: url).appendingPathComponent("Immunization")
    }
    
    func communication(base url: URL) -> URL {
        gatewayAPIService(base: url).appendingPathComponent("Communication/Mobile")
    }
    
    func vaccineCard(base url: URL) -> URL {
        immunizationBaseUrl(base: url).appendingPathComponent("PublicVaccineStatus")
    }
    
    // MARK: PDF
    func clinicalDocumentPDF(fileID: String, base url: URL, hdid: String) -> URL {
        clinicalDocuments(base: url, hdid: hdid)
            .appendingPathComponent("file")
            .appendingPathComponent(fileID)
    }
    
    func labTestPDF(base url: URL, reportID: String) -> URL {
        laboratoryService(base: url)
            .appendingPathComponent("Laboratory")
            .appendingPathComponent(reportID)
            .appendingPathComponent("Report")
    }
    
    // MARK: Comments
    func comments(base url: URL, hdid: String) -> URL {
        userProfile(base: url, hdid: hdid).appendingPathComponent("Comment")
    }
    
    // MARK: Dependents
    func listOfDependents(base url: URL, hdid: String) -> URL {
        userProfile(base: url, hdid: hdid).appendingPathComponent("Dependent")
    }
    
    func deleteDependent(base url: URL, dependentHdid: String, guardian: String) -> URL {
        userProfileBase(base: url)
            .appendingPathComponent(guardian)
            .appendingPathComponent("Dependent")
            .appendingPathComponent(dependentHdid)
    }
    
    // MARK: User
    func userProfileBase(base url: URL) -> URL {
        return gatewayAPIService(base: url).appendingPathComponent("UserProfile")
    }
    
    func userProfile(base url: URL, hdid: String) -> URL {
        return userProfileBase(base: url).appendingPathComponent(hdid)
    }
    
    func validateProfile(base url: URL, hdid: String) -> URL {
        userProfile(base: url, hdid: hdid).appendingPathComponent("Validate")
    }
    
    func termsOfService(base url: URL) -> URL {
        return userProfileBase(base: url).appendingPathComponent("termsofservice")
    }
    
    func patientDetails(base url: URL, hdid: String) -> URL {
        patientServiceBaseURL(base: url)
            .appendingPathComponent("Patient")
            .appendingPathComponent(hdid)
    }
    
}
