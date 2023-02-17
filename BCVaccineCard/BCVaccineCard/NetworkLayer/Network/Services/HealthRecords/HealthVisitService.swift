//
//  HealthVisitService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-02-10.
//

import Foundation

typealias HealthVisitsResponse = AuthenticatedHealthVisitsResponseObject.HealthVisit

struct HealthVisitsService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([HealthVisit])->Void) {
        if !HealthRecordConstants.enabledTypes.contains(.healthVisit) {return completion([])}
        
        network.addLoader(message: .FetchingRecords)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader()
                return completion([])
            }
            store(healthVisits: response, for: patient, completion: completion)
            network.removeLoader()
        }
    }
    
    // MARK: Store
    private func store(healthVisits response: [HealthVisitsResponse],
                       for patient: Patient,
                       completion: @escaping ([HealthVisit])->Void
    ) {
        StorageService.shared.deleteAllRecords(in: patient.healthVisitsArray)
        StorageService.shared.storeHealthVisits(patient: patient, objects: response, authenticated: patient.authenticated, completion: {result in
            return completion(result)
        })
    }
    
}

// MARK: Network requests
extension HealthVisitsService {
    private func fetch(for patient: Patient, completion: @escaping(_ response: [HealthVisitsResponse]?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient .hdid,
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
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedHealthVisitsResponseObject>(url: endpoints.healthVisits(base: baseURL, hdid: hdid),
                                                                                                     type: .Get,
                                                                                                     parameters: parameters,
                                                                                                     encoder: .urlEncoder,
                                                                                                     headers: headers)
            { result in
                if let visits = result?.resourcePayload {
                    // return result
                    return completion(visits)
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
