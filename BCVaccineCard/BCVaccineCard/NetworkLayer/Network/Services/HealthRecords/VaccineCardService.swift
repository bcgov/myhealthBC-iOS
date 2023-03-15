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
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping (VaccineCard?)->Void) {
        network.addLoader(message: .FetchingRecords)
        Logger.log(string: "Fetching VaccineCard records for \(patient.name)", type: .Network)
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
            fetchAndStore(for: dependent) { vaccineCard in
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
    
    func fetchAndStore(phn: String, dateOfBirth: String, dateOfVaccine: String, completion: @escaping (VaccineCard?)->Void) {
        network.addLoader(message: .empty)
        fetch(phn: phn, dateOfBirth: dateOfBirth, dateOfVaccine: dateOfVaccine) { response in
            guard let response = response, let payload = response.resourcePayload else {
                return completion(nil)
            }
            
            
            let fullName = (payload.firstname ?? "") + " " + (payload.lastname ?? "")
            guard let patient = StorageService.shared.fetchOrCreatePatient(phn: phn,
                                                                     name: fullName,
                                                                     firstName: payload.firstname,
                                                                     lastName: payload.lastname,
                                                                     gender: nil,
                                                                     birthday: payload.birthdate?.getGatewayDate(),
                                                                     physicalAddress: nil,
                                                                     mailingAddress: nil,
                                                                     authenticated: false)
            else {
                return completion(nil)
            }
            
            store(vaccineCard: response, for: patient, completion: { result in
                network.removeLoader()
                return completion(result)
            })
        }
    }
    
    private func store(vaccineCard: GatewayVaccineCardResponse,
                       for patient: Patient,
                       completion: @escaping (VaccineCard?)->Void
    ) {
        Logger.log(string: "Storing VaccineCard records from gateway for \(patient.name)", type: .Network)
        StorageService.shared.deleteAllRecords(in: patient.vaccineCardArray)
        StorageService.shared.storeVaccineCard(from: vaccineCard, for: patient, manuallyAdded: true, completion: completion)
    }
    
    private func store(VaccineCards: VaccineCardsResponse,
                       for patient: Patient,
                       completion: @escaping (VaccineCard?)->Void
    ) {
        Logger.log(string: "Storing VaccineCard records for \(patient.name)", type: .Network)
        StorageService.shared.deleteAllRecords(in: patient.vaccineCardArray)
        StorageService.shared.storeVaccineCard(from: VaccineCards, for: patient, manuallyAdded: false, completion: completion)
    }
    
}

// MARK: Network requests
extension VaccineCardService {
    func fetch(phn: String, dateOfBirth: String, dateOfVaccine: String, completion: @escaping (GatewayVaccineCardResponse?)->Void) {
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            
            let headers = [
                Constants.GatewayVaccineCardRequestParameters.phn: phn,
                Constants.GatewayVaccineCardRequestParameters.dateOfBirth: dateOfBirth,
                Constants.GatewayVaccineCardRequestParameters.dateOfVaccine: dateOfVaccine
            ]
            
            let parameters: DefaultParams = DefaultParams()
            
            let requestModel = NetworkRequest<DefaultParams, VaccineCardsResponse>(url: endpoints.vaccineCardPublic(base: baseURL), type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers)
            { result in
                Logger.log(string: "Network VaccineCard Result received", type: .Network)
                return completion(result)
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: .fetchRecordError, style: .Warn)
                }
                
            }
            
            network.request(with: requestModel)
        }
    }
    
    private func fetch(for patient: Patient, completion: @escaping(_ response: VaccineCardsResponse?) -> Void) {
        
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
            
            let requestModel = NetworkRequest<HDIDParams, VaccineCardsResponse>(url: endpoints.vaccineCardAuthenticated(base: baseURL), type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers)
            
            { result in
                Logger.log(string: "Network VaccineCard Result received", type: .Network)
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
            Logger.log(string: "Network VaccineCard initiated", type: .Network)
            network.request(with: requestModel)
        }
    }
}
