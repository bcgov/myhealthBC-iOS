//
//  HealthVisitsService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

typealias HospitalVisitsResponse = AuthenticatedHospitalVisitsResponseObject.HospitalVisit

struct HospitalVisitsService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([HospitalVisit]?)->Void) {
        if !HealthRecordConstants.enabledTypes.contains(.hospitalVisit) {return completion([])}
        Logger.log(string: "Fetching HospitalVisit records for \(patient.name)", type: .Network)
        network.addLoader(message: .FetchingRecords)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader()
                return completion(nil)
            }
            store(HopotalVisits: response, for: patient) { stored in
                network.removeLoader()
                return completion(stored)
            }
            
        }
    }
    
    // MARK: Store
    private func store(HopotalVisits response: [HospitalVisitsResponse],
                       for patient: Patient,
                       completion: @escaping ([HospitalVisit])->Void
    ) {
        Logger.log(string: "Storing HospitalVisit records for \(patient.name)", type: .Network)
        StorageService.shared.deleteAllRecords(in: patient.hospitalVisitsArray)
        let stored = StorageService.shared.storeHospitalVisits(patient: patient, objects: response, authenticated: true)
        return completion(stored)
    }
    
}

// MARK: Network requests
extension HospitalVisitsService {
    private func fetch(for patient: Patient, completion: @escaping(_ response: [HospitalVisitsResponse]?) -> Void) {
        
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
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedHospitalVisitsResponseObject>(url: endpoints.hospitalVisits(base: baseURL, hdid: hdid),
                                                                                                     type: .Get,
                                                                                                     parameters: parameters,
                                                                                                     encoder: .urlEncoder,
                                                                                                     headers: headers)
            { result in
                Logger.log(string: "Network HospitalVisits Result received", type: .Network)
                if let visits = result?.resourcePayload?.hospitalVisits {
                    // return result
                    return completion(visits)
                } else {
                    return completion(nil)
                }
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    break
                }
                
            }
            Logger.log(string: "Network HospitalVisits initiated", type: .Network)
            network.request(with: requestModel)
        }
    }
}
