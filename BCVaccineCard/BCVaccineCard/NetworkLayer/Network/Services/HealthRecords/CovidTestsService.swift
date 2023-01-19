//
//  CovidTestsService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-31.
//

import Foundation

typealias CovidTestsResponse = AuthenticatedTestResultsResponseModel


struct CovidTestsService {
    
    let network: Network
    let authManager: AuthManager
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStore(for patient: Patient, completion: @escaping ([CovidLabTestResult])->Void) {
        network.addLoader(message: .FetchingRecords)
        fetch(for: patient) { result in
            guard let response = result else {
                network.removeLoader()
                return completion([])
            }
            store(covidtests: response, for: patient, completion: { result in
                network.removeLoader()
                return completion(result)
            })
        }
    }
    
    
    // MARK: Store
    private func store(covidtests respose: CovidTestsResponse,
                       for patient: Patient,
                       completion: @escaping ([CovidLabTestResult])->Void
    ) {
        
        StorageService.shared.deleteAllRecords(in: patient.testResultArray)
        let stored = StorageService.shared.storeCovidTestResults(patient: patient, in: respose, authenticated: false, manuallyAdded: false, pdf: nil)
        return completion(stored)
    }
}

// MARK: Network requests
extension CovidTestsService {
    private func fetch(for patient: Patient, completion: @escaping(_ response: CovidTestsResponse?) -> Void) {
        
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
            
            let requestModel = NetworkRequest<HDIDParams, CovidTestsResponse>(url: endpoints.getAuthenticatedTestResults,
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
