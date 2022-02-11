//
//  AuthenticatedHealthRecordsAPIWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-01-19.
//
// TODO: Cleanup
import UIKit
import BCVaccineValidator

// FIXME: Adjust delegates to only pass in once everything has started, and once everything has finished
protocol AuthenticatedHealthRecordsAPIWorkerDelegate: AnyObject {
    func showPatientDetailsError(error: String)
    func showFetchStartedBanner()
    func showFetchCompletedBanner(recordsSuccessful: Int, recordsAttempted: Int, errors: [AuthenticationFetchType: String]?)
}

enum AuthenticationFetchType {
    case PatientDetails
    case VaccineCard
    case TestResults
    case MedicationStatement
    
    // NOTE: The reason this is not in localized file yet is because we don't know what loader will look like, so text will likely change
    var getName: String {
        switch self {
        case .PatientDetails: return "Patient Details"
        case .VaccineCard: return "Vaccine Card"
        case .TestResults: return "Test Results"
        case .MedicationStatement: return "Medication Statement"
        }
    }
}

class AuthenticatedHealthRecordsAPIWorker: NSObject {
    
    private var apiClient: APIClient
    weak private var delegate: AuthenticatedHealthRecordsAPIWorkerDelegate?
    
    private var retryCount = 0
    private var requestDetails = AuthenticatedAPIWorkerRetryDetails()
    private var includeQueueItUI = false
    private var executingVC: UIViewController
    private var patientDetails: AuthenticatedPatientDetailsResponseObject?
    private var authCredentials: AuthenticationRequestObject?
    
    init(delegateOwner: UIViewController) {
        self.apiClient = APIClient(delegateOwner: delegateOwner)
        self.delegate = delegateOwner as? AuthenticatedHealthRecordsAPIWorkerDelegate
        self.executingVC = delegateOwner
    }
    
    // Note: Choosing this instead of completion handlers as completion handlers were causing issues
    // TODO: Turn this into an array which will track the fetch status - construct this independendently (via init, perhaps) so that it is more reusable
    var fetchStatusList: FetchStatusList = FetchStatusList(fetchStatus: [
        .VaccineCard : FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0),
        .TestResults : FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0),
        .MedicationStatement : FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0)
    ]) {
        didSet {
            if fetchStatusList.isCompleted {
                self.delegate?.showFetchCompletedBanner(recordsSuccessful: fetchStatusList.getSuccessfulCount, recordsAttempted: fetchStatusList.getAttemptedCount, errors: fetchStatusList.getErrors)
            }
        }
    }
    
    // Note: The reason we are calling the other requests within this request function is because we are using objc methods for retry methodology, which doesn't allow for an escaping completion block - otherwise, we would clean this function up and call 'initializeRequests' in the completion code
    func getAuthenticatedPatientDetails(authCredentials: AuthenticationRequestObject) {
        self.authCredentials = authCredentials
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
        delegate?.showFetchStartedBanner()
        self.getAuthenticatedVaccineCard(authCredentials: authCredentials)
        self.getAuthenticatedTestResults(authCredentials: authCredentials)
        self.getAuthenticatedMedicationStatement(authCredentials: authCredentials)
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
    
    private func getAuthenticatedMedicationStatement(authCredentials: AuthenticationRequestObject) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedMedicationStatementDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedMedicationStatementDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedMedicationStatement(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else { return }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedMedicationStatementDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedMedicationStatement(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else { return }
                    self.handleMedicationStatementResponse(result: result)
                }
            } else {
                self.handleMedicationStatementResponse(result: result)
            }
        }
    }
    
}

// MARK: Retry functions
extension AuthenticatedHealthRecordsAPIWorker {
    
    @objc private func retryGetPatientDetailsRequest() {
        guard let authCredentials = self.requestDetails.authenticatedPatientDetails?.authCredentials else {
            self.delegate?.showPatientDetailsError(error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedPatientDetails(authCredentials: authCredentials)
    }
    
    @objc private func retryGetTestResultsRequest() {
        guard let authCredentials = self.requestDetails.authenticatedTestResultsDetails?.authCredentials else {
            self.fetchStatusList.fetchStatus[.TestResults] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedTestResults(authCredentials: authCredentials)
    }
    
    @objc private func retryGetVaccineCardRequest() {
        guard let authCredentials = self.requestDetails.authenticatedVaccineCardDetails?.authCredentials else {
            self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedVaccineCard(authCredentials: authCredentials)
    }
    
    @objc private func retryGetMedicationStatementRequest() {
        guard let authCredentials = self.requestDetails.authenticatedVaccineCardDetails?.authCredentials else {
            self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedMedicationStatement(authCredentials: authCredentials)
    }
    
}

// MARK: Handling responses
extension AuthenticatedHealthRecordsAPIWorker {
    
    private func handleTestResultsResponse(result: Result<AuthenticatedTestResultsResponseModel, ResultError>) {
        switch result {
        case .success(let testResult):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = testResult.resultError?.resultMessage, (testResult.resourcePayload?.orders == nil || testResult.resourcePayload?.orders.count == 0) {
                self.fetchStatusList.fetchStatus[.TestResults] = FetchStatus(requestCompleted: true, attemptedCount: testResult.totalResultCount ?? 0, successfullCount: 0, error: resultMessage)
            }
            else if testResult.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicRetryMaxForTestResults, let retryinMS = testResult.resourcePayload?.retryin {
                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                self.perform(#selector(self.retryGetTestResultsRequest), with: nil, afterDelay: retryInSeconds)
            }
            else {
                self.handleTestResultsInCoreData(testResult: testResult)
                
            }
        case .failure(let error):
            self.fetchStatusList.fetchStatus[.TestResults] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
        
    private func handleVaccineCardResponse(result: Result<GatewayVaccineCardResponse, ResultError>) {
        switch result {
        case .success(let vaccineCard):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = vaccineCard.resultError?.resultMessage, (vaccineCard.resourcePayload?.qrCode?.data == nil && vaccineCard.resourcePayload?.federalVaccineProof?.data == nil) {
                // TODO: Error mapping here
                self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 0, error: resultMessage)
            } else if vaccineCard.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicVaccineStatusRetryMaxForFedPass, let retryinMS = vaccineCard.resourcePayload?.retryin {
                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                self.perform(#selector(self.retryGetVaccineCardRequest), with: nil, afterDelay: retryInSeconds)
            } else {
                self.handleVaccineCardInCoreData(vaccineCard: vaccineCard)
            }
        case .failure(let error):
            self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
    
    private func handleMedicationStatementResponse(result: Result<AuthenticatedMedicationStatementResponseObject, ResultError>) {
        switch result {
        case .success(let medicationStatement):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = medicationStatement.resultError?.resultMessage, (medicationStatement.resourcePayload == nil || medicationStatement.resourcePayload?.count == 0) {
                self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: medicationStatement.totalResultCount ?? 0, successfullCount: 0, error: resultMessage)
            }
            // NOTE: Currently the response object doesn't have "loaded" property - I could see that changing, so for now added the retry code below and leaving it commented out
//            else if medicationStatement.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicRetryMaxForMedicationStatement, let retryinMS = medicationStatement.resourcePayload?.retryin {
//                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
//                self.retryCount += 1
//                let retryInSeconds = Double(retryinMS/1000)
//                self.perform(#selector(self.retryGetMedicationStatementRequest), with: nil, afterDelay: retryInSeconds)
//            }
            else {
                self.handleMedicationStatementInCoreData(medicationStatement: medicationStatement)
                
            }
        case .failure(let error):
            self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
    
}

// MARK: Handle Vaccine results in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleVaccineCardInCoreData(vaccineCard: GatewayVaccineCardResponse) {
        
        let qrResult = vaccineCard.transformResponseIntoQRCode()
        guard let code = qrResult.qrString else {
            self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 0, error: qrResult.error ?? .genericErrorMessage)
            return
        }
        BCVaccineValidator.shared.validate(code: code) { [weak self] result in
            guard let `self` = self else { return }
            guard let data = result.result else {
                self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 0, error: .invalidQRCodeMessage)
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
                self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 1, error: nil)
            })
        }
    }
    
    private func updateCard(model: AppVaccinePassportModel) {
        let localModel = model.transform()
        StorageService.shared.updateVaccineCard(newData: localModel, authenticated: true, completion: {[weak self] card in
            guard let `self` = self else {return}
            if card != nil {
                self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 1, error: nil)
            } else {
                self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 0, error: .updateCardFailed)
            }
        })
    }
}

// MARK: Handle test results in core data
extension AuthenticatedHealthRecordsAPIWorker {
    // TODO: Handle test results response in core data here
    private func handleTestResultsInCoreData(testResult: AuthenticatedTestResultsResponseModel) {
        guard let patient = self.patientDetails else { return }
        guard let orders = testResult.resourcePayload?.orders else { return }
        var errorArrayCount: Int = 0
        var completedCount: Int = 0
        for order in orders {
            let gatewayResponse = AuthenticatedTestResultsResponseModel.transformToGatewayTestResultResponse(model: order, patient: patient)
            if let id = handleTestResultInCoreData(gatewayResponse: gatewayResponse, authenticated: true, patientObject: patient) {
                completedCount += 1
            } else {
                errorArrayCount += 1
            }
        }
        let error: String? = errorArrayCount > 0 ? .genericErrorMessage : nil
        self.fetchStatusList.fetchStatus[.TestResults] = FetchStatus(requestCompleted: true, attemptedCount: errorArrayCount + completedCount, successfullCount: completedCount, error: error)
    }
    
    private func handleTestResultInCoreData(gatewayResponse: GatewayTestResultResponse, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject) -> String? {
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate) else { return nil }
        guard let object = StorageService.shared.storeTestResults(patient: patient ,gateWayResponse: gatewayResponse, authenticated: authenticated) else { return nil }
        return object.id
    }
}

// MARK: Handle Medication Statement in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleMedicationStatementInCoreData(medicationStatement: AuthenticatedMedicationStatementResponseObject) {
        guard let patient = self.patientDetails else { return }
        guard let payloads = medicationStatement.resourcePayload else { return }
        var errorArrayCount: Int = 0
        var completedCount: Int = 0
        for payload in payloads {
            if let id = handleMedicationStatementInCoreData(object: payload, authenticated: true, patientObject: patient) {
                completedCount += 1
            } else {
                errorArrayCount += 1
            }
        }
        let error: String? = errorArrayCount > 0 ? .genericErrorMessage : nil
        self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: errorArrayCount + completedCount, successfullCount: completedCount, error: error)
    }
    
    private func handleMedicationStatementInCoreData(object: AuthenticatedMedicationStatementResponseObject.ResourcePayload, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject) -> String? {
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate) else { return nil }
        guard let object = StorageService.shared.storePrescription(patient: patient, object: object) else { return nil }
        return object.id
    }
}


// MARK: Structs used for various fetch types
struct AuthenticatedAPIWorkerRetryDetails {
    var authenticatedPatientDetails: AuthenticatedPatientDetails?
    var authenticatedVaccineCardDetails: AuthenticatedVaccineCardDetails?
    var authenticatedTestResultsDetails: AuthenticatedTestResultsDetails?
    var authenticatedMedicationStatementDetails: AuthenticatedMedicationStatementDetails?
    
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
    
    struct AuthenticatedMedicationStatementDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
}

// MARK: Struct used to handle async requests
struct FetchStatus {
    var requestCompleted: Bool
    var attemptedCount: Int
    var successfullCount: Int
    var error: String?
}

struct FetchStatusList {
    var fetchStatus: [AuthenticationFetchType: FetchStatus]
    
    var isCompleted: Bool {
        return fetchStatus.count == fetchStatus.map({ $0.value.requestCompleted == true }).count
    }
    
    var getAttemptedCount: Int {
        return fetchStatus.map { $0.value.attemptedCount }.reduce(0, +)
    }
    
    var getSuccessfulCount: Int {
        return fetchStatus.map { $0.value.successfullCount }.reduce(0, +)
    }
    
    var getErrors: [AuthenticationFetchType: String]? {
        var errors: [AuthenticationFetchType: String] = [:]
        fetchStatus.forEach { instance in
            if let error = instance.value.error {
                errors[instance.key] = error
            }
        }
        guard errors.count > 0 else { return nil }
        return errors
    }
}