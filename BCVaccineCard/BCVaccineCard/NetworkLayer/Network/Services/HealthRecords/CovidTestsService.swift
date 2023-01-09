//
//  CovidTestsService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-31.
//

import Foundation

typealias covidTestsResponse = AuthenticatedTestResultsResponseModel

struct CovidTestsService {
    
    let network: Network
    let authManager: AuthManager
    private let maxRetry = Constants.NetworkRetryAttempts.publicRetryMaxForTestResults
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchAndStoreCovidTests(for dependent: Dependent, completion: @escaping ([CovidLabTestResult])->Void) {
        fetchCovidTests(for: dependent, currentAttempt: 0) { result in
            guard let response = result else {
                return completion([])
            }
            store(covidtests: response, for: dependent, completion: completion)
        }
    }
    
   
    // MARK: Store
    private func store(covidtests respose: covidTestsResponse,
                       for dependent: Dependent,
                       completion: @escaping ([CovidLabTestResult])->Void
    ) {
        guard let patient = dependent.info else { return completion([]) }
        
        let stored = StorageService.shared.storeCovidTestResults(patient: patient, in: respose, authenticated: false, manuallyAdded: false, pdf: nil)
        // TODO: Connor Test stored
         return completion(stored)
    }
}

// MARK: Network requests
extension CovidTestsService {
    private func fetchCovidTests(for dependent: Dependent, currentAttempt: Int, completion: @escaping(_ response: AuthenticatedTestResultsResponseModel?) -> Void) {
        
        guard currentAttempt < maxRetry,
              let token = authManager.authToken,
              let hdid = dependent.info?.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }

            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)

            let requestModel = NetworkRequest<HDIDParams, AuthenticatedTestResultsResponseModel>(url: endpoints.getAuthenticatedTestResults, type: .Get, parameters: parameters, encoder: .urlEncoder, headers: headers) { result in
                
                if result?.resourcePayload?.loaded == false, let retryInMS = result?.resourcePayload?.retryin {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryInMS/1000)) {
                        fetchCovidTests(for: dependent, currentAttempt: currentAttempt + 1, completion: completion)
                    }
                } else if let covidTests = result?.resourcePayload {
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
