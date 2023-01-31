//
//  BackgroundTestResultUpdateAPIWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-12-22.
//

import UIKit

protocol BackgroundTestResultUpdateAPIWorkerDelegate: AnyObject {
    func handleTestResult(result: GatewayTestResultResponse, row: Int)
    func handleError(title: String, error: ResultError, row: Int)
}

class BackgroundTestResultUpdateAPIWorker: NSObject {
    
    private var apiClient: APIClient
    weak private var delegate: BackgroundTestResultUpdateAPIWorkerDelegate?
    
    private var retryCount = 0
    private var requestDetails = HealthGatewayAPIWorkerRetryDetails()
    private var includeQueueItUI = false
    private var row: Int = 0
    
    init(delegateOwner: UIViewController) {
        self.apiClient = APIClient(delegateOwner: delegateOwner)
        self.delegate = delegateOwner as? BackgroundTestResultUpdateAPIWorkerDelegate
    }
        
    func getTestResult(model: GatewayTestResultRequest, executingVC: UIViewController, row: Int) {
        self.row = row
        let token = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.testResultDetails = HealthGatewayAPIWorkerRetryDetails.TestResultDetails(model: model, queueItToken: token, executingVC: executingVC)
        apiClient.getTestResult(model, token: token, executingVC: executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.testResultDetails?.queueItToken = queueItToken
                self.apiClient.getTestResult(model, token: queueItToken, executingVC: executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleTestResultResponse(result: result, row: row)
                }
            } else {
                self.handleTestResultResponse(result: result, row: row)
            }
        }
    }
    
}

// MARK: Handling responses
extension BackgroundTestResultUpdateAPIWorker {
    
    private func handleTestResultResponse(result: Result<GatewayTestResultResponse, ResultError>, row: Int) {
        switch result {
        case .success(let testResult):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = testResult.resultError?.resultMessage, (testResult.resourcePayload?.records == nil || testResult.resourcePayload?.records.count == 0) {
                // TODO: Error mapping here
                self.delegate?.handleError(title: .error, error: ResultError(resultMessage: resultMessage), row: row)
            } else if testResult.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.maxRetry - 1, let retryinMS = testResult.resourcePayload?.retryin {
                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                self.perform(#selector(self.retryGetTestResultRequest), with: nil, afterDelay: retryInSeconds)
            } else {
                self.delegate?.handleTestResult(result: testResult, row: row)
            }
        case .failure(let error):
            self.delegate?.handleError(title: .error, error: error, row: row)
        }
    }
    
    @objc private func retryGetTestResultRequest() {
        guard let model = self.requestDetails.testResultDetails?.model, let vc = self.requestDetails.testResultDetails?.executingVC else {
            self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .genericErrorMessage), row: row)
            return
        }
        self.getTestResult(model: model, executingVC: vc, row: row)
    }
}

