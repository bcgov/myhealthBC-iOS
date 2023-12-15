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
        let shouldFetch = patient.isDependent() ? (Defaults.enabledTypes?.contains(dependentDataset: .ClinicalDocument) == true) : (Defaults.enabledTypes?.contains(dataset: .ClinicalDocument) == true)
        if !shouldFetch {return completion([])}
        Logger.log(string: "Fetching ClinicalDocument records for \(patient.name)", type: .Network)
        network.addLoader(message: .SyncingRecords, caller: .ClinicalDocumentService_fetchAndStore)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader(caller: .ClinicalDocumentService_fetchAndStore)
                return completion(nil)
            }
            
            store(HopotalVisits: response, for: patient, completion: { result in
                network.removeLoader(caller: .ClinicalDocumentService_fetchAndStore)
                return completion(result)
            })
        }
    }
    
    // MARK: Store
    // TODO: Amir - clean up property name, should be 'clinicalDocuments' and not 'HopotalVisits', just for clarity sake
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
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid, apiVersion: "1")
            
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
                default:
                    break
                }
                
            }
            Logger.log(string: "Network ClinicalDocument initiated", type: .Network)
            network.request(with: requestModel)
        }
    }
}
