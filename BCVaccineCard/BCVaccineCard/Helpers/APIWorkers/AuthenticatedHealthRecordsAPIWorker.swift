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
        self.getAuthenticatedVaccineCard(authCredentials: authCredentials) {
            self.getAuthenticatedTestResults(authCredentials: authCredentials)
        }
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
    
    private func getAuthenticatedVaccineCard(authCredentials: AuthenticationRequestObject, completion: () -> Void) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedVaccineCardDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedVaccineCardDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedVaccineCard(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {
                completion()
                return
            }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedVaccineCardDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedVaccineCard(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {
                        completion()
                        return
                    }
                    self.handleVaccineCardResponse(result: result, completion: completion)
                }
            } else {
                self.handleVaccineCardResponse(result: result, completion: completion)
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
    
    @objc private func retryGetVaccineCardRequest(completion: () -> Void) {
        guard let authCredentials = self.requestDetails.authenticatedVaccineCardDetails?.authCredentials else {
            self.delegate?.handleError(error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedVaccineCard(authCredentials: authCredentials, completion: completion)
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
        
    private func handleVaccineCardResponse(result: Result<GatewayVaccineCardResponse, ResultError>, completion: () -> Void) {
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
                self.handleVaccineCardInCoreData(vaccineCard: vaccineCard, completion: completion)
            }
        case .failure(let error):
            self.delegate?.handleError(error: error.resultMessage)
        }
    }
    
}

// MARK: Handle Vaccine results in core data
extension AuthenticatedHealthRecordsAPIWorker {
    // TODO: Handle vaccine card response in core data here
    private func handleVaccineCardInCoreData(vaccineCard: GatewayVaccineCardResponse, completion: () -> Void) {
        
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
        completion()
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
        
        
        self.delegate?.handleDataProgress(fetchType: .TestResults, totalCount: <#T##Int#>, completedCount: <#T##Int#>)
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

//if let id = handleTestResultInCoreData(gatewayResponse: result, authenticated: false) { /*if id exists, then increase loader value, if not, then increase error array check*/  }

//func handleTestResultInCoreData(gatewayResponse: GatewayTestResultResponse, authenticated: Bool) -> String? {
//    // Note, this first guard statement is to handle the case when health gateway is wonky - throws success with no error but has key nil values, so in this case we don't want to store a dummy patient value, as that's what was happening
//    guard let collectionDate = gatewayResponse.resourcePayload?.records.first?.collectionDateTime,
//          !collectionDate.trimWhiteSpacesAndNewLines.isEmpty, let reportID = gatewayResponse.resourcePayload?.records.first?.reportId,
//          !reportID.trimWhiteSpacesAndNewLines.isEmpty else { return nil }
//    guard let phnIndexPath = getIndexPathForSpecificCell(.phnForm, inDS: self.dataSource, usingOnlyShownCells: false) else { return nil }
//    guard let phn = dataSource[phnIndexPath.row].configuration.text?.removeWhiteSpaceFormatting else { return nil }
//    let bday: Date?
//    if let dobIndexPath = getIndexPathForSpecificCell(.dobForm, inDS: self.dataSource, usingOnlyShownCells: false),
//       let dob = dataSource[dobIndexPath.row].configuration.text,
//       let dateOfBirth = Date.Formatter.yearMonthDay.date(from: dob) {
//        bday = dateOfBirth
//    } else {
//        bday = nil
//    }
//    guard let patient = StorageService.shared.fetchOrCreatePatient(phn: phn, name: gatewayResponse.resourcePayload?.records.first?.patientDisplayName, birthday: bday) else {return nil}
//    guard let object = StorageService.shared.storeTestResults(patient: patient ,gateWayResponse: gatewayResponse, authenticated: authenticated) else { return nil }
//    return object.id
//}
