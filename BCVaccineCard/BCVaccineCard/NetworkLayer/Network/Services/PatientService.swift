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
        Logger.log(string: "Fetching PatientDetails", type: .Network)
        network.addLoader(message: .FetchingRecords)
        fetchDetail() { result in
            guard let response = result else {
                network.removeLoader()
                return completion(nil)
            }
            let patientFirstName = response.resourcePayload?.firstname
            let patientFullName = response.getFullName
            
            store(patientDetails: response, completion: { result in
                network.removeLoader()
                Logger.log(string: "Stored Patient Details", type: .Network)
                let userInfo: [String: String?] = ["firstName": patientFirstName, "fullName": patientFullName]
                NotificationCenter.default.post(name: .patientAPIFetched, object: nil, userInfo: userInfo as [AnyHashable : Any])
                return completion(result)
            })
        }
    }

    private func store(patientDetails: PatientDetailResponse,
                       completion: @escaping (Patient?)->Void
    ) {
        Logger.log(string: "Storing Patient Details", type: .Network)
        let phyiscalAddress = StorageService.shared.createAndReturnAddress(addressDetails: patientDetails.resourcePayload?.physicalAddress)
        let mailingAddress = StorageService.shared.createAndReturnAddress(addressDetails: patientDetails.resourcePayload?.postalAddress)
        let patient = StorageService.shared.fetchOrCreatePatient(phn: patientDetails.resourcePayload?.personalhealthnumber,
                                                   name: patientDetails.getFullName,
                                                   firstName: patientDetails.resourcePayload?.firstname,
                                                   lastName: patientDetails.resourcePayload?.lastname,
                                                   gender: patientDetails.resourcePayload?.gender,
                                                   birthday: patientDetails.getBdayDate,
                                                   physicalAddress: phyiscalAddress,
                                                   mailingAddress: mailingAddress,
                                                   hdid: AuthManager().hdid,
                                                   authenticated: true)
        return completion(patient)
        
    }
    
    // MARK: Validate
    func validateProfile(completion: @escaping (ProfileValidationResult)->Void) {
        network.addLoader(message: .SyncingRecords)
        validate { response in
            network.removeLoader()
            guard let response = response else {
                
                return completion(.CouldNotValidate)
            }
            guard
                let payload = response.resourcePayload,
                payload == true
            else {
                network.removeLoader()
                return completion(.UnderAge)
            }
            network.addLoader(message: .SyncingRecords)
            fetchProfile { profile in
                network.removeLoader()
                guard let profile = profile else {
                    return completion(.CouldNotValidate)
                }
                if profile.resourcePayload?.acceptedTermsOfService == true
                    // TODO: CHECK TERMS UPDATED
                {
                    return completion(.Valid)
                } else {
                    return completion(.TOSNotAccepted)
                }
            }
        }
    }
    
    enum ProfileValidationResult {
        case UnderAge
        case TOSNotAccepted
        case CouldNotValidate
        case Valid
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
    
    private func fetchDetail(completion: @escaping(_ response: PatientDetailResponse?) -> Void) {
        
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
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
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
    
    func fetchProfile(completion: @escaping (AuthenticatedUserProfileResponseObject?)-> Void) {
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
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
            ]
            
            let request = NetworkRequest<DefaultParams, AuthenticatedUserProfileResponseObject>(
                url: endpoints.userProfile(base: baseURL, hdid: hdid),
                type: .Get,
                parameters: nil,
                headers: headers,
                completion: { responseData in
                    return completion(responseData)
                }, onError: nil)
            network.request(with: request)
        }
    }
}
