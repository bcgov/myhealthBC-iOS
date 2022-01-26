//
//  AuthenticatedHealthRecordsAPIWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-19.
//
// TODO: Connor 2: Create AuthenticatedHealthRecordsAPIWorker - similar to background test result api worker - except records will be stored/modified in core data in this worker, and then will notify tab bar that the record has been updated
import UIKit

protocol AuthenticatedHealthRecordsAPIWorkerDelegate: AnyObject {
    func handleTestResult(result: AuthenticatedTestResultsResponseModel)
    func handleVaccineCard(result: GatewayVaccineCardResponse)
    func handleError(title: String, error: ResultError)
}

class AuthenticatedHealthRecordsAPIWorker: NSObject {
    
    private var apiClient: APIClient
    weak private var delegate: AuthenticatedHealthRecordsAPIWorkerDelegate?
    
    private var retryCount = 0
    private var requestDetails = AuthenticatedAPIWorkerRetryDetails()
    private var includeQueueItUI = false
    
    init(delegateOwner: UIViewController) {
        self.apiClient = APIClient(delegateOwner: delegateOwner)
        self.delegate = delegateOwner as? AuthenticatedHealthRecordsAPIWorkerDelegate
    }
        
    func getAuthenticatedTestResults(authCredentials: AuthenticationRequestObject, executingVC: UIViewController) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedTestResultsDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedTestResultsDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached, executingVC: executingVC)
        apiClient.getAuthenticatedTestResults(authCredentials, token: queueItTokenCached, executingVC: executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedTestResultsDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedTestResults(authCredentials, token: queueItToken, executingVC: executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleTestResultsResponse(result: result)
                }
            } else {
                self.handleTestResultsResponse(result: result)
            }
        }
    }
    
    func getAuthenticatedVaccineCard(authCredentials: AuthenticationRequestObject, executingVC: UIViewController) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedVaccineCardDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedVaccineCardDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached, executingVC: executingVC)
        apiClient.getAuthenticatedVaccineCard(authCredentials, token: queueItTokenCached, executingVC: executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedVaccineCardDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedVaccineCard(authCredentials, token: queueItToken, executingVC: executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleVaccineCardResponse(result: result)
                }
            } else {
                self.handleVaccineCardResponse(result: result)
            }
        }
    }
    
}

// MARK: Handling responses
extension AuthenticatedHealthRecordsAPIWorker {
    
    private func handleTestResultsResponse(result: Result<AuthenticatedTestResultsResponseModel, ResultError>) {
        switch result {
        case .success(let testResult):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = testResult.resultError?.resultMessage, (testResult.resourcePayload == nil || testResult.resourcePayload?.count == 0) {
                // TODO: Error mapping here
                self.delegate?.handleError(title: .error, error: ResultError(resultMessage: resultMessage))
            }
            // TODO: Find out if retry logic is needed
//            else if testResult.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicRetryMaxForTestResults, let retryinMS = testResult.resourcePayload?.retryin {
//                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
//                self.retryCount += 1
//                let retryInSeconds = Double(retryinMS/1000)
//                self.perform(#selector(self.retryGetTestResultsRequest), with: nil, afterDelay: retryInSeconds)
//            }
            else {
                self.delegate?.handleTestResult(result: testResult)
            }
        case .failure(let error):
            self.delegate?.handleError(title: .error, error: error)
        }
    }
    
    @objc private func retryGetTestResultsRequest() {
        guard let authCredentials = self.requestDetails.authenticatedTestResultsDetails?.authCredentials, let vc = self.requestDetails.authenticatedTestResultsDetails?.executingVC else {
            self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .genericErrorMessage))
            return
        }
        self.getAuthenticatedTestResults(authCredentials: authCredentials, executingVC: vc)
    }
    
    private func handleVaccineCardResponse(result: Result<GatewayVaccineCardResponse, ResultError>) {
        switch result {
        case .success(let vaccineCard):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = vaccineCard.resultError?.resultMessage, (vaccineCard.resourcePayload?.qrCode?.data == nil && vaccineCard.resourcePayload?.federalVaccineProof?.data == nil) {
                // TODO: Error mapping here
                self.delegate?.handleError(title: .error, error: ResultError(resultMessage: resultMessage))
            } else if vaccineCard.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicVaccineStatusRetryMaxForFedPass, let retryinMS = vaccineCard.resourcePayload?.retryin {
                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                self.perform(#selector(self.retryGetVaccineCardRequest), with: nil, afterDelay: retryInSeconds)
            } else {
                self.delegate?.handleVaccineCard(result: vaccineCard)
            }
        case .failure(let error):
            self.delegate?.handleError(title: .error, error: error)
        }
    }
    
    @objc private func retryGetVaccineCardRequest() {
        guard let authCredentials = self.requestDetails.authenticatedVaccineCardDetails?.authCredentials, let vc = self.requestDetails.authenticatedVaccineCardDetails?.executingVC else {
            self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .genericErrorMessage))
            return
        }
        self.getAuthenticatedVaccineCard(authCredentials: authCredentials, executingVC: vc)
    }
}

struct AuthenticatedAPIWorkerRetryDetails {
    var authenticatedVaccineCardDetails: AuthenticatedVaccineCardDetails?
    var authenticatedTestResultsDetails: AuthenticatedTestResultsDetails?
    
    
    struct AuthenticatedVaccineCardDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
        var executingVC: UIViewController
    }

    struct AuthenticatedTestResultsDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
        var executingVC: UIViewController
    }
}
