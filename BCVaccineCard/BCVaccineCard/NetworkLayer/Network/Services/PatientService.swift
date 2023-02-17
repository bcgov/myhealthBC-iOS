//
//  PatientService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-02-10.
//

import Foundation

typealias PatientDetailResponse = AuthenticatedPatientDetailsResponseObject

struct PatientService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    // MARK: Profile
    public func fetchAndStoreDetails(completion: @escaping (Patient?)->Void) {
        network.addLoader(message: .FetchingRecords)
        fetch() { result in
            guard let response = result else {
                network.removeLoader()
                return completion(nil)
            }
            let patientFirstName = response.resourcePayload?.firstname
            let patientFullName = response.getFullName
            
            store(patientDetails: response, completion: { result in
                network.removeLoader()
                let userInfo: [String: String?] = ["firstName": patientFirstName, "fullName": patientFullName]
                NotificationCenter.default.post(name: .patientAPIFetched, object: nil, userInfo: userInfo as [AnyHashable : Any])
                return completion(result)
            })
        }
    }

    private func store(patientDetails: PatientDetailResponse,
                       completion: @escaping (Patient?)->Void
    ) {
        let phyiscalAddress = StorageService.shared.createAndReturnAddress(addressDetails: patientDetails.resourcePayload?.physicalAddress)
        let mailingAddress = StorageService.shared.createAndReturnAddress(addressDetails: patientDetails.resourcePayload?.postalAddress)
        let patient = StorageService.shared.storePatient(name: patientDetails.getFullName,
                                                         firstName: patientDetails.resourcePayload?.firstname,
                                                         lastName: patientDetails.resourcePayload?.lastname,
                                                         gender: patientDetails.resourcePayload?.gender,
                                                         birthday: patientDetails.getBdayDate,
                                                         phn: patientDetails.resourcePayload?.personalhealthnumber,
                                                         physicalAddress: phyiscalAddress,
                                                         mailingAddress: mailingAddress,
                                                         hdid: AuthManager().hdid,
                                                         authenticated: true)
        
        return completion(patient)
        
    }
    // MARK: Validate
    
    func validateProfile(completion: @escaping (Bool)->Void) {
        validate { response in
            if let response = response, let payload = response.resourcePayload {
                return completion(payload)
            }
        }
    }
}

// MARK: Network requests
extension PatientService {
    
    private func validate(completion: @escaping(_ response: AuthenticatedValidAgeCheck?)->Void) {
        guard let token = authManager.authToken,
              let hdid = authManager.hdid,
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
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedValidAgeCheck>(url: endpoints.validateProfile(base: baseURL, hdid: hdid),
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
    
    private func fetch(completion: @escaping(_ response: PatientDetailResponse?) -> Void) {
        
        guard let token = authManager.authToken,
              let hdid = authManager.hdid,
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
            
            let requestModel = NetworkRequest<HDIDParams, PatientDetailResponse>(url: endpoints.patientDetails(base: baseURL, hdid: hdid),
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
