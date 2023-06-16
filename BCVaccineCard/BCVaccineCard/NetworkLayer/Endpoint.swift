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
    func vaccineCardPublic(base url: URL) -> URL
    func vaccineCardAuthenticated(base url: URL) -> URL
    func termsOfService(base url: URL) -> URL
    func patientDetails(base url: URL, hdid: String) -> URL
    func comments(base url: URL, hdid: String) -> URL
    func clinicalDocumentPDF(fileID: String, base url: URL, hdid: String) -> URL
    func labTestPDF(base url: URL, reportID: String) -> URL
    func validateProfile(base url: URL, hdid: String) -> URL
    func userProfile(base url: URL, hdid: String) -> URL
    func listOfDependents(base url: URL, hdid: String) -> URL
    func deleteDependent(base url: URL, dependentHdid: String, guardian: String) -> URL
    func feedback(base url: URL, hdid: String) -> URL
    func notifcations(base url: URL, hdid: String) -> URL
    func notes(base url: URL, hdid: String) -> URL
}

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
    
    func medicationRequest(base url: URL, hdid: String) -> URL {
        medicationServiceBaseURL(base: url).appendingPathComponent("MedicationRequest").appendingPathComponent(hdid)
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
    
    func vaccineCardPublic(base url: URL) -> URL {
        immunizationBaseUrl(base: url).appendingPathComponent("PublicVaccineStatus")
    }
    
    func vaccineCardAuthenticated(base url: URL) -> URL {
        immunizationBaseUrl(base: url).appendingPathComponent("AuthenticatedVaccineStatus")
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
    
    // MARK: Notes
    func notes(base url: URL, hdid: String) -> URL {
        noteBase(base: url).appendingPathComponent(hdid)
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
    
    // MARK: Feedback
    
    func feedback(base url: URL, hdid: String) -> URL {
        return gatewayAPIService(base: url).appendingPathComponent("UserFeedback").appendingPathComponent(hdid)
    }
    
    // MARK: User
    func userProfileBase(base url: URL) -> URL {
        return gatewayAPIService(base: url).appendingPathComponent("UserProfile")
    }
    
    func noteBase(base url: URL) -> URL {
        return gatewayAPIService(base: url).appendingPathComponent("Note")
    }
    
    func patientDataBase(base url: URL) -> URL {
        return patientServiceBaseURL(base: url).appendingPathComponent("PatientData")
    }
    
    func patientData(base url: URL, hdid: String) -> URL {
        return patientDataBase(base: url).appendingPathComponent(hdid)
    }
    
    func patientDataPDF(base url: URL, hdid: String, fileID: String) -> URL {
        return patientData(base: url, hdid: hdid).appendingPathComponent("file").appendingPathComponent(fileID)
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
    
    // Notifications
    func notifcations(base url: URL, hdid: String) -> URL {
        return gatewayAPIService(base: url)
            .appendingPathComponent("Notification")
            .appendingPathComponent(hdid)
    }
    
    func deleteNotifcations(base url: URL, hdid: String, notificationID: String) -> URL {
        return gatewayAPIService(base: url)
            .appendingPathComponent("Notification")
            .appendingPathComponent(hdid)
            .appendingPathComponent(notificationID)
    }
    
}
