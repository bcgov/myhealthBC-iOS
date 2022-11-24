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
    private let maxRetry = Constants.NetworkRetryAttempts.publicRetryMaxForTestResults
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStoreImmunizations(for dependent: Dependent, completion: @escaping ([Immunization])->Void) {
        fetchImmunizations(for: dependent, currentAttempt: 0) { result in
            guard let response = result else {
                return completion([])
            }
            store(immunizations: response, for: dependent, completion: completion)
        }
    }
    
    // MARK: Store
    private func store(immunizations response: immunizationsResponse,
                       for dependent: Dependent,
                       completion: @escaping ([Immunization])->Void
    ) {
        guard let patient = dependent.info,
              let payload = response.resourcePayload
        else { return completion([]) }
        let stored = StorageService.shared.storeImmunizations(patient: patient, in: payload, authenticated: false)
        // TODO: Connor Test stored
        return completion(stored)
    }
    
}

// MARK: Network requests
extension ImmnunizationsService {
    private func fetchImmunizations(for dependent: Dependent, currentAttempt: Int, completion: @escaping(_ response: AuthenticatedImmunizationsResponseObject?) -> Void) {
        
        guard currentAttempt < maxRetry,
              let token = authManager.authToken,
              let hdid = dependent.info?.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedImmunizationsResponseObject>(url: endpoints.getAuthenticatedImmunizations, type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers) { result in
                
                if let immunizations = result?.resourcePayload {
                    // return result
                    return completion(result)
                } else {
                    // show error
                    return completion(nil)
                }
            }
            
            network.request(with: requestModel)
        }
    }
}
