//
//  VaccineCardService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-31.
//

import Foundation

typealias vaccineCardsResponse = GatewayVaccineCardResponse

struct VaccineCardService {
    
    let network: Network
    let authManager: AuthManager
    private let maxRetry = Constants.NetworkRetryAttempts.publicRetryMaxForTestResults
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStoreCovidProof(for dependent: Dependent, completion: @escaping (VaccineCard?)->Void) {
        fetchVaccineProofs(for: dependent, currentAttempt: 0) { result in
            guard let response = result else {
                return completion(nil)
            }
            store(VaccineCards: response, for: dependent, completion: completion)
        }
    }
    
                                                          
    private func store(VaccineCards: vaccineCardsResponse,
                       for dependent: Dependent,
                       completion: @escaping (VaccineCard?)->Void
    ) {
        guard let patient = dependent.info else { return completion(nil) }
        StorageService.shared.storeVaccineCard(from: VaccineCards, for: patient, manuallyAdded: false, completion: completion)
    }
    
}

// MARK: Network requests
extension VaccineCardService {
   
    private func fetchVaccineProofs(for dependent: Dependent, currentAttempt: Int, completion: @escaping(_ response: GatewayVaccineCardResponse?) -> Void) {
        
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
            
            let requestModel = NetworkRequest<HDIDParams, GatewayVaccineCardResponse>(url: endpoints.getAuthenticatedVaccineCard, type: .Get, parameters: parameters, headers: headers) { result in
                
                if result?.resourcePayload?.loaded == false,
                   let retryinMS = result?.resourcePayload?.retryin {
                    // retry if needed
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryinMS/1000)) {
                        fetchVaccineProofs(for: dependent, currentAttempt: currentAttempt + 1, completion: completion)
                    }
                    
                } else if let proofs = result?.resourcePayload {
                    // return result
                    return completion(result)
                } else {
                    // TODO: CONNOR: getting this error
                    // show error
                    return completion(nil)
                }
            }
            
            network.request(with: requestModel)
        }
    }
}
