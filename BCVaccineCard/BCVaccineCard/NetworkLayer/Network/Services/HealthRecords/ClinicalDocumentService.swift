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
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([ClinicalDocument]?)->Void) {
        if !HealthRecordConstants.enabledTypes.contains(.clinicalDocument) {return completion([])}
        Logger.log(string: "Fetching ClinicalDocument records for \(patient.name)", type: .Network)
        network.addLoader(message: .SyncingRecords)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader()
                return completion(nil)
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
        Logger.log(string: "Storing ClinicalDocument records for \(patient.name)", type: .Network)
        StorageService.shared.deleteAllRecords(in: patient.clinicalDocumentsArray)
        let stored = StorageService.shared.storeClinicalDocuments(patient: patient, objects: response, authenticated: true)
        return completion(stored)
    }
    
}

// MARK: Network requests
extension ClinicalDocumentService {
   
    private func fetch(for patient: Patient, completion: @escaping(_ response: [ClinicalDocumentResponse]?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedClinicalDocumentResponseObject>(url: endpoints.clinicalDocuments(base: baseURL, hdid: hdid),
                                                                                                       type: .Get,
                                                                                                       parameters: parameters,
                                                                                                       encoder: .urlEncoder,
                                                                                                       headers: headers)
            { result in
                Logger.log(string: "Network ClinicalDocument Result received", type: .Network)
                if let docs = result?.resourcePayload {
                    // return result
                    return completion(docs)
                } else {
                    return completion(nil)
                }
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    break
                }
                
            }
            Logger.log(string: "Network ClinicalDocument initiated", type: .Network)
            network.request(with: requestModel)
        }
    }
}
