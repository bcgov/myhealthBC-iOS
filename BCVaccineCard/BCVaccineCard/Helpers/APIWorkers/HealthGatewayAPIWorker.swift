//
//  HGWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-12-13.
//

import UIKit
import BCVaccineValidator

protocol HealthGatewayAPIWorkerDelegate: AnyObject {
    func handleVaccineCard(scanResult: ScanResultModel, fedCode: String?)
    func handleTestResult(result: GatewayTestResultResponse)
    func handleError(title: String, error: ResultError)
}

class HealthGatewayAPIWorker: NSObject {
    
    private var apiClient: APIClient
    weak private var delegate: HealthGatewayAPIWorkerDelegate?
    
    private var retryCount = 0
    private var requestDetails = HealthGatewayAPIWorkerRetryDetails()
    
    init(delegateOwner: UIViewController) {
        self.apiClient = APIClient(delegateOwner: delegateOwner)
        self.delegate = delegateOwner as? HealthGatewayAPIWorkerDelegate
    }
    
    func getVaccineCard(model: GatewayVaccineCardRequest, executingVC: UIViewController) {
        let token = Defaults.cachedQueueItObject?.queueitToken // May need to check if this is necessary - maybe pass nil for now
        requestDetails.vaccineCardDetails = HealthGatewayAPIWorkerRetryDetails.VaccineCardDetails(model: model, queueItToken: token, executingVC: executingVC)
        apiClient.getVaccineCard(model, token: token, executingVC: executingVC, includeQueueItUI: true) { [weak self ] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.vaccineCardDetails?.queueItToken = queueItToken
                self.apiClient.getVaccineCard(model, token: queueItToken, executingVC: executingVC, includeQueueItUI: true) { [weak self ] result, _ in
                    guard let `self` = self else {return}
                    self.handleVaccineCardResponse(result: result)
                }
            } else {
                self.handleVaccineCardResponse(result: result)
            }
        }
    }
    
    func getTestResult(model: GatewayTestResultRequest, executingVC: UIViewController) {
        let token = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.testResultDetails = HealthGatewayAPIWorkerRetryDetails.TestResultDetails(model: model, queueItToken: token, executingVC: executingVC)
        apiClient.getTestResult(model, token: token, executingVC: executingVC, includeQueueItUI: true) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.testResultDetails?.queueItToken = queueItToken
                self.apiClient.getTestResult(model, token: queueItToken, executingVC: executingVC, includeQueueItUI: true) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleTestResultResponse(result: result)
                }
            } else {
                self.handleTestResultResponse(result: result)
            }
        }
    }
    
}

// MARK: Handling responses
extension HealthGatewayAPIWorker {
    private func handleVaccineCardResponse(result: Result<GatewayVaccineCardResponse, ResultError>) {
        switch result {
        case .success(let vaccineCard):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = vaccineCard.resultError?.resultMessage, (vaccineCard.resourcePayload?.qrCode?.data == nil && vaccineCard.resourcePayload?.federalVaccineProof?.data == nil) {
                let adjustedMessage = resultMessage == .errorParsingPHNFromHG ? .errorParsingPHNMessage : resultMessage
                self.delegate?.handleError(title: .error, error: ResultError(resultMessage: adjustedMessage))
            } else if vaccineCard.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicVaccineStatusRetryMaxForFedPass, let retryinMS = vaccineCard.resourcePayload?.retryin {
                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                self.perform(#selector(self.retryGetVaccineCardRequest), with: nil, afterDelay: retryInSeconds)
            } else {
                let qrResult = vaccineCard.transformResponseIntoQRCode()
                guard let code = qrResult.qrString else {
                    self.delegate?.handleError(title: .error, error: ResultError(resultMessage: qrResult.error))
                    return
                }
                BCVaccineValidator.shared.validate(code: code) { [weak self] result in
                    guard let `self` = self else { return }
                    guard let data = result.result else {
                        self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .invalidQRCodeMessage))
                        return
                    }
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else {return}
                        self.delegate?.handleVaccineCard(scanResult: data, fedCode: vaccineCard.resourcePayload?.federalVaccineProof?.data)
                    }
                    
                }
            }
        case .failure(let error):
            Logger.log(string: error.localizedDescription, type: .Network)
            self.delegate?.handleError(title: .error, error: error)
        }
    }
    
    @objc private func retryGetVaccineCardRequest() {
        guard let model = self.requestDetails.vaccineCardDetails?.model, let vc = self.requestDetails.vaccineCardDetails?.executingVC else {
            self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .genericErrorMessage))
            return
        }
        self.getVaccineCard(model: model, executingVC: vc)
    }
    
    
    private func handleTestResultResponse(result: Result<GatewayTestResultResponse, ResultError>) {
        switch result {
        case .success(let testResult):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = testResult.resultError?.resultMessage, (testResult.resourcePayload?.records == nil || testResult.resourcePayload?.records.count == 0) {
                // TODO: Error mapping here
                if checkForMismatchActionCode(error: testResult.resultError) {
                    self.delegate?.handleError(title: .theInformationDoesNotMatchTitle, error: ResultError(resultMessage: .theInformationDoesNotMatchDescription))
                } else {
                    let adjustedMessage = resultMessage == .errorParsingPHNFromHG ? .errorParsingPHNMessage : resultMessage
                    self.delegate?.handleError(title: .error, error: ResultError(resultMessage: adjustedMessage))
                }
            } else if testResult.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicRetryMaxForTestResults, let retryinMS = testResult.resourcePayload?.retryin {
                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                self.perform(#selector(self.retryGetTestResultRequest), with: nil, afterDelay: retryInSeconds)
            } else {
                self.delegate?.handleTestResult(result: testResult)
            }
        case .failure(let error):
            if checkForMismatchActionCode(error: error) {
                self.delegate?.handleError(title: .theInformationDoesNotMatchTitle, error: ResultError(resultMessage: .theInformationDoesNotMatchDescription))
            } else {
                self.delegate?.handleError(title: .error, error: error)
            }
        }
    }
    
    @objc private func retryGetTestResultRequest() {
        guard let model = self.requestDetails.testResultDetails?.model, let vc = self.requestDetails.testResultDetails?.executingVC else {
            self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .genericErrorMessage))
            return
        }
        self.getTestResult(model: model, executingVC: vc)
    }
    
    private func checkForMismatchActionCode(error: ResultError?) -> Bool {
        guard let code = error?.actionCode, code == "MISMATCH" else { return false }
        return true
    }
}

// This is where we will store details pertaining to each request type
struct HealthGatewayAPIWorkerRetryDetails {
    var vaccineCardDetails: VaccineCardDetails?
    var testResultDetails: TestResultDetails?
    
    struct VaccineCardDetails {
        var model: GatewayVaccineCardRequest
        var queueItToken: String?
        var executingVC: UIViewController
    }
    
    struct TestResultDetails {
        var model: GatewayTestResultRequest
        var queueItToken: String?
        var executingVC: UIViewController
    }
}
