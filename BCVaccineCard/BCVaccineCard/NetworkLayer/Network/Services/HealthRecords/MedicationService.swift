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
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, protectiveWord: String?, completion: @escaping ([Perscription], _ protectiveWordRequired: Bool)->Void) {
        network.addLoader(message: .FetchingRecords)
        Logger.log(string: "Fetching Medication records for \(patient.name)", type: .Network)
        // TODO: Handle Protected Fetch
        fetch(for: patient, protectiveWord: protectiveWord) { result in
            if result?.protectiveWordRequired == true {
                SessionStorage.protectiveWordEnabled = true
            }
            
            guard let response = result else {
                network.removeLoader()
                return completion([], result?.protectiveWordRequired == true)
            }
            store(medication: response, for: patient, protected: protectiveWord != nil, completion: { result in
                network.removeLoader()
                return completion(result, response.protectiveWordRequired)
            })
        }
    }
    
    // MARK: Store
    private func store(medication response: MedicationResponse,
                       for patient: Patient,
                       protected: Bool,
                       completion: @escaping ([Perscription])->Void
    ) {
        Logger.log(string: "Storing Medication records for \(patient.name)", type: .Network)
        StorageService.shared.deleteAllRecords(in: patient.prescriptionArray)
        StorageService.shared.storePrescriptions(in: response, patient: patient, initialProtectedMedFetch: protected, completion: completion)
    }
    
}

// MARK: Network requests
extension MedicationService {
    
    private func fetch(for patient: Patient, protectiveWord: String?, completion: @escaping(_ response: MedicationResponse?) -> Void) {
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
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticatedMedicationStatementParameters.protectiveWord: (protectiveWord ?? "")
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            // TODO: CONNOR: getAuthenticatedMedicationRequest or getAuthenticatedMedicationStatement?
            let requestModel = NetworkRequest<HDIDParams, MedicationResponse>(url: endpoints.medicationStatement(base: baseURL, hdid: hdid),
                                                                              type: .Get,
                                                                              parameters: parameters,
                                                                              encoder: .urlEncoder,
                                                                              headers: headers)
            { result in
                Logger.log(string: "Network Medication Result received", type: .Network)
                return completion(result)
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: .fetchRecordError, style: .Warn)
                }
                
            }
            Logger.log(string: "Network Medication initiated", type: .Network)
            network.request(with: requestModel)
        }
    }
    /*
     if isManualAuthFetch {
    //                        self.authManager.storeMedFetchRequired(bool: true)
    //                        self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: nil)
    //                    } else if self.protectedWordAlreadyAttempted == false {
    //                        guard let authCreds = self.authCredentials else { return }
    //                        self.protectedWordAlreadyAttempted = true
    //                        self.getAuthenticatedMedicationStatement(authCredentials: authCreds, protectiveWord: protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
    //                    } else if self.protectedWordAlreadyAttempted == true {
    //                        // In this case, there is an error with the protective word, so we must show an alert
    //                        self.protectedWordAlreadyAttempted = false
    //                        NotificationCenter.default.post(name: .protectedWordFailedPromptAgain, object: nil, userInfo: nil)
    //                        self.deinitializeStatusList()
    //                    }
    */
}
