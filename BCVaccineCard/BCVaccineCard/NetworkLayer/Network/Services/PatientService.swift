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
    
    // MARK: Quick Links Preferences
    // Note: Not using a loader when called during background fetch
    // This should be called during records sync only - so loader will not be called
//    public func fetchAndStoreQuickLinksPreferences(for patient: Patient, useLoader: Bool = false, completion: @escaping ([QuickLinkPreferences]?)-> Void) {
//        guard let hdid = patient.hdid else {
//            return completion(nil)
//        }
//        if useLoader {
//            network.addLoader(message: .SyncingPreferences, caller: .QuickLinks_fetchAndStore)
//        }
//        fetchProfile { result in
//            guard let response = result else {
//                if useLoader {
//                    network.removeLoader(caller: .QuickLinks_fetchAndStore)
//                }
//                return completion(nil)
//            }
//            guard let quicklinks = response.resourcePayload?.preferences?.quickLinks else {
//                if useLoader {
//                    network.removeLoader(caller: .QuickLinks_fetchAndStore)
//                }
//                return completion(nil)
//            }
//            let enabled = !(response.resourcePayload?.preferences?.hideOrganDonorQuickLink?.value == "true")
//            let storedLinks = StorageService.shared.store(quickLinksPreferences: quicklinks, isOrganDonorQuickLinkEnabled: enabled, quickLinkVersion: response.resourcePayload?.preferences?.quickLinks?.version, organDonorVersion: response.resourcePayload?.preferences?.hideOrganDonorQuickLink?.version, for: patient)
//            if useLoader {
//                network.removeLoader(caller: .QuickLinks_fetchAndStore)
//            }
//            completion(storedLinks)
//        }
//
//    }
    
//    public func update quick links preferences
//    public func updateQuickLinkPreferences(preferenceString: String, preferenceType: UserProfilePreferencePUTRequestModel.PreferenceType, version: Int, completion: @escaping (UserProfilePreferencePUTResponseModel?, Bool)->Void) {
//        guard let token = authManager.authToken,
//              let hdid = authManager.hdid else { return completion(nil, true) }
//        guard NetworkConnection.shared.hasConnection
//        else {
//            network.showToast(message: .noInternetConnection, style: .Warn)
//            return completion(nil, false)
//        }
//
//        configService.fetchConfig { response in
//            guard let config = response,
//                  config.online,
//                  let baseURLString = config.baseURL,
//                  let baseURL = URL(string: baseURLString)
//            else {
//                network.showToast(message: "Maintenance is underway. Please try later.", style: .Warn)
//                return completion(nil, false)
//            }
//
//            let headers = [
//                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
//                Constants.AuthenticationHeaderKeys.hdid: hdid
//            ]
//            let parameters = UserProfilePreferencePUTRequestModel(hdid: hdid, preference: preferenceType.rawValue, value: preferenceString, version: version)
//            let requestModel = NetworkRequest<UserProfilePreferencePUTRequestModel, UserProfilePreferencePUTResponseModel>(url: endpoints.preference(base: baseURL, hdid: hdid),
//                                                                                type: .Put,
//                                                                                parameters: parameters,
//                                                                                encoder: .json,
//                                                                                headers: headers)
//            { result in
//
//                if (result?.resourcePayload) != nil {
//                    // return result
//                    return completion(result, true)
//                } else {
//                    return completion(nil, true)
//                }
//            } onError: { error in
//                network.showToast(error: error)
//            }
//
//            network.request(with: requestModel)
//        }
//    }
    
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
        validate { response in
            network.removeLoader(caller: .PatientService_validateProfile)
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
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid, apiVersion: "1")
            
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
                network.showToast(error: error)
                
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
                network.showToast(error: error)
                
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
