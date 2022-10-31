//
//  HealthRecordsService.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-10-24.
//

import UIKit

struct HealthRecordsService {
    
    let network: Network
    let authManager: AuthManager
    private let maxRetry = Constants.NetworkRetryAttempts.publicRetryMaxForTestResults
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func fetchHealthRecords(for dependent: Dependent, completion: @escaping ([HealthRecord])->Void) {
        // TODO
    }
    
    private func fetchAndStoreCovidTests(for dependent: Dependent, completion: @escaping ([CovidTestResult])->Void) {
        fetchCovidTests(for: patient, currentAttempt: 0) { response in
            self.handleCovidTestsResponse(response: response)
        }
    }
    
    private func fetchAndStoreImmunizations(for dependent: Dependent, completion: @escaping ([Immunization])->Void) {
        fetchImmunizations(for: patient, currentAttempt: 0) { response in
            self.handleImmunizationsResponse(response: response)
        }
    }
    
    private func fetchAndStoreCovidProofs(for dependent: Dependent, completion: @escaping ([VaccineCard])->Void) {
        fetchVaccineProofs(for: patient, currentAttempt: 0) { response in
            self.handleVaccineProofsResponse(response: response)
        }
    }
    
    // MARK: Store
    private func storeCovidTests(for dependent: Dependent, apiResponse: AuthenticatedTestResultsResponseModel.ResourcePayload,completion: @escaping ([CovidTestResult])->Void) {
        
    }
    private func storeImmunizations(for dependent: Dependent, apiResponse: AuthenticatedImmunizationsResponseObject.ResourcePayload, completion: @escaping ([CovidTestResult])->Void) {
        
    }
    private func storeCovidProofs(for dependent: Dependent, apiResponse: GatewayVaccineCardResponse.ResourcePayload, completion: @escaping ([CovidTestResult])->Void) {
        
    }
    
}

// MARK: Network requests
extension HealthRecordsService {
    private func fetchCovidTests(for dependent: Dependent, currentAttempt: Int, completion: @escaping(_ response: AuthenticatedTestResultsResponseModel?) -> Void) {
        
        guard currentAttempt < maxRetry,
              let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedTestResultsResponseModel>(url: endpoints.getAuthenticatedTestResults, type: .Get, parameters: parameters, headers: headers) { result in
                if result?.resourcePayload?.loaded == false,
                   let retryinMS = result?.resourcePayload?.retryin {
                    // retry if needed
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryinMS/1000)) {
                        fetchVaccineProofs(for: patient, currentAttempt: currentAttempt + 1, completion: completion)
                    }
                    
                } else if let covidTests = response?.resourcePayload, {
                    // return result
                    return completion(result)
                } else {
                    // show error
                    return completion(nil)
                }
            }
            
            network.request(with: requestModel)
        }
    }
    
    private func fetchImmunizations(for dependent: Dependent, currentAttempt: Int, completion: @escaping(_ response: AuthenticatedImmunizationsResponseObject?) -> Void) {
        
        guard currentAttempt < maxRetry,
              let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, AuthenticatedImmunizationsResponseObject>(url: endpoints.getAuthenticatedImmunizations, type: .Get, parameters: parameters, headers: headers) { result in
                
                if result?.resourcePayload?.loaded == false,
                   let retryinMS = result?.resourcePayload?.retryin {
                    // retry if needed
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryinMS/1000)) {
                        fetchVaccineProofs(for: patient, currentAttempt: currentAttempt + 1, completion: completion)
                    }
                    
                } else if let immunizations = response?.resourcePayload {
                    // return result
                    return completion(result)
                } else {
                    // show error
                    return completion(nil)
                }
            }
            
            network.request(with: requestModel)
        }
    }
    
    private func fetchVaccineProofs(for dependent: Dependent, currentAttempt: Int, completion: @escaping(_ response: GatewayVaccineCardResponse?) -> Void) {
        
        guard currentAttempt < maxRetry,
              let token = authManager.authToken,
              let hdid = patient.hdid,
              NetworkConnection.shared.hasConnection
        else { return completion(nil)}
        
        BaseURLWorker.shared.setBaseURL {
            guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
            ]
            
            let parameters: HDIDParams = HDIDParams(hdid: hdid)
            
            let requestModel = NetworkRequest<HDIDParams, GatewayVaccineCardResponse>(url: endpoints.getAuthenticatedVaccineCard, type: .Get, parameters: parameters, headers: headers) { result in
                
                if result?.resourcePayload?.loaded == false,
                   let retryinMS = result?.resourcePayload?.retryin {
                    // retry if needed
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(retryinMS/1000)) {
                        fetchVaccineProofs(for: patient, currentAttempt: currentAttempt + 1, completion: completion)
                    }
                    
                } else if let proofs = result?.resourcePayload {
                    // return result
                    return completion(result)
                } else {
                    // show error
                    return completion(nil)
                }
            }
            
            network.request(with: requestModel)
        }
    }
}

// MARK: Handle responses
//extension HealthRecordsService {
//    private func handleCovidTestsResponse(response: AuthenticatedTestResultsResponseModel?) {
//        if response?.resourcePayload?.loaded == false && DependentRetryCounter.shared.getRetryCount(forType: .CovidTest) < Constants.NetworkRetryAttempts.publicRetryMaxForTestResults, let retryinMS = response?.resourcePayload?.retryin {
//            DependentRetryCounter.shared.increaseRetryCount(forType: .CovidTest)
//            let retryInSeconds = Double(retryinMS/1000)
//            DispatchQueue.main.asyncAfter(deadline: .now() + retryInSeconds) {
//                self.handleCovidTests()
//            }
//        } else if let resultMessage = response?.resultError?.resultMessage, response?.resourcePayload?.orders.count == 0 {
//            // TODO: Error handling here
//        } else if let covidTests = response?.resourcePayload, covidTests.orders.count > 0 {
//            DependentRetryCounter.shared.resetRetryCount(forType: .CovidTest)
//            handleCovidTestsInCoreData(covidTests: covidTests)
//        } else {
//            // TODO: Other error handling here
//        }
//    }
//
//    private func handleImmunizationsResponse(response: AuthenticatedImmunizationsResponseObject?) {
//        if let resultMessage = response?.resultError?.resultMessage, response?.resourcePayload?.immunizations?.count == 0 {
//            // TODO: Error handling here
//        } else if let immunizations = response?.resourcePayload {
//            handleImmunizationsInCoreData(immunizations: immunizations)
//            // TODO: Should probably do recommendations as well
//        } else {
//            // TODO: Other error handling here
//        }
//    }
//
//    private func handleVaccineProofsResponse(response: GatewayVaccineCardResponse?) {
//        if response?.resourcePayload?.loaded == false && DependentRetryCounter.shared.getRetryCount(forType: .CovidProofs) < Constants.NetworkRetryAttempts.publicRetryMaxForTestResults, let retryinMS = response?.resourcePayload?.retryin {
//            DependentRetryCounter.shared.increaseRetryCount(forType: .CovidProofs)
//            let retryInSeconds = Double(retryinMS/1000)
//            DispatchQueue.main.asyncAfter(deadline: .now() + retryInSeconds) {
//                self.handleCovidProofs()
//            }
//        } else if let resultMessage = response?.resultError?.resultMessage, (response?.resourcePayload?.qrCode?.data == nil && response?.resourcePayload?.federalVaccineProof?.data == nil) {
//            // TODO: Error handling here
//        } else if let proofs = response?.resourcePayload {
//            DependentRetryCounter.shared.resetRetryCount(forType: .CovidProofs)
//            handleCovidProofsInCoreData(proofs: proofs)
//        } else {
//            // TODO: Other error handling here
//        }
//    }
//}

//// MARK: Handle results in core data
//extension HealthRecordsService {
//    private func handleCovidTestsInCoreData(covidTests: AuthenticatedTestResultsResponseModel.ResourcePayload) {
//        // TODO: Core data handling here for Dependant
//    }
//
//    private func handleImmunizationsInCoreData(immunizations: AuthenticatedImmunizationsResponseObject.ResourcePayload) {
//        // TODO: Core data handling here for Dependant
//    }
//
//    private func handleCovidProofsInCoreData(proofs: GatewayVaccineCardResponse.ResourcePayload) {
//        // TODO: Core data handling here for Dependant
//    }
//}


// MARK: To handle the retry count within a struct
//class DependentRetryCounter {
//
//    static let shared = DependentRetryCounter()
//
//    enum RetryType {
//        case CovidTest
//        case Immunizations
//        case CovidProofs
//    }
//
//
//    private var covidTestRetryCount = 0
//    private var immunizationsRetryCount = 0
//    private var covidProofsRetryCount = 0
//
//    func getRetryCount(forType type: RetryType) -> Int {
//        switch type {
//        case .CovidTest:
//            return covidTestRetryCount
//        case .Immunizations:
//            return immunizationsRetryCount
//        case .CovidProofs:
//            return covidProofsRetryCount
//        }
//    }
//
//    func increaseRetryCount(forType type: RetryType) {
//        switch type {
//        case .CovidTest:
//            covidTestRetryCount += 1
//        case .Immunizations:
//            immunizationsRetryCount += 1
//        case .CovidProofs:
//            covidProofsRetryCount += 1
//        }
//    }
//
//    func resetRetryCount(forType type: RetryType) {
//        switch type {
//        case .CovidTest:
//            covidTestRetryCount = 0
//        case .Immunizations:
//            immunizationsRetryCount = 0
//        case .CovidProofs:
//            covidProofsRetryCount = 0
//        }
//    }
//}
