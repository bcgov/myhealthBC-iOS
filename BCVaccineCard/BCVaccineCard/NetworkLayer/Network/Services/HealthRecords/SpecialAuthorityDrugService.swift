//
//  SpecialAuthorityDrugService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-02-10.
//

import Foundation

typealias SpecialAuthorityDrugResponse = AuthenticatedSpecialAuthorityDrugsResponseModel.SpecialAuthorityDrug

struct SpecialAuthorityDrugService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([SpecialAuthorityDrug]?)->Void) {
        if !HealthRecordConstants.enabledTypes.contains(.specialAuthorityDrug) {return completion([])}
        Logger.log(string: "Fetching SpecialAuthorityDrug records for \(patient.name)", type: .Network)
        network.addLoader(message: .SyncingRecords)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader()
                return completion(nil)
            }
            store(medications: response, for: patient){ stored in
                network.removeLoader()
                return completion(stored)
            }
        }
    }
    
    // MARK: Store
    private func store(medications response: [SpecialAuthorityDrugResponse],
                       for patient: Patient,
                       completion: @escaping ([SpecialAuthorityDrug])->Void
    ) {
        Logger.log(string: "Storing SpecialAuthorityDrug records for \(patient.name)", type: .Network)
        StorageService.shared.deleteAllRecords(in: patient.specialAuthorityDrugsArray)
        StorageService.shared.storeSpecialAuthorityMedications(patient: patient, objects: response, authenticated: patient.authenticated, completion: { result in
            return completion(result)
        })
    }
    
}

// MARK: Network requests
extension SpecialAuthorityDrugService {
    private func fetch(for patient: Patient, completion: @escaping(_ response: [SpecialAuthorityDrugResponse]?) -> Void) {
        
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
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedSpecialAuthorityDrugsResponseModel>(url: endpoints.medicationRequest(base: baseURL, hdid: hdid), type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers)
            
            { result in
                Logger.log(string: "Network SpecialAuthorityDrug Result received", type: .Network)
                if let meds = result?.resourcePayload {
                    // return result
                    return completion(meds)
                } else {
                    return completion(nil)
                }
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    break
                }
                
            }
            Logger.log(string: "Network SpecialAuthorityDrug initiated", type: .Network)
            network.request(with: requestModel)
        }
    }
}
