//
//  DependentService.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-10-18.
//

import Foundation

struct DependentService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchDependents(completion: @escaping(_ dependentResponse: DependentResponse?) -> Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else { return }
        if NetworkConnection.shared.hasConnection {
            BaseURLWorker.shared.setBaseURL {
                guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
                
                let headers = [
                    Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                    Constants.AuthenticationHeaderKeys.hdid: hdid
                ]
                
                let requestModel = NetworkRequest<DefaultParams, DependentResponse>(url: endpoints.listOfDependents(hdid: hdid), type: .Get, parameters: nil, headers: headers) { result in
                    completion(result)
                }
                
                network.request(with: requestModel)
            }
        }
    }
    
    public func addDependent(object: PostDependent, completion: @escaping(_ dependentResponse: DependentResponse?) -> Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else { return }
        if NetworkConnection.shared.hasConnection {
            BaseURLWorker.shared.setBaseURL {
                guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
                
                let headers = [
                    Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                    Constants.AuthenticationHeaderKeys.hdid: hdid
                ]
                
                let requestModel = NetworkRequest<PostDependent, DependentResponse>(url: endpoints.listOfDependents(hdid: hdid), type: .Post, parameters: object, headers: headers) { result in
                    completion(result)
                }
                
                network.request(with: requestModel)
            }
        }
    }
    
}
