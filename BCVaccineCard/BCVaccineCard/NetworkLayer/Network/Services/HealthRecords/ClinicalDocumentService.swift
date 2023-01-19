//
//  ClinicalDocumentService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

typealias ClinicalDocumentResponse = AuthenticatedClinicalDocumentResponseObject.ClinicalDocument

struct ClinicalDocumentService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchPDF(for document: ClinicalDocument, patient: Patient, completion: @escaping (String?)->Void) {
        guard let fileId = document.fileID else {
            return completion(nil)
        }
        network.addLoader(message: .FetchingRecords)
        fetchPDF(fileID: fileId, patient: patient, completion: {response in
            network.removeLoader()
            return completion(response?.data)
        })
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([ClinicalDocument])->Void) {
        if !HealthRecordConstants.enabledTypes.contains(.clinicalDocument) {return completion([])}
        network.addLoader(message: .FetchingRecords)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader()
                return completion([])
            }
            
            store(HopotalVisits: response, for: patient, completion: { result in
                network.removeLoader()
                return completion(result)
            })
        }
    }
    
    // MARK: Store
    private func store(HopotalVisits response: [ClinicalDocumentResponse],
                       for patient: Patient,
                       completion: @escaping ([ClinicalDocument])->Void
    ) {
        StorageService.shared.deleteAllRecords(in: patient.clinicalDocumentsArray)
        let stored = StorageService.shared.storeClinicalDocuments(patient: patient, objects: response, authenticated: true)
        return completion(stored)
    }
    
}

// MARK: Network requests
extension ClinicalDocumentService {
    private func fetchPDF(fileID: String, patient: Patient, completion: @escaping(_ response: AuthenticatedPDFResponseObject.ResourcePayload?) -> Void) {
        guard let token = authManager.authToken,
              let hdid = patient .hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedPDFResponseObject>(url: endpoints.authenticatedClinicalDocumentPDF(hdid: hdid, fileID: fileID),
                                                                                          type: .Get,
                                                                                          parameters: parameters,
                                                                                          encoder: .urlEncoder,
                                                                                          headers: headers)
            { result in
                if let docs = result?.resourcePayload {
                    // return result
                    return completion(docs)
                } else {
                    return completion(nil)
                }
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: .fetchRecordError, style: .Warn)
                }
                
            }
            
            network.request(with: requestModel)
        }
    }
    
    private func fetch(for patient: Patient, completion: @escaping(_ response: [ClinicalDocumentResponse]?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient .hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedClinicalDocumentResponseObject>(url: endpoints.authenticatedClinicalDocuments(hdid: hdid),
                                                                                                       type: .Get,
                                                                                                       parameters: parameters,
                                                                                                       encoder: .urlEncoder,
                                                                                                       headers: headers)
            { result in
                if let docs = result?.resourcePayload {
                    // return result
                    return completion(docs)
                } else {
                    return completion(nil)
                }
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: .fetchRecordError, style: .Warn)
                }
                
            }
            
            network.request(with: requestModel)
        }
    }
}
