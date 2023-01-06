//
//  HealthVisitsService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

struct HospitalVisitsService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStoreHospitalVisits(for patient: Patient, completion: @escaping ([Immunization])->Void) {
        network.addLoader(message: .SyncingRecords)
        fetchHospitalVisits(for: patient, currentAttempt: 0) { result in
            guard let response = result else {
                return completion([])
            }
            store(HopotalVisits: response, for: patient, completion: completion)
            network.removeLoader()
        }
    }
    
    // MARK: Store
    private func store(HopotalVisits response: AuthenticatedHospitalVisitsResponseObject,
                       for patient: Patient,
                       completion: @escaping ([Immunization])->Void
    ) {
//        guard let payload = response.resourcePayload
//        else { return completion([]) }
//        let stored = StorageService.shared.storeImmunizations(patient: patient, in: payload, authenticated: false)
//        // TODO: Connor Test stored
//        return completion(stored)
        
        return completion([])
    }
    
}

// MARK: Network requests
extension HospitalVisitsService {
    private func fetchHospitalVisits(for patient: Patient, currentAttempt: Int, completion: @escaping(_ response: AuthenticatedHospitalVisitsResponseObject?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient .hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedHospitalVisitsResponseObject>(url: endpoints.getAuthenticatedHospitalVisits(hdid: hdid), type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers) { result in
                if let visits = result?.resourcePayload {
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
