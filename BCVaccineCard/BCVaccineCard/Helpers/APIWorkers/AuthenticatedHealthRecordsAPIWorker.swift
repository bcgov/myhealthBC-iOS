//
//  AuthenticatedHealthRecordsAPIWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-19.
//
// TODO: Connor 2: Create AuthenticatedHealthRecordsAPIWorker - similar to background test result api worker - except records will be stored/modified in core data in this worker, and then will notify tab bar that the record has been updated
import UIKit
import BCVaccineValidator

// FIXME: Adjust delegates to handle progress (pass back value, and completed fetch type)
protocol AuthenticatedHealthRecordsAPIWorkerDelegate: AnyObject {
    func handleDataProgress(fetchType: AuthenticationFetchType, totalCount: Int, completedCount: Int)
    func handleError(error: String?)
}

enum AuthenticationFetchType {
    case VaccineCard
    case TestResults
}

class AuthenticatedHealthRecordsAPIWorker: NSObject {
    
    private var apiClient: APIClient
    weak private var delegate: AuthenticatedHealthRecordsAPIWorkerDelegate?
    
    private var retryCount = 0
    private var requestDetails = AuthenticatedAPIWorkerRetryDetails()
    private var includeQueueItUI = false
    private var executingVC: UIViewController
    private var patientDetails: AuthenticatedPatientDetailsResponseObject?
    
    init(delegateOwner: UIViewController) {
        self.apiClient = APIClient(delegateOwner: delegateOwner)
        self.delegate = delegateOwner as? AuthenticatedHealthRecordsAPIWorkerDelegate
        self.executingVC = delegateOwner
    }
    
    // Note: The reason we are calling the other requests within this request function is because we are using objc methods for retry methodology, which doesn't allow for an escaping completion block - otherwise, we would clean this function up and call 'initializeRequests' in the completion code
    func getAuthenticatedPatientDetails(authCredentials: AuthenticationRequestObject) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedPatientDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedPatientDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedPatientDetails(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedPatientDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedPatientDetails(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.initializePatientDetails(authCredentials: authCredentials, result: result)
                    
                }
            } else {
                self.initializePatientDetails(authCredentials: authCredentials, result: result)
            }
        }
    }
    
    private func initializePatientDetails(authCredentials: AuthenticationRequestObject, result: Result<AuthenticatedPatientDetailsResponseObject, ResultError>) {
        switch result {
        case .success(let patientDetails):
            self.patientDetails = patientDetails
            initializeRequests(authCredentials: authCredentials)
        case .failure(let error):
            print(error)
            //TODO: Handle error here
        }
    }
    
    private func initializeRequests(authCredentials: AuthenticationRequestObject) {
        self.getAuthenticatedVaccineCard(authCredentials: authCredentials)
        self.getAuthenticatedTestResults(authCredentials: authCredentials)
    }
        
    private func getAuthenticatedTestResults(authCredentials: AuthenticationRequestObject) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedTestResultsDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedTestResultsDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedTestResults(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedTestResultsDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedTestResults(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleTestResultsResponse(result: result)
                }
            } else {
                self.handleTestResultsResponse(result: result)
            }
        }
    }
    
    private func getAuthenticatedVaccineCard(authCredentials: AuthenticationRequestObject) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedVaccineCardDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedVaccineCardDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedVaccineCard(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else { return }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedVaccineCardDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedVaccineCard(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else { return }
                    self.handleVaccineCardResponse(result: result)
                }
            } else {
                self.handleVaccineCardResponse(result: result)
            }
        }
    }
    
}

// MARK: Retry functions
extension AuthenticatedHealthRecordsAPIWorker {
    
    @objc private func retryGetPatientDetailsRequest() {
        guard let authCredentials = self.requestDetails.authenticatedPatientDetails?.authCredentials else {
            self.delegate?.handleError(error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedPatientDetails(authCredentials: authCredentials)
    }
    
    @objc private func retryGetTestResultsRequest() {
        guard let authCredentials = self.requestDetails.authenticatedTestResultsDetails?.authCredentials else {
            self.delegate?.handleError(error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedTestResults(authCredentials: authCredentials)
    }
    
    @objc private func retryGetVaccineCardRequest() {
        guard let authCredentials = self.requestDetails.authenticatedVaccineCardDetails?.authCredentials else {
            self.delegate?.handleError(error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedVaccineCard(authCredentials: authCredentials)
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
                self.delegate?.handleError(error: resultMessage)
            }
            // TODO: Find out if retry logic is needed
//            else if testResult.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicRetryMaxForTestResults, let retryinMS = testResult.resourcePayload?.retryin {
//                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
//                self.retryCount += 1
//                let retryInSeconds = Double(retryinMS/1000)
//                self.perform(#selector(self.retryGetTestResultsRequest), with: nil, afterDelay: retryInSeconds)
//            }
            else {
                self.handleTestResultsInCoreData(testResult: testResult)
                
            }
        case .failure(let error):
            self.delegate?.handleError(error: error.resultMessage)
        }
    }
        
    private func handleVaccineCardResponse(result: Result<GatewayVaccineCardResponse, ResultError>) {
        switch result {
        case .success(let vaccineCard):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = vaccineCard.resultError?.resultMessage, (vaccineCard.resourcePayload?.qrCode?.data == nil && vaccineCard.resourcePayload?.federalVaccineProof?.data == nil) {
                // TODO: Error mapping here
                self.delegate?.handleError(error: resultMessage)
            } else if vaccineCard.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicVaccineStatusRetryMaxForFedPass, let retryinMS = vaccineCard.resourcePayload?.retryin {
                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                self.perform(#selector(self.retryGetVaccineCardRequest), with: nil, afterDelay: retryInSeconds)
            } else {
                self.handleVaccineCardInCoreData(vaccineCard: vaccineCard)
            }
        case .failure(let error):
            self.delegate?.handleError(error: error.resultMessage)
        }
    }
    
}

// MARK: Handle Vaccine results in core data
extension AuthenticatedHealthRecordsAPIWorker {
    // TODO: Handle vaccine card response in core data here
    private func handleVaccineCardInCoreData(vaccineCard: GatewayVaccineCardResponse) {
        
        let qrResult = vaccineCard.transformResponseIntoQRCode()
        guard let code = qrResult.qrString else {
            self.delegate?.handleError(error: qrResult.error)
            return
        }
        BCVaccineValidator.shared.validate(code: code) { [weak self] result in
            guard let `self` = self else { return }
            guard let data = result.result else {
                self.delegate?.handleError(error: .invalidQRCodeMessage)
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {return}
                var model = self.executingVC.convertScanResultModelIntoLocalData(data: data, source: .healthGateway)
                model.fedCode = vaccineCard.resourcePayload?.federalVaccineProof?.data
                self.coreDataLogic(localModel: model)
            }
        }
    }
    
    private func coreDataLogic(localModel: LocallyStoredVaccinePassportModel) {
        let model = localModel.transform()
        model.state { [weak self] state in
            guard let `self` = self else {return}
            switch state {
            case .isNew:
                self.storeCard(model: model)
            case .canUpdateExisting, .exists, .isOutdated, .UpdatedFederalPass:
                self.updateCard(model: model)
            }
        }
    }
    
    private func storeCard(model: AppVaccinePassportModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.executingVC.storeVaccineCard(model: model.transform(),
                                  authenticated: true,
                                  sortOrder: nil,
                                  completion: {
                self.delegate?.handleDataProgress(fetchType: .VaccineCard, totalCount: 1, completedCount: 1)
            })
        }
    }
    
    private func updateCard(model: AppVaccinePassportModel) {
        let localModel = model.transform()
        StorageService.shared.updateVaccineCard(newData: localModel, authenticated: true, completion: {[weak self] card in
            guard let `self` = self else {return}
            if card != nil {
                self.delegate?.handleDataProgress(fetchType: .VaccineCard, totalCount: 1, completedCount: 1)
            } else {
                self.delegate?.handleError(error: .updateCardFailed)
            }
        })
    }
}

// MARK: Handle test results in core data
extension AuthenticatedHealthRecordsAPIWorker {
    // TODO: Handle test results response in core data here
    private func handleTestResultsInCoreData(testResult: AuthenticatedTestResultsResponseModel) {
        guard let patient = self.patientDetails else { return }
        guard let payloadArray = testResult.resourcePayload else { return }
        var errorArrayCount: Int = 0
        var completedCount: Int = 0
        for resourcePayload in payloadArray {
            let gatewayResponse = AuthenticatedTestResultsResponseModel.transformToGatewayTestResultResponse(model: resourcePayload, patient: patient)
            if let id = handleTestResultInCoreData(gatewayResponse: gatewayResponse, authenticated: true, patientObject: patient) {
                completedCount += 1
                self.delegate?.handleDataProgress(fetchType: .TestResults, totalCount: testResult.totalResultCount ?? payloadArray.count, completedCount: completedCount)
            } else {
                errorArrayCount += 1
                self.delegate?.handleError(error: "Error fetching test result")
            }
        }
    }
    
    private func handleTestResultInCoreData(gatewayResponse: GatewayTestResultResponse, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject) -> String? {
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate) else { return nil }
        guard let object = StorageService.shared.storeTestResults(patient: patient ,gateWayResponse: gatewayResponse, authenticated: authenticated) else { return nil }
        return object.id
    }
}

struct AuthenticatedAPIWorkerRetryDetails {
    var authenticatedPatientDetails: AuthenticatedPatientDetails?
    var authenticatedVaccineCardDetails: AuthenticatedVaccineCardDetails?
    var authenticatedTestResultsDetails: AuthenticatedTestResultsDetails?
    
    struct AuthenticatedPatientDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
    
    struct AuthenticatedVaccineCardDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }

    struct AuthenticatedTestResultsDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
}
