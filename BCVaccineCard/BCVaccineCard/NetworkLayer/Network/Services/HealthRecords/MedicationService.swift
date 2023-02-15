//
//  MedicationService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-18.
//

import Foundation

typealias MedicationResponse = AuthenticatedMedicationStatementResponseObject

struct MedicationService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, protectiveWord: String?, completion: @escaping ([Perscription])->Void) {
        network.addLoader(message: .FetchingRecords)
        // TODO: Handle Protected Fetch
        fetch(for: patient, protectiveWord: protectiveWord) { result in
            guard let response = result else {
                network.removeLoader()
                return completion([])
            }
            store(medication: response, for: patient, protected: protectiveWord != nil, completion: { result in
                network.removeLoader()
                return completion(result)
            })
        }
    }
    
    // MARK: Store
    private func store(medication response: MedicationResponse,
                       for patient: Patient,
                       protected: Bool,
                       completion: @escaping ([Perscription])->Void
    ) {
        StorageService.shared.deleteAllRecords(in: patient.prescriptionArray)
        StorageService.shared.storePrescriptions(in: response, patient: patient, initialProtectedMedFetch: protected, completion: completion)
    }
    
}

// MARK: Network requests
extension MedicationService {
    
    private func fetch(for patient: Patient, protectiveWord: String?, completion: @escaping(_ response: MedicationResponse?) -> Void) {
        // TODO: Handle Protected Fetch
        guard let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticatedMedicationStatementParameters.protectiveWord: (protectiveWord ?? "")
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            // TODO: CONNOR: getAuthenticatedMedicationRequest or getAuthenticatedMedicationStatement?
            let requestModel = NetworkRequest<HDIDParams, MedicationResponse>(url: endpoints.getAuthenticatedMedicationStatement(hdid: hdid),
                                                                              type: .Get,
                                                                              parameters: parameters,
                                                                              encoder: .urlEncoder,
                                                                              headers: headers)
            { result in
                if (result?.resourcePayload) != nil {
                    // return result
                    return completion(result)
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
