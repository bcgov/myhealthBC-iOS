//
//  DependentService.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-10-18.
//

import Foundation
import JOSESwift
import BCVaccineValidator

extension Network {
    func addLoader() {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.incrementLoader(message: .SyncingRecords)
            }
        }
    }
    
    func removeLoader() {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.decrementLoader()
            }
        }
    }
}

struct DependentService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchDependents(for patient: Patient, completion: @escaping([Patient]) -> Void) {
        network.addLoader()
        fetchDependentNetworkRequest { dependentResponse in
            guard let dependentResponse = dependentResponse, let payload = dependentResponse.resourcePayload else {
                network.removeLoader()
                return completion([])
            }
            network.removeLoader()
            let result = payload.compactMap({$0.dependentInformation})
            StorageService.shared.deleteDependents(for: patient)
            StorageService.shared.store(dependents: result, for: patient, completion: { result in
                network.removeLoader()
                completion(result)
            })
            
        }
    }
    
    private func fetchDependentNetworkRequest(completion: @escaping(_ dependentResponse: DependentsResponse?) -> Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return completion(nil)}
        guard NetworkConnection.shared.hasConnection else {return completion(nil)}
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            
            let requestModel = NetworkRequest<DefaultParams, DependentsResponse>(url: endpoints.listOfDependents(hdid: hdid), type: .Get, parameters: nil, headers: headers) { result in
                completion(result)
            }
            
            network.request(with: requestModel)
        }

    }
    
    public func addDependent(for patient: Patient, object: PostDependent, completion: @escaping(Patient?) -> Void) {
        network.addLoader()
        addDependentNetworkRequest(object: object) { dependentResponse in
            network.removeLoader()
            guard let dependentResponse = dependentResponse, let payload = dependentResponse.resourcePayload, let info = payload.dependentInformation else {
                network.removeLoader()
                return completion(nil)
            }
            
            StorageService.shared.store(dependents: [info], for: patient, completion: { result in
                guard !result.isEmpty else {return completion(nil)}
                completion(result.first)
            })
        }
    }
    
//    public func deleteDependent(patient: Patient, completion: @escaping(Bool) -> Void) {
//        guard let token = authManager.authToken, let hdid = authManager.hdid else {return completion(false)}
//        guard NetworkConnection.shared.hasConnection else {return completion(false)}
//        
//        let object = PostDependent(firstName: <#T##String#>, lastName: <#T##String#>, dateOfBirth: <#T##String#>, phn: <#T##String#>)
//        BaseURLWorker.shared.setBaseURL {
//            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
//            
//            let headers = [
//                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
//                Constants.AuthenticationHeaderKeys.hdid: hdid
//            ]
//            
//            let requestModel = NetworkRequest<PostDependent, AddDependentResponse>(url: endpoints.listOfDependents(hdid: hdid), type: .Post, parameters: object, headers: headers) { result in
//                completion(result)
//            }
//            
//            network.request(with: requestModel)
//        }
//        
//    }
    
    private func addDependentNetworkRequest(object: PostDependent, completion: @escaping(_ dependentResponse: AddDependentResponse?) -> Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return completion(nil)}
        guard NetworkConnection.shared.hasConnection else {return completion(nil)}
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            
            let requestModel = NetworkRequest<PostDependent, AddDependentResponse>(url: endpoints.listOfDependents(hdid: hdid), type: .Post, parameters: object, headers: headers) { result in
                completion(result)
            }
            
            network.request(with: requestModel)
        }
    }

    
}
