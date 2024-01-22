//
//  PatientService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-02-10.
//

import Foundation

typealias PatientDetailResponse = AuthenticatedPatientDetailsResponseObject
typealias OrganDonorStatusResponse = AuthenticatedOrganDonorStatusResponseModel.Item
typealias DiagnosticImagingResponse = AuthenticatedDiagnosticImagingResponseModel.Item
//typealias QuickLinksPreferencesResponse = AuthenticatedUserProfileResponseObject.QuickLinks

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
        network.addLoader(message: .SyncingRecords, caller: .PatientService_fetchAndStoreDetails)
        fetchDetail() { result in
            guard let response = result else {
                network.removeLoader(caller: .PatientService_fetchAndStoreDetails)
                return completion(nil)
            }
            let patientFirstName = response.preferredName?.givenName
            let patientFullName = response.getFullName
            store(patientDetails: response, completion: { result in
                network.removeLoader(caller: .PatientService_fetchAndStoreDetails)
                Logger.log(string: "Stored Patient Details", type: .Network)
                let userInfo: [String: String?] = ["firstName": patientFirstName, "fullName": patientFullName]
                NotificationCenter.default.post(name: .patientAPIFetched, object: nil, userInfo: userInfo as [AnyHashable : Any])
                return completion(result)
            })
        }
    }
    
    // MARK: Organ Donor Status
    public func fetchAndStoreOrganDonorStatus(for patient: Patient, completion: @escaping (OrganDonorStatus?)->Void) {
        guard let hdid = patient.hdid else {
            return completion(nil)
        }
        network.addLoader(message: .SyncingRecords, caller: .PatientService_fetchAndStoreOrganDonorStatus)
        fetchPatientData(type: .organDonorRegistrationStatus, hdid: hdid) { result in
            guard let result = result, let data = result.items?.first else {
                network.removeLoader(caller: .PatientService_fetchAndStoreOrganDonorStatus)
                return completion(nil)
            }
            store(donorStatus: data, for: patient) {storedData in
                network.removeLoader(caller: .PatientService_fetchAndStoreOrganDonorStatus)
                return completion(storedData)
            }
        }
    }
    
    private func store(donorStatus: OrganDonorStatusResponse,for patient: Patient, completion: @escaping (OrganDonorStatus?)->Void) {
        let storedObject = StorageService.shared.store(organDonorStatus: donorStatus, for: patient)
        return completion(storedObject)
    }
    
    // MARK: Diagnostic Imaging
    public func fetchAndStoreDiagnosticImaging(for patient: Patient, completion: @escaping ([DiagnosticImaging]?)->Void) {
        guard let hdid = patient.hdid else {
            return completion(nil)
        }
        network.addLoader(message: .SyncingRecords, caller: .PatientService_fetchAndStoreDiagnosticImaging)
        fetchPatientDataDiagnostic(type: .diagnosticImaging, hdid: hdid) { result in
            // TODO: Look into error handling logic here, might be a flaw, need to test out
            guard let result = result, let data = result.items, data.count > 0 else {
                network.removeLoader(caller: .PatientService_fetchAndStoreDiagnosticImaging)
                return completion(nil)
            }
            store(diagnosticImagingArray: data, for: patient) {storedData in
                network.removeLoader(caller: .PatientService_fetchAndStoreDiagnosticImaging)
                return completion(storedData)
            }
        }
    }
    
    private func store(diagnosticImagingArray: [DiagnosticImagingResponse],for patient: Patient, completion: @escaping ([DiagnosticImaging]?)->Void) {
        let storedObject = StorageService.shared.store(diagnosticImagingArray: diagnosticImagingArray, for: patient)
        return completion(storedObject)
    }

    private func store(patientDetails: PatientDetailResponse,
                       completion: @escaping (Patient?)->Void
    ) {
        Logger.log(string: "Storing Patient Details", type: .Network)
        let phyiscalAddress = StorageService.shared.createAndReturnAddress(addressDetails: patientDetails.physicalAddress)
        let mailingAddress = StorageService.shared.createAndReturnAddress(addressDetails: patientDetails.postalAddress)
        let patient = StorageService.shared.fetchOrCreatePatient(phn: patientDetails.personalHealthNumber,
                                                                 name: patientDetails.getFullName,
                                                                 firstName: patientDetails.preferredName?.givenName,
                                                                 lastName: patientDetails.preferredName?.surname,
                                                                 gender: patientDetails.gender,
                                                                 birthday: patientDetails.getBdayDate,
                                                                 physicalAddress: phyiscalAddress,
                                                                 mailingAddress: mailingAddress,
                                                                 hdid: AuthManager().hdid,
                                                                 authenticated: true)
        return completion(patient)
        
    }
    
    // MARK: Validate
    func validateProfile(completion: @escaping (ProfileValidationResult)->Void) {
        network.addLoader(message: .SyncingRecords, caller: .PatientService_validateProfile)
        validate { response, error  in
            network.removeLoader(caller: .PatientService_validateProfile)
            if error != .none {
                switch error {
                case .offlineAPI:
                    return validateOfflineProfile(completion: completion)
                case .offlineDevice:
                    return validateOfflineProfile(completion: completion)
                case .invalidAuthToken:
                    return completion(.CouldNotValidate)
                case .invalidResponse:
                    return completion(.CouldNotValidate)
                case .none:
                    break
                }
            }
            guard let response = response else {
                return completion(.CouldNotValidate)
            }
            guard let payload = response.resourcePayload,payload == true else {
                return completion(.UnderAge)
            }
            network.addLoader(message: .SyncingRecords, caller: .PatientService_validateProfile)
            fetchProfile { profile in
                network.removeLoader(caller: .PatientService_validateProfile)
                guard let profile = profile else {
                    return completion(.CouldNotValidate)
                }
                if profile.resourcePayload?.acceptedTermsOfService == true && profile.resourcePayload?.hasTermsOfServiceUpdated == false
                {
                    return completion(.Valid)
                } else if profile.resourcePayload?.hasTermsOfServiceUpdated == true {
                    return completion(.TOSUpdated)
                } else {
                    return completion(.TOSNotAccepted)
                }
            }
        }
    }
    
    func validateOfflineProfile(completion: @escaping (ProfileValidationResult)->Void) {
        network.showToast(message: "Maintenance is underway.", style: .Warn)
        return completion(.Valid)
    }
    
    enum ProfileValidationResult {
        case UnderAge
        case TOSNotAccepted
        case CouldNotValidate
        case TOSUpdated
        case Valid
    }
}

// MARK: Network requests
extension PatientService {
    
    private func validate(completion: @escaping(_ response: AuthenticatedValidAgeCheck?,_ error: NetworkError)->Void) {
        guard let token = authManager.authToken,
              let hdid = authManager.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil, .offlineDevice)}
        
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil, .offlineAPI)
            }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid, apiVersion: "1")
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedValidAgeCheck>(url: endpoints.validateProfile(base: baseURL, hdid: hdid),
                                                                                type: .Get,
                                                                                parameters: parameters,
                                                                                encoder: .urlEncoder,
                                                                                headers: headers)
            { result in
                
                if (result?.resourcePayload) != nil {
                    // return result
                    return completion(result, .none)
                } else {
                    return completion(nil, .invalidResponse)
                }
            } onError: { error in
                // TODO: Connor check with this here
                network.showToast(error: error)
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
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid, apiVersion: "2")
            
            let requestModel = NetworkRequest<HDIDParams, PatientDetailResponse>(url: endpoints.patientDetails(base: baseURL, hdid: hdid),
                                                                                type: .Get,
                                                                                parameters: parameters,
                                                                                encoder: .urlEncoder,
                                                                                headers: headers)
            { result in
                return completion(result)
            } onError: { error in
                // TODO: Connor check with this here
                network.showToast(error: error)
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
            
            let parameters: DefaultParams = DefaultParams(apiVersion: "1")
            
            let request = NetworkRequest<DefaultParams, AuthenticatedUserProfileResponseObject>(
                url: endpoints.userProfile(base: baseURL, hdid: hdid),
                type: .Get,
                parameters: parameters,
                encoder: .urlEncoder,
                headers: headers,
                completion: { responseData in
                    return completion(responseData)
                }, onError: { error in
                    // TODO: Connor check with this here
                    network.showToast(error: error)
                })
            network.request(with: request)
        }
    }
    
    func fetchPatientData(type: PatientDataType, hdid: String, completion: @escaping(AuthenticatedOrganDonorStatusResponseModel?)-> Void) {
        guard let token = authManager.authToken,
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
            
            let parameters: PatientDataParams = PatientDataParams(patientDataTypes: type.rawValue, apiVersion: "2")
            
            let requestModel = NetworkRequest<PatientDataParams, AuthenticatedOrganDonorStatusResponseModel>(url: endpoints.patientData(base: baseURL, hdid: hdid), type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers)
            { result in
                return completion(result)
            } onError: { error in
                // Note: Commenting this out due to client request
//                network.showToast(error: error)
                
            }
            
            network.request(with: requestModel)
        }
    }
    
    // TODO: Make this reusable with function above - for now, keeping it separate due to completion handler
    private func fetchPatientDataDiagnostic(type: PatientDataType, hdid: String, completion: @escaping(AuthenticatedDiagnosticImagingResponseModel?)-> Void) {
        guard let token = authManager.authToken,
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
            
            let parameters: PatientDataParams = PatientDataParams(patientDataTypes: type.rawValue, apiVersion: "2")
            
            let requestModel = NetworkRequest<PatientDataParams, AuthenticatedDiagnosticImagingResponseModel>(url: endpoints.patientData(base: baseURL, hdid: hdid), type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers)
            { result in
                return completion(result)
            } onError: { error in
                // Note: Commenting this out due to client request
//                network.showToast(error: error)
                
            }
            
            network.request(with: requestModel)
        }
    }
}


enum PatientDataType: String {
    case organDonorRegistrationStatus = "OrganDonorRegistrationStatus"
    case diagnosticImaging = "DiagnosticImaging"
}

struct PatientDataParams: Codable {
    let patientDataTypes: String
    let apiVersion: String
    
    enum CodingKeys: String, CodingKey {
        case patientDataTypes
        case apiVersion = "api-version"
    }
}
