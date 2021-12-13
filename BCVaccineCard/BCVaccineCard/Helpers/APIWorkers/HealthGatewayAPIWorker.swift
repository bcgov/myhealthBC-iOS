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
        apiClient.getVaccineCard(model, token: token, executingVC: executingVC) { [weak self ] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.vaccineCardDetails?.queueItToken = queueItToken
                self.apiClient.getVaccineCard(model, token: queueItToken, executingVC: executingVC) { [weak self ] result, _ in
                    guard let `self` = self else {return}
                    self.handleResponse(result: result)
                }
            } else {
                self.handleResponse(result: result)
            }
        }
    }
    
    func getTestResults(model: GatewayTestResultRequest, executingVC: UIViewController) {
        let token = Defaults.cachedQueueItObject?.queueitToken
    }
    
    private func handleResponse(result: Result<GatewayVaccineCardResponse, ResultError>) {
        switch result {
        case .success(let vaccineCard):
            print(vaccineCard)
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = vaccineCard.resultError?.resultMessage, (vaccineCard.resourcePayload?.qrCode?.data == nil && vaccineCard.resourcePayload?.federalVaccineProof?.data == nil) {
                let adjustedMessage = resultMessage == .errorParsingPHNFromHG ? .errorParsingPHNMessage : resultMessage
                self.delegate?.handleError(title: .error, error: ResultError(resultMessage: adjustedMessage))
//                self.delegate?.hideLoader()
            } else if vaccineCard.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicVaccineStatusRetryMaxForFedPass, let retryinMS = vaccineCard.resourcePayload?.retryin {
                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                self.perform(#selector(self.retryGetActualVaccineCardRequest), with: nil, afterDelay: retryInSeconds)
            } else {
                let qrResult = vaccineCard.transformResponseIntoQRCode()
                guard let code = qrResult.qrString else {
                    self.delegate?.handleError(title: .error, error: ResultError(resultMessage: qrResult.error))
//                    self.delegate?.hideLoader()
                    return
                }
                BCVaccineValidator.shared.validate(code: code) { [weak self] result in
                    guard let `self` = self else { return }
                    guard let data = result.result else {
                        self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .invalidQRCodeMessage))
//                        self.delegate?.hideLoader()
                        return
                    }
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else {return}
                        self.delegate?.handleVaccineCard(scanResult: data, fedCode: vaccineCard.resourcePayload?.federalVaccineProof?.data)
//                        self.delegate?.hideLoader()
                    }
                    
                }
            }
        case .failure(let error):
            print(error)
//            self.delegate?.hideLoader()
            self.delegate?.handleError(title: .error, error: error)
        }
    }
    
    @objc private func retryGetActualVaccineCardRequest() {
        guard let model = self.requestDetails.vaccineCardDetails?.model, let vc = self.requestDetails.vaccineCardDetails?.executingVC else {
            self.delegate?.handleError(title: .error, error: ResultError(resultMessage: .genericErrorMessage))
            return
        }
        self.getVaccineCard(model: model, executingVC: vc)
    }
}

// This is where we will store details pertaining to each request type
struct HealthGatewayAPIWorkerRetryDetails {
    var vaccineCardDetails: VaccineCardDetails?
    
    
    struct VaccineCardDetails {
        var model: GatewayVaccineCardRequest
        var queueItToken: String?
        var executingVC: UIViewController
    }
}
