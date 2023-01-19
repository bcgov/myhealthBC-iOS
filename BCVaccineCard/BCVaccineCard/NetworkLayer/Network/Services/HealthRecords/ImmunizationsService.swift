//
//  ImmunizationsService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-31.
//

import Foundation

typealias immunizationsResponse = AuthenticatedImmunizationsResponseObject

struct ImmnunizationsService {
    
    let network: Network
    let authManager: AuthManager
    private let maxRetry = Constants.NetworkRetryAttempts.maxRetry
    private let retryIn = Constants.NetworkRetryAttempts.retryIn
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([Immunization])->Void) {
        network.addLoader(message: .FetchingRecords)
        fetch(for: patient, currentAttempt: 0) { result in
            guard let response = result else {
                network.removeLoader()
                return completion([])
            }
            store(immunizations: response, for: patient, completion: { result in
                network.removeLoader()
                return completion(result)
            })
        }
    }
    
    // MARK: Store
    private func store(immunizations response: immunizationsResponse,
                       for patient: Patient,
                       completion: @escaping ([Immunization])->Void
    ) {
        guard let payload = response.resourcePayload else { return completion([]) }
        StorageService.shared.deleteAllRecords(in: patient.immunizationArray)
        let stored = StorageService.shared.storeImmunizations(patient: patient, in: payload, authenticated: false)
        return completion(stored)
    }
    
}

// MARK: Network requests
extension ImmnunizationsService {
    private func fetch(for patient: Patient, currentAttempt: Int, completion: @escaping(_ response: immunizationsResponse?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else {
            return completion(nil)
        }
        
        guard currentAttempt < maxRetry else {
            network.showToast(message: .fetchRecordError, style: .Warn)
            return completion(nil)
        }
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, immunizationsResponse>(url: endpoints.getAuthenticatedImmunizations,
                                                                                 type: .Get,
                                                                                 parameters: parameters,
                                                                                 encoder: .urlEncoder,
                                                                                 headers: headers)
            { result in
                
                let shouldRetry = result?.resourcePayload?.loadState?.refreshInProgress
                if  shouldRetry == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryIn)) {
                        return fetch(for: patient, currentAttempt: currentAttempt + 1, completion: completion)
                    }
                } else if (result?.resourcePayload) != nil {
                    // return result
                    return completion(result)
                } else {
                    return completion(nil)
                }
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: .fetchRecordError, style: .Warn)
                    break
                }
                
            }
            
            network.request(with: requestModel)
        }
    }
}
