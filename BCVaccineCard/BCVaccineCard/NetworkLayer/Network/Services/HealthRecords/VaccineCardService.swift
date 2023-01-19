//
//  VaccineCardService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-31.
//

import Foundation

typealias VaccineCardsResponse = GatewayVaccineCardResponse

struct VaccineCardService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping (VaccineCard?)->Void) {
        network.addLoader(message: .FetchingRecords)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader()
                return completion(nil)
            }
            store(VaccineCards: response, for: patient, completion: { result in
                network.removeLoader()
                return completion(result)
            })
        }
    }
    
    public func fetchAndStore(for dependent: Dependent, completion: @escaping (VaccineCard?)->Void) {
        guard let patient = dependent.info else {return}
        network.addLoader(message: .FetchingRecords)
        fetchAndStore(for: patient) { vaccineCard in
            network.removeLoader()
            return completion(vaccineCard)
        }
    }
    
    public func fetchAndStoreForDependents(of patient: Patient, completion: @escaping ([VaccineCard])->Void) {
        let dependents = patient.dependentsArray
        guard dependents.count > 0 else { return }
        
        let dispatchGroup = DispatchGroup()
        var records: [VaccineCard] = []
        network.addLoader(message: .FetchingRecords)
        StorageService.shared.deleteDependentVaccineCards(forPatient: patient)
        
        dependents.forEach { dependent in
            dispatchGroup.enter()
            fetchAndStore(for: patient) { vaccineCard in
                if let record = vaccineCard {
                    records.append(record)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // Return completion
            network.removeLoader()
            return completion(records)
        }
    }
    
    private func store(VaccineCards: VaccineCardsResponse,
                       for patient: Patient,
                       completion: @escaping (VaccineCard?)->Void
    ) {
        StorageService.shared.deleteAllRecords(in: patient.vaccineCardArray)
        StorageService.shared.storeVaccineCard(from: VaccineCards, for: patient, manuallyAdded: false, completion: completion)
    }
    
}

// MARK: Network requests
extension VaccineCardService {
    
    private func fetch(for patient: Patient, completion: @escaping(_ response: VaccineCardsResponse?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, VaccineCardsResponse>(url: endpoints.getAuthenticatedVaccineCard,
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
