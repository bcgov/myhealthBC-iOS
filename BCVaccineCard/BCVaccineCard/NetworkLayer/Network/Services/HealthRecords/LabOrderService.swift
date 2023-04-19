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
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([LaboratoryOrder]?)->Void) {
        Logger.log(string: "Fetching LabOrder records for \(patient.name)", type: .Network)
        network.addLoader(message: .SyncingRecords, caller: .LabOrderService_fetchAndStore)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader(caller: .LabOrderService_fetchAndStore)
                return completion(nil)
            }
            store(labOrders: response, for: patient, completion: { result in
                network.removeLoader(caller: .LabOrderService_fetchAndStore)
                return completion(result)
            })
        }
    }
    
    // MARK: Store
    private func store(labOrders response: labOrdersResponse,
                       for patient: Patient,
                       completion: @escaping ([LaboratoryOrder])->Void
    ) {
        Logger.log(string: "Storing LabOrder records for \(patient.name)", type: .Network)
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
            
            let requestModel = NetworkRequest<HDIDParams, labOrdersResponse>(url: endpoints.laboratoryOrders(base: baseURL),
                                                                             type: .Get,
                                                                             parameters: parameters,
                                                                             encoder: .urlEncoder,
                                                                             headers: headers)
            { result in
                Logger.log(string: "Network LabOrder Result received", type: .Network)
                if (result?.resourcePayload) != nil {
                    // return result
                    return completion(result)
                } else {
                    return completion(nil)
                }
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    break
                }
                
            }
            Logger.log(string: "Network LabOrder initiated", type: .Network)
            network.request(with: requestModel)
        }
    }
}
