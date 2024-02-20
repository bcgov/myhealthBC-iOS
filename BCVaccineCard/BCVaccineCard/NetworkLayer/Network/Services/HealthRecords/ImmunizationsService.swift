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
    let configService: MobileConfigService
    private let maxRetry = Constants.NetworkRetryAttempts.maxRetry
    private let retryIn = Constants.NetworkRetryAttempts.retryIn
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([Immunization]?)->Void) {
        Logger.log(string: "Fetching Immnunization records for \(patient.name)", type: .Network)
        network.addLoader(message: .SyncingRecords, caller: .ImmnunizationsService_fetchAndStore)
        fetch(for: patient, currentAttempt: 0) { result in
            guard let response = result else {
                network.removeLoader(caller: .ImmnunizationsService_fetchAndStore)
                return completion(nil)
            }
            store(immunizations: response, for: patient, completion: { result in
                network.removeLoader(caller: .ImmnunizationsService_fetchAndStore)
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
        Logger.log(string: "Storing Immnunization records for \(patient.name)", type: .Network)
        StorageService.shared.deleteAllRecords(in: patient.immunizationArray)
        StorageService.shared.deleteAllRecords(in: patient.recommandationsArray)
        
        if let recomandations = payload.recommendations {
            StorageService.shared.storeRecommendations(patient: patient, objects: recomandations, authenticated: patient.authenticated, completion: { results in
                Logger.log(string: "Stored Immnunization Reccomandation records for \(patient.name)", type: .Network)
                let stored = StorageService.shared.storeImmunizations(patient: patient, in: payload, authenticated: false)
                return completion(stored)
            })
        } else {
            Logger.log(string: "Stored Immnunization records for \(patient.name)", type: .Network)
            let stored = StorageService.shared.storeImmunizations(patient: patient, in: payload, authenticated: false)
            return completion(stored)
        }
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
            // Note: Commenting this out due to client request
//            network.showToast(message: .fetchRecordError, style: .Warn)
            return completion(nil)
        }
        
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
            
            let requestModel = NetworkRequest<HDIDParams, immunizationsResponse>(url: endpoints.immunizations(base: baseURL),
                                                                                 type: .Get,
                                                                                 parameters: parameters,
                                                                                 encoder: .urlEncoder,
                                                                                 headers: headers)
            { result in
                
                Logger.log(string: "Network Immnunization Result received", type: .Network)
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
                default:
                    break
                }
                
            }
            
            Logger.log(string: "Network Immnunization initiated", type: .Network)
            network.request(with: requestModel)
        }
    }
}
