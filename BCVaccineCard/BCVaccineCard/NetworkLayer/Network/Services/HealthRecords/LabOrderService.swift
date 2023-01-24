//
//  LabOrderService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-31.
//

import Foundation

typealias labOrdersResponse = AuthenticatedLaboratoryOrdersResponseObject

struct LabOrderService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([LaboratoryOrder])->Void) {
        network.addLoader(message: .FetchingRecords)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader()
                return completion([])
            }
            store(labOrders: response, for: patient, completion: { result in
                network.removeLoader()
                return completion(result)
            })
        }
    }
    
    // MARK: Store
    private func store(labOrders response: labOrdersResponse,
                       for patient: Patient,
                       completion: @escaping ([LaboratoryOrder])->Void
    ) {
        StorageService.shared.deleteAllRecords(in: patient.labOrdersArray)
        let stored = StorageService.shared.storeLaboratoryOrders(patient: patient, gateWayResponse: response)
        return completion(stored)
    }
    
}

// MARK: Network requests
extension LabOrderService {
    
    private func fetch(for patient: Patient, completion: @escaping(_ response: labOrdersResponse?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else {
            return completion(nil)
        }
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, labOrdersResponse>(url: endpoints.getAuthenticatedLaboratoryOrders,
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
