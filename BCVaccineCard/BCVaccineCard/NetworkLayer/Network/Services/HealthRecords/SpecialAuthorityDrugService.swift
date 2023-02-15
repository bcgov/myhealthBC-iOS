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
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([SpecialAuthorityDrug])->Void) {
        if !HealthRecordConstants.enabledTypes.contains(.specialAuthorityDrug) {return completion([])}
        
        network.addLoader(message: .FetchingRecords)
        fetch(for: patient) { result in
            guard let response = result else {
                return completion([])
            }
            store(medications: response, for: patient, completion: completion)
            network.removeLoader()
        }
    }
    
    // MARK: Store
    private func store(medications response: [SpecialAuthorityDrugResponse],
                       for patient: Patient,
                       completion: @escaping ([SpecialAuthorityDrug])->Void
    ) {
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
              let hdid = patient .hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedSpecialAuthorityDrugsResponseModel>(url: endpoints.getAuthenticatedMedicationRequest(hdid: hdid),
                                                                                                     type: .Get,
                                                                                                     parameters: parameters,
                                                                                                     encoder: .urlEncoder,
                                                                                                     headers: headers)
            { result in
                if let meds = result?.resourcePayload {
                    // return result
                    return completion(meds)
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

