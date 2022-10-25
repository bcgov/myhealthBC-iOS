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
    var currentDependant: Patient
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    // Note: Use this if we will make the requests sequentially - in which case we turn "currentDependant" to a let
    public mutating func updateCurrentDependent(newDependent: Patient) {
        self.currentDependant = newDependent
    }
    
    public func fetchHealthRecords() {
        handleCovidTests()
        handleImmunizations()
        handleCovidProofs()
    }
    
    private func handleCovidTests() {
        fetchCovidTests { response in
            self.handleCovidTestsResponse(response: response)
        }
    }
    
    private func handleImmunizations() {
        fetchImmunizations { response in
            self.handleImmunizationsResponse(response: response)
        }
    }
    
    private func handleCovidProofs() {
        fetchVaccineProofs { response in
            self.handleVaccineProofsResponse(response: response)
        }
    }
    
    
}

// MARK: Network requests
extension HealthRecordsService {
    private func fetchCovidTests(completion: @escaping(_ response: AuthenticatedTestResultsResponseModel?) -> Void) {
        guard let token = authManager.authToken, let hdid = self.currentDependant.hdid else { return }
        if NetworkConnection.shared.hasConnection {
            BaseURLWorker.shared.setBaseURL {
                guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
                
                let headers = [
                    Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
                ]
                
                let parameters: HDIDParams = HDIDParams(hdid: hdid)

                let requestModel = NetworkRequest<HDIDParams, AuthenticatedTestResultsResponseModel>(url: endpoints.getAuthenticatedTestResults, type: .Get, parameters: parameters, headers: headers) { result in
                    completion(result)
                }
                
                network.request(with: requestModel)
            }
        }
    }
    
    private func fetchImmunizations(completion: @escaping(_ response: AuthenticatedImmunizationsResponseObject?) -> Void) {
        guard let token = authManager.authToken, let hdid = self.currentDependant.hdid else { return }
        if NetworkConnection.shared.hasConnection {
            BaseURLWorker.shared.setBaseURL {
                guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
                
                let headers = [
                    Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
                ]
                
                let parameters: HDIDParams = HDIDParams(hdid: hdid)

                let requestModel = NetworkRequest<HDIDParams, AuthenticatedImmunizationsResponseObject>(url: endpoints.getAuthenticatedImmunizations, type: .Get, parameters: parameters, headers: headers) { result in
                    completion(result)
                }
                
                network.request(with: requestModel)
            }
        }
    }
    
    private func fetchVaccineProofs(completion: @escaping(_ response: GatewayVaccineCardResponse?) -> Void) {
        guard let token = authManager.authToken, let hdid = self.currentDependant.hdid else { return }
        if NetworkConnection.shared.hasConnection {
            BaseURLWorker.shared.setBaseURL {
                guard BaseURLWorker.shared.isOnline == true else { return completion(nil) }
                
                let headers = [
                    Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)"
                ]
                
                let parameters: HDIDParams = HDIDParams(hdid: hdid)

                let requestModel = NetworkRequest<HDIDParams, GatewayVaccineCardResponse>(url: endpoints.getAuthenticatedVaccineCard, type: .Get, parameters: parameters, headers: headers) { result in
                    completion(result)
                }

                network.request(with: requestModel)
            }
        }
    }
}

// MARK: Handle responses
extension HealthRecordsService {
    private func handleCovidTestsResponse(response: AuthenticatedTestResultsResponseModel?) {
        if response?.resourcePayload?.loaded == false && DependentRetryCounter.shared.getRetryCount(forType: .CovidTest) < Constants.NetworkRetryAttempts.publicRetryMaxForTestResults, let retryinMS = response?.resourcePayload?.retryin {
            DependentRetryCounter.shared.increaseRetryCount(forType: .CovidTest)
            let retryInSeconds = Double(retryinMS/1000)
            DispatchQueue.main.asyncAfter(deadline: .now() + retryInSeconds) {
                self.handleCovidTests()
            }
        } else if let resultMessage = response?.resultError?.resultMessage, response?.resourcePayload?.orders.count == 0 {
            // TODO: Error handling here
        } else if let covidTests = response?.resourcePayload, covidTests.orders.count > 0 {
            DependentRetryCounter.shared.resetRetryCount(forType: .CovidTest)
            handleCovidTestsInCoreData(covidTests: covidTests)
        } else {
            // TODO: Other error handling here
        }
    }
    
    private func handleImmunizationsResponse(response: AuthenticatedImmunizationsResponseObject?) {
        if let resultMessage = response?.resultError?.resultMessage, response?.resourcePayload?.immunizations?.count == 0 {
            // TODO: Error handling here
        } else if let immunizations = response?.resourcePayload {
            handleImmunizationsInCoreData(immunizations: immunizations)
            // TODO: Should probably do recommendations as well
        } else {
            // TODO: Other error handling here
        }
    }
    
    private func handleVaccineProofsResponse(response: GatewayVaccineCardResponse?) {
        if response?.resourcePayload?.loaded == false && DependentRetryCounter.shared.getRetryCount(forType: .CovidProofs) < Constants.NetworkRetryAttempts.publicRetryMaxForTestResults, let retryinMS = response?.resourcePayload?.retryin {
            DependentRetryCounter.shared.increaseRetryCount(forType: .CovidProofs)
            let retryInSeconds = Double(retryinMS/1000)
            DispatchQueue.main.asyncAfter(deadline: .now() + retryInSeconds) {
                self.handleCovidProofs()
            }
        } else if let resultMessage = response?.resultError?.resultMessage, (response?.resourcePayload?.qrCode?.data == nil && response?.resourcePayload?.federalVaccineProof?.data == nil) {
            // TODO: Error handling here
        } else if let proofs = response?.resourcePayload {
            DependentRetryCounter.shared.resetRetryCount(forType: .CovidProofs)
            handleCovidProofsInCoreData(proofs: proofs)
        } else {
            // TODO: Other error handling here
        }
    }
}

// MARK: Handle results in core data
extension HealthRecordsService {
    private func handleCovidTestsInCoreData(covidTests: AuthenticatedTestResultsResponseModel.ResourcePayload) {
        // TODO: Core data handling here for Dependant
    }
    
    private func handleImmunizationsInCoreData(immunizations: AuthenticatedImmunizationsResponseObject.ResourcePayload) {
        // TODO: Core data handling here for Dependant
    }
    
    private func handleCovidProofsInCoreData(proofs: GatewayVaccineCardResponse.ResourcePayload) {
        // TODO: Core data handling here for Dependant
    }
}


// MARK: To handle the retry count within a struct
class DependentRetryCounter {
    
    static let shared = DependentRetryCounter()
    
    enum RetryType {
        case CovidTest
        case Immunizations
        case CovidProofs
    }
    
    
    private var covidTestRetryCount = 0
    private var immunizationsRetryCount = 0
    private var covidProofsRetryCount = 0
    
    func getRetryCount(forType type: RetryType) -> Int {
        switch type {
        case .CovidTest:
            return covidTestRetryCount
        case .Immunizations:
            return immunizationsRetryCount
        case .CovidProofs:
            return covidProofsRetryCount
        }
    }
    
    func increaseRetryCount(forType type: RetryType) {
        switch type {
        case .CovidTest:
            covidTestRetryCount += 1
        case .Immunizations:
            immunizationsRetryCount += 1
        case .CovidProofs:
            covidProofsRetryCount += 1
        }
    }
    
    func resetRetryCount(forType type: RetryType) {
        switch type {
        case .CovidTest:
            covidTestRetryCount = 0
        case .Immunizations:
            immunizationsRetryCount = 0
        case .CovidProofs:
            covidProofsRetryCount = 0
        }
    }
}
