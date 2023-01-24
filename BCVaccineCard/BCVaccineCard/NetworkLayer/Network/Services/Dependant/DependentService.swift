//
//  DependentService.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-10-18.
//

import Foundation
import JOSESwift
import BCVaccineValidator

struct DependentService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
  
    public func fetchDependents(for patient: Patient, completion: @escaping([Dependent]) -> Void) {
        network.addLoader(message: .FetchingRecords)
        fetchDependentNetworkRequest { dependentResponse in
            guard let dependentResponse = dependentResponse, let payload = dependentResponse.resourcePayload else {
                network.removeLoader()
                return completion([])
            }
            network.removeLoader()
            StorageService.shared.deleteDependents(for: patient)
            StorageService.shared.store(dependents: payload, for: patient, completion: { result in
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
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: .fetchRecordError, style: .Warn)
                }
                
            }
            
            network.request(with: requestModel)
        }

    }
    
    public func addDependent(for patient: Patient, object: PostDependent, completion: @escaping(Dependent?) -> Void) {
        network.addLoader(message: .empty)
        addDependentNetworkRequest(object: object) { dependentResponse in
            network.removeLoader()
            guard let dependentResponse = dependentResponse,
                  let payload = dependentResponse.resourcePayload
            else {
                network.removeLoader()
                return completion(nil)
            }
            
            StorageService.shared.store(dependents: [payload], for: patient, completion: { result in
                guard !result.isEmpty else {return completion(nil)}
                completion(result.first)
            })
        }
    }
    
    public func delete(dependents: [Dependent], for guardian: Patient, completion: @escaping(Bool) -> Void) {
        deleteRemote(dependents: dependents, for: guardian) { success in
            guard success else {
                return completion(success)
            }
            StorageService.shared.delete(dependents: dependents, for: guardian)
            return completion(success)
        }
    }
    
    private func deleteRemote(dependents: [Dependent], for guardian: Patient, completion: @escaping(Bool) -> Void) {
        guard !dependents.isEmpty, let guardianHdid = AuthManager().hdid else {
            return completion(true)
        }
        var remaining = dependents
        guard let currentDependent = remaining.popLast() else {
            return completion(false)
        }
        
        guard
            let remoteObject = currentDependent.toRemote(),
            let dependentInfo = currentDependent.info,
            let dependentHdid = dependentInfo.hdid
        else {
            return deleteRemote(dependents: remaining, for: guardian, completion: completion)
        }
        guard let token = authManager.authToken else {return completion(false)}
        guard NetworkConnection.shared.hasConnection else {return completion(false)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(false) }

            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: guardianHdid,
                Constants.AuthenticationHeaderKeys.dependentHdid: dependentHdid
            ]

            let requestModel = NetworkRequest<RemoteDependent, AddDependentResponse>(url: endpoints.deleteDependent(dependentHdid: dependentHdid, guardian: guardianHdid), type: .Delete, parameters: remoteObject, headers: headers) { result in
                guard result != nil else {return completion(false)}
                return deleteRemote(dependents: remaining, for: guardian, completion: completion)
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: "Could not delete dependent, please try again later", style: .Warn)
                }
                
            }

            network.request(with: requestModel)
        }

    }
    
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
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: "Could not add depndent, please try again later", style: .Warn)
                }
                
            }
            
            network.request(with: requestModel)
        }
    }

    
}
