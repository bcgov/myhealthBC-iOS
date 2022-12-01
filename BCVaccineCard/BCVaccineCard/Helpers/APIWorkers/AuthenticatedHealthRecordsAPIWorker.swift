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
    func showPatientDetailsError(error: String, showBanner: Bool)
    func showFetchStartedBanner(showBanner: Bool)
    func showFetchCompletedBanner(recordsSuccessful: Int, recordsAttempted: Int, errors: [AuthenticationFetchType: String]?, showBanner: Bool, resetHealthRecordsTab: Bool, loginSourceVC: LoginVCSource, fetchStatusTypes: [AuthenticationFetchType])
    func showAlertForLoginAttemptDueToValidation(error: ResultError?)
    func showAlertForUserUnder(ageInYears age: Int)
    func showAlertForUserProfile(error: ResultError?)
}
// TODO: Check to see if we will in fact be pulling comments separately, or if they will be a part of the medication statement request. If separate, we should make the request synchronus
enum AuthenticationFetchType {
    case PatientDetails
    case VaccineCard
    case TestResults
    case MedicationStatement
    case SpecialAuthorityDrugs
    case LaboratoryOrders
    case Immunizations
    case HealthVisits
    case Comments
    
    // NOTE: The reason this is not in localized file yet is because we don't know what loader will look like, so text will likely change
    var getName: String {
        switch self {
        case .PatientDetails: return "Patient Details"
        case .VaccineCard: return "Vaccine Card"
        case .TestResults: return "Test Results"
        case .MedicationStatement: return "Medication Statement"
        case .SpecialAuthorityDrugs: return "Special Authority Drugs"
        case .LaboratoryOrders: return "Laboratory Orders"
        case .Immunizations: return "Immunizations"
        case .HealthVisits: return "HealthVisits"
        case .Comments: return "Comments"
        }
    }
}

class AuthenticatedHealthRecordsAPIWorker: NSObject {
    
    private enum AutoLogoutReason {
        case Underage
        case FailedToValidate
    }
    
    private var apiClient: APIClient
    weak private var delegate: AuthenticatedHealthRecordsAPIWorkerDelegate?
    fileprivate let authManager = AuthManager()
    
    private var retryCount = 0
    private var requestDetails = AuthenticatedAPIWorkerRetryDetails()
    private var includeQueueItUI = false
    private var executingVC: UIViewController
    private var patientDetails: AuthenticatedPatientDetailsResponseObject?
    private var authCredentials: AuthenticationRequestObject?
    private var showBanner = true
    private var isManualAuthFetch = true
    private var loginSourceVC: LoginVCSource = .AfterOnboarding
    private var protectedWordAlreadyAttempted = false
    private var initialProtectedMedFetch = false
    
    init(delegateOwner: UIViewController) {
        self.apiClient = APIClient(delegateOwner: delegateOwner)
        self.delegate = delegateOwner as? AuthenticatedHealthRecordsAPIWorkerDelegate
        self.executingVC = delegateOwner
    }
    
    // Note: Choosing this instead of completion handlers as completion handlers were causing issues
    var fetchStatusList: FetchStatusList = FetchStatusList(fetchStatus: [:]) {
        didSet {
            if fetchStatusList.isCompleted {
                // Check to make sure fetchStatusList isn't just comments
                guard fetchStatusList.isStatusListMoreThanJustComments else {
                    self.deinitializeStatusList()
                    return
                }
                //                StorageService.shared.removeCovidImmunizationDuplicates()
                self.delegate?.showFetchCompletedBanner(recordsSuccessful: fetchStatusList.getSuccessfulCount, recordsAttempted: fetchStatusList.getAttemptedCount, errors: fetchStatusList.getErrors, showBanner: self.showBanner, resetHealthRecordsTab: !self.initialProtectedMedFetch, loginSourceVC: self.loginSourceVC, fetchStatusTypes: fetchStatusList.getFetchStatusTypes)
                self.deinitializeStatusList()
            } else if fetchStatusList.canFetchComments {
                guard let authCredentials = authCredentials else { return }
                self.getAuthenticatedComments(authCredentials: authCredentials)
            }
        }
    }
    
    private func logoutUser(reason: AutoLogoutReason, sourceVC: LoginVCSource, error:  ResultError?, completion: @escaping(Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.authManager.signout { suceess in
                guard suceess else {
                    self.authManager.logoutPermissionCancelled()
                    completion(false)
                    return
                }
                switch reason {
                case .Underage:
                    self.delegate?.showAlertForUserUnder(ageInYears: Constants.AgeLimit.ageLimitForRecords)
                case .FailedToValidate:
                    self.delegate?.showAlertForLoginAttemptDueToValidation(error: error)
                }
                NotificationManager.postLoginDataClearedOnLoginRejection(sourceVC: sourceVC)
                completion(false)
            }
        }
    }
    
    // NOTE: This function handles the check if user is 12 and over, and if user has accepted terms and conditions
    // TODO: should do throttle function separately - build it directly on the authentication view controller
    public func checkIfUserCanLoginAndFetchRecords(authCredentials: AuthenticationRequestObject, sourceVC: LoginVCSource, completion: @escaping(Bool) -> Void) {
        getQueueItWorkingByHittingTestResultsEndpoint(authCredentials: authCredentials) {
            let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
            self.apiClient.checkIfProfileIsValid(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { valid, error in
                guard let valid = valid else {
                    self.logoutUser(reason: .FailedToValidate, sourceVC: sourceVC, error: error, completion: completion)
                    return
                }
                if valid == false {
                    self.logoutUser(reason: .Underage, sourceVC: sourceVC, error: error, completion: completion)
                    return
                }
                // NOTE: Check if user profile has been created here and has accepted terms and conditions
                self.apiClient.hasUserAcceptedTermsOfService(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { hasAccepted, error in
                    guard let hasAccepted = hasAccepted else {
                        self.delegate?.showAlertForUserProfile(error: error)
                        completion(false)
                        return
                    }
                    if hasAccepted {
                        completion(true)
                    } else {
                        // Note: May be an issue with when this is called here, we'll see
                        NotificationManager.showTermsOfService()
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: Get terms of service string
    public func fetchTermsOfService(completion: @escaping(TermsOfServiceResponse.ResourcePayload?, ResultError?) -> Void) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        apiClient.getTermsOfServiceString(token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI, completion: completion)
    }
    
    public func respondToTermsOfService(_ authCredentials: AuthenticationRequestObject, accepted: Bool, termsOfServiceId: String, completion: @escaping (Bool?, ResultError?) -> Void) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        apiClient.respondToTermsOfService(authCredentials, accepted: accepted, termsOfServiceId: termsOfServiceId, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI, completion: completion)
    }
    
    public func getAuthenticatedPatientDetails(authCredentials: AuthenticationRequestObject, showBanner: Bool, isManualFetch: Bool, specificFetchTypes: [AuthenticationFetchType]? = nil, protectiveWord: String? = nil, sourceVC: LoginVCSource, initialProtectedMedFetch: Bool = false) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        // User is valid, so we can proceed here
        self.showBanner = showBanner
        self.isManualAuthFetch = isManualFetch
        self.loginSourceVC = sourceVC
        self.initializeFetchStatusList(withSpecificTypes: specificFetchTypes)
        self.authCredentials = authCredentials
        self.delegate?.showFetchStartedBanner(showBanner: showBanner)
        self.initialProtectedMedFetch = initialProtectedMedFetch
        self.requestDetails.authenticatedPatientDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedPatientDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        self.incrementLoadCounter()
        self.apiClient.getAuthenticatedPatientDetails(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            self.decrementLoadCounter()
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedPatientDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedPatientDetails(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.initializePatientDetails(authCredentials: authCredentials, result: result, specificFetchTypes: specificFetchTypes, protectiveWord: protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
                    
                }
            } else {
                self.initializePatientDetails(authCredentials: authCredentials, result: result, specificFetchTypes: specificFetchTypes, protectiveWord: protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
            }
        }
        
    }
    
    private func initializePatientDetails(authCredentials: AuthenticationRequestObject, result: Result<AuthenticatedPatientDetailsResponseObject, ResultError>, specificFetchTypes: [AuthenticationFetchType]?, protectiveWord: String?, initialProtectedMedFetch: Bool) {
        switch result {
        case .success(let patientDetails):
            self.patientDetails = patientDetails
            self.storePatient(patientDetails: patientDetails)
            let patientFirstName = patientDetails.resourcePayload?.firstname
            let patientFullName = patientDetails.getFullName
            let userInfo: [String: String?] = ["firstName": patientFirstName, "fullName": patientFullName]
            NotificationCenter.default.post(name: .patientAPIFetched, object: nil, userInfo: userInfo as [AnyHashable : Any])
            initializeRequests(authCredentials: authCredentials, specificFetchTypes: specificFetchTypes, protectiveWord: protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
        case .failure(let error):
            Logger.log(string: error.localizedDescription, type: .Network)
            self.delegate?.showPatientDetailsError(error: error.resultMessage ?? .genericErrorMessage, showBanner: self.showBanner)
        }
    }
    
    private func storePatient(patientDetails: AuthenticatedPatientDetailsResponseObject) {
        let _ = StorageService.shared.storePatient(name: patientDetails.getFullName, birthday: patientDetails.getBdayDate, phn: patientDetails.resourcePayload?.personalhealthnumber, authenticated: true)
    }
    
    private func initializeRequests(authCredentials: AuthenticationRequestObject, specificFetchTypes: [AuthenticationFetchType]?, protectiveWord: String?, initialProtectedMedFetch: Bool) {
        // Note: Check if patient is same as currently stored patient or not - if isManualFetch, is currently stored exists, is authenticated, and patient details shows they are different, then delete current patient and all associated records
        if isManualAuthFetch,
           let currentlyStoredPatient = StorageService.shared.fetchAuthenticatedPatient(),
           let newPatient = self.patientDetails,
           currentlyStoredPatient.birthday != newPatient.getBdayDate,
           currentlyStoredPatient.name != newPatient.getFullName {
            // This means that we have to delete the current patient and all associated records
            self.authManager.clearMedFetchProtectiveWordDetails()
            StorageService.shared.deleteHealthRecordsForAuthenticatedUser()
            if let name = currentlyStoredPatient.name, let birthday = currentlyStoredPatient.birthday {
                StorageService.shared.deletePatient(name: name, birthday: birthday)
            } else {
                StorageService.shared.deleteAuthenticatedPatient()
            }
        }
        guard let types = specificFetchTypes else {
            // Note: We use a dummy call first to handle the queue it issues, then afterwards we have the rest of our normal calls
            self.getQueueItWorkingByHittingTestResultsEndpoint(authCredentials: authCredentials, completion: {})
            self.getAuthenticatedVaccineCard(authCredentials: authCredentials)
            self.getAuthenticatedMedicationStatement(authCredentials: authCredentials, protectiveWord: protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
            self.getAuthenticatedSpecialAuthorityDrugs(authCredentials: authCredentials)
            self.getAuthenticatedLaboratoryOrders(authCredentials: authCredentials)
            self.getAuthenticatedImmunizations(authCredentials: authCredentials)
            self.getAuthenticatedHealthVisits(authCredentials: authCredentials)
            self.getAuthenticatedTestResults(authCredentials: authCredentials)
            return
        }
        self.getQueueItWorkingByHittingTestResultsEndpoint(authCredentials: authCredentials, completion: {})
        for type in types {
            switch type {
            case .VaccineCard: self.getAuthenticatedVaccineCard(authCredentials: authCredentials)
            case .TestResults: self.getAuthenticatedTestResults(authCredentials: authCredentials)
            case .MedicationStatement: self.getAuthenticatedMedicationStatement(authCredentials: authCredentials, protectiveWord: protectiveWord ?? authManager.protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
            case .SpecialAuthorityDrugs: self.getAuthenticatedSpecialAuthorityDrugs(authCredentials: authCredentials)
            case .LaboratoryOrders: self.getAuthenticatedLaboratoryOrders(authCredentials: authCredentials)
            case .Immunizations: self.getAuthenticatedImmunizations(authCredentials: authCredentials)
            case .HealthVisits: self.getAuthenticatedHealthVisits(authCredentials: authCredentials)
            default: break
            }
        }
    }
    // Temporary workaround for dumb queueit issues on prod
    private func getQueueItWorkingByHittingTestResultsEndpoint(authCredentials: AuthenticationRequestObject, completion: @escaping()->Void) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedQueueItPingTestResultsDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedQueueItPingTestResultsDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedTestResults(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedQueueItPingTestResultsDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedTestResults(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleQueueItTestResultsResponse(result: result, completion: completion)
                }
            } else {
                self.handleQueueItTestResultsResponse(result: result, completion: completion)
            }
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
    
    private func getAuthenticatedMedicationStatement(authCredentials: AuthenticationRequestObject, protectiveWord: String? = nil, initialProtectedMedFetch: Bool) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedMedicationStatementDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedMedicationStatementDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedMedicationStatement(authCredentials, protectiveWord: protectiveWord, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else { return }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedMedicationStatementDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedMedicationStatement(authCredentials, protectiveWord: protectiveWord, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else { return }
                    self.handleMedicationStatementResponse(result: result, protectiveWord: protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
                }
            } else {
                self.handleMedicationStatementResponse(result: result, protectiveWord: protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
            }
        }
    }
    
    private func getAuthenticatedSpecialAuthorityDrugs(authCredentials: AuthenticationRequestObject) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedSpecialAuthorityDrugsDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedSpecialAuthorityDrugsDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedSpecialAuthorityDrugs(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else { return }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedSpecialAuthorityDrugsDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedSpecialAuthorityDrugs(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else { return }
                    self.handleSpecialAuthorityDrugsResponse(result: result)
                }
            } else {
                self.handleSpecialAuthorityDrugsResponse(result: result)
            }
        }
    }
    
    private func getAuthenticatedLaboratoryOrders(authCredentials: AuthenticationRequestObject) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedLaboratoryOrdersDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedLaboratoryOrdersDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedLaboratoryOrders(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else { return }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedLaboratoryOrdersDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedLaboratoryOrders(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else { return }
                    self.handleLaboratoryOrdersResponse(result: result)
                }
            } else {
                self.handleLaboratoryOrdersResponse(result: result)
            }
        }
    }
    
    private func getAuthenticatedImmunizations(authCredentials: AuthenticationRequestObject) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedImmunizationsDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedImmunizationsDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedImmunizations(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else { return }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedImmunizationsDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedImmunizations(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else { return }
                    self.handleImmunizationsResponse(result: result)
                }
            } else {
                self.handleImmunizationsResponse(result: result)
            }
        }
    }
    
    private func getAuthenticatedHealthVisits(authCredentials: AuthenticationRequestObject) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedHealthVisitsDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedHealthVisitsDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedHealthVisits(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else { return }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedHealthVisitsDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedHealthVisits(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else { return }
                    self.handleHealthVisitsResponse(result: result)
                }
            } else {
                self.handleHealthVisitsResponse(result: result)
            }
        }
    }
    
    // TODO: Refactor this to get comments for specific types - or at least filter them - for the case when we fetch comments with protective word initial fetch
    private func getAuthenticatedComments(authCredentials: AuthenticationRequestObject) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        requestDetails.authenticatedCommentsDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedCommentsDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
        apiClient.getAuthenticatedComments(authCredentials, token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: self.includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else { return }
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.requestDetails.authenticatedCommentsDetails?.queueItToken = queueItToken
                self.apiClient.getAuthenticatedComments(authCredentials, token: queueItToken, executingVC: self.executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else { return }
                    self.handleCommentsResponse(result: result)
                }
            } else {
                self.handleCommentsResponse(result: result)
            }
        }
    }
    
    // TODO: Remove this from here
//    private func getAuthenticatedLaboratoryOrderPDF(authCredentials: AuthenticationRequestObject, reportId: String, completion: @escaping (String?) -> Void) {
//        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
//        requestDetails.authenticatedLabOrderPDFDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedLabOrderPDFDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
//        apiClient.getAuthenticatedLabTestPDF(authCredentials, token: queueItTokenCached, reportId: reportId, executingVC: self.executingVC, includeQueueItUI: false, type: .normal) { [weak self] result, queueItRetryStatus in
//            guard let `self` = self else {
//                completion(nil)
//                return
//            }
//            if let retry = queueItRetryStatus, retry.retry == true {
//                let queueItToken = retry.token
//                self.requestDetails.authenticatedLabOrderPDFDetails?.queueItToken = queueItToken
//                self.apiClient.getAuthenticatedLabTestPDF(authCredentials, token: queueItToken, reportId: reportId, executingVC: self.executingVC, includeQueueItUI: false, type: .normal) { [weak self] result, _ in
//                    guard let `self` = self else {
//                        completion(nil)
//                        return
//                    }
//                    return self.handlePDFResponse(result: result, completion: completion)
//                }
//            } else {
//                return self.handlePDFResponse(result: result, completion: completion)
//            }
//
//        }
//    }
    
//    private func getAuthenticatedCovidTestPDF(authCredentials: AuthenticationRequestObject, reportId: String, completion: @escaping (String?) -> Void) {
//        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
//        requestDetails.authenticatedCovidTestPDFDetails = AuthenticatedAPIWorkerRetryDetails.AuthenticatedCovidTestPDFDetails(authCredentials: authCredentials, queueItToken: queueItTokenCached)
//        apiClient.getAuthenticatedLabTestPDF(authCredentials, token: queueItTokenCached, reportId: reportId, executingVC: self.executingVC, includeQueueItUI: false, type: .covid) { [weak self] result, queueItRetryStatus in
//            guard let `self` = self else {
//                completion(nil)
//                return
//            }
//            if let retry = queueItRetryStatus, retry.retry == true {
//                let queueItToken = retry.token
//                self.requestDetails.authenticatedCovidTestPDFDetails?.queueItToken = queueItToken
//                self.apiClient.getAuthenticatedLabTestPDF(authCredentials, token: queueItToken, reportId: reportId, executingVC: self.executingVC, includeQueueItUI: false, type: .covid) { [weak self] result, _ in
//                    guard let `self` = self else {
//                        completion(nil)
//                        return
//                    }
//                    return self.handlePDFResponse(result: result, completion: completion)
//                }
//            } else {
//                return self.handlePDFResponse(result: result, completion: completion)
//            }
//
//        }
//    }

}

// MARK: Retry functions
extension AuthenticatedHealthRecordsAPIWorker {
    
    @objc private func retryGetPatientDetailsRequest() {
        guard let authCredentials = self.requestDetails.authenticatedPatientDetails?.authCredentials else {
            self.delegate?.showPatientDetailsError(error: .genericErrorMessage, showBanner: self.showBanner)
            return
        }
        self.getAuthenticatedPatientDetails(authCredentials: authCredentials, showBanner: self.showBanner, isManualFetch: self.isManualAuthFetch, sourceVC: self.loginSourceVC)
    }
    
    @objc private func retryGetQueueItTestResultsRequest(completion: @escaping()->Void) {
        guard let authCredentials = self.requestDetails.authenticatedQueueItPingTestResultsDetails?.authCredentials else {
            print("Error")
            
            return completion()
        }
        self.getQueueItWorkingByHittingTestResultsEndpoint(authCredentials: authCredentials, completion: completion)
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
        guard let authCredentials = self.requestDetails.authenticatedMedicationStatementDetails?.authCredentials else {
            self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedMedicationStatement(authCredentials: authCredentials, initialProtectedMedFetch: self.initialProtectedMedFetch)
    }
    
    @objc private func retryGetLaboratoryOrdersRequest() {
        guard let authCredentials = self.requestDetails.authenticatedLaboratoryOrdersDetails?.authCredentials else {
            self.fetchStatusList.fetchStatus[.LaboratoryOrders] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: .genericErrorMessage)
            return
        }
        self.getAuthenticatedLaboratoryOrders(authCredentials: authCredentials)
    }
    
}

// MARK: Handling responses
extension AuthenticatedHealthRecordsAPIWorker {
    
    private func showFetchFailed() {
        AppDelegate.sharedInstance?.showToast(message: "Not all records were fetched successfully", style: .Warn)
    }
    
    private func handleQueueItTestResultsResponse(result: Result<AuthenticatedTestResultsResponseModel, ResultError>, completion: @escaping()->Void) {
        switch result {
        case .success(let testResult):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = testResult.resultError?.resultMessage, testResult.resourcePayload?.orders.count == 0 {
                Logger.log(string: resultMessage, type: .Network)
                completion()
            } else if testResult.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicRetryMaxForTestResults, let retryinMS = testResult.resourcePayload?.retryin {
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                DispatchQueue.main.asyncAfter(deadline: .now() + retryInSeconds, execute: {
                    self.retryGetQueueItTestResultsRequest(completion: completion)
                })
            } else {
                Logger.log(string: "QUEUEIT Test call completed", type: .Network)
                completion()
            }
        case .failure(let error):
            Logger.log(string: "Error: \(error.localizedDescription)", type: .Network)
            return completion()
        }
    }
    
    private func handleTestResultsResponse(result: Result<AuthenticatedTestResultsResponseModel, ResultError>) {
        switch result {
        case .success(let testResult):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = testResult.resultError?.resultMessage, testResult.resourcePayload?.orders.count == 0 {
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
            //            showFetchFailed()
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
            //            showFetchFailed()
            self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
    
    private func handleMedicationStatementResponse(result: Result<AuthenticatedMedicationStatementResponseObject, ResultError>, protectiveWord: String?, initialProtectedMedFetch: Bool) {
        switch result {
        case .success(let medicationStatement):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultError = medicationStatement.resultError, (medicationStatement.resourcePayload == nil || medicationStatement.resourcePayload?.count == 0) {
                if resultError.actionCode == "PROTECTED" {
                    if isManualAuthFetch {
                        self.authManager.storeMedFetchRequired(bool: true)
                        self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: nil)
                    } else if self.protectedWordAlreadyAttempted == false {
                        guard let authCreds = self.authCredentials else { return }
                        self.protectedWordAlreadyAttempted = true
                        self.getAuthenticatedMedicationStatement(authCredentials: authCreds, protectiveWord: protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
                    } else if self.protectedWordAlreadyAttempted == true {
                        // In this case, there is an error with the protective word, so we must show an alert
                        self.protectedWordAlreadyAttempted = false
                        NotificationCenter.default.post(name: .protectedWordFailedPromptAgain, object: nil, userInfo: nil)
                        self.deinitializeStatusList()
                    }
                } else {
                    self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: medicationStatement.totalResultCount ?? 0, successfullCount: 0, error: resultError.resultMessage ?? .genericErrorMessage)
                }
            }
            // NOTE: Currently the response object doesn't have "loaded" property - I could see that changing, so for now added the retry code below and leaving it commented out
            //            else if medicationStatement.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicRetryMaxForMedicationStatement, let retryinMS = medicationStatement.resourcePayload?.retryin {
            //                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
            //                self.retryCount += 1
            //                let retryInSeconds = Double(retryinMS/1000)
            //                self.perform(#selector(self.retryGetMedicationStatementRequest), with: nil, afterDelay: retryInSeconds)
            //            }
            else {
                self.handleMedicationStatementInCoreData(medicationStatement: medicationStatement, protectiveWord: protectiveWord, initialProtectedMedFetch: initialProtectedMedFetch)
            }
        case .failure(let error):
            //            showFetchFailed()
            self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
    
    private func handleSpecialAuthorityDrugsResponse(result: Result<AuthenticatedSpecialAuthorityDrugsResponseModel, ResultError>) {
        switch result {
        case .success(let drugs):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = drugs.resultError?.resultMessage, (drugs.resourcePayload?.count == 0 || drugs.resourcePayload == nil) {
                self.fetchStatusList.fetchStatus[.SpecialAuthorityDrugs] = FetchStatus(requestCompleted: true, attemptedCount: drugs.totalResultCount ?? 0, successfullCount: 0, error: resultMessage)
            }
            else {
                self.handleSpecialAuthorityDrugsInCoreData(specialAuthDrugs: drugs)
            }
        case .failure(let error):
            //            showFetchFailed()
            self.fetchStatusList.fetchStatus[.SpecialAuthorityDrugs] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
    
    private func handleLaboratoryOrdersResponse(result: Result<AuthenticatedLaboratoryOrdersResponseObject, ResultError>) {
        switch result {
        case .success(let labOrders):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = labOrders.resultError?.resultMessage, labOrders.resourcePayload?.orders.count == 0 {
                self.fetchStatusList.fetchStatus[.LaboratoryOrders] = FetchStatus(requestCompleted: true, attemptedCount: labOrders.totalResultCount ?? 0, successfullCount: 0, error: resultMessage)
            }
            else if labOrders.resourcePayload?.loaded == false && self.retryCount < Constants.NetworkRetryAttempts.publicRetryMaxForLaboratoryOrders, let retryinMS = labOrders.resourcePayload?.retryin {
                // Note: If we don't get QR data back when retrying (for BC Vaccine Card purposes), we
                self.retryCount += 1
                let retryInSeconds = Double(retryinMS/1000)
                self.perform(#selector(self.retryGetLaboratoryOrdersRequest), with: nil, afterDelay: retryInSeconds)
            }
            else {
                self.handleLaboratoryOrdersInCoreData(labOrders: labOrders)
            }
        case .failure(let error):
            //            showFetchFailed()
            self.fetchStatusList.fetchStatus[.LaboratoryOrders] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
    
    private func handleImmunizationsResponse(result: Result<AuthenticatedImmunizationsResponseObject, ResultError>) {
        switch result {
        case .success(let immunizations):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = immunizations.resultError?.resultMessage, immunizations.resourcePayload?.immunizations?.count == 0 {
                self.fetchStatusList.fetchStatus[.Immunizations] = FetchStatus(requestCompleted: true, attemptedCount: immunizations.totalResultCount ?? 0, successfullCount: 0, error: resultMessage)
            }
            // Note: This is where we would have the retry logic, however this is currently not in the payload
            else {
                self.handleImmunizationsInCoreData(immunizations: immunizations)
                self.handleImmunizationsRecommendationsInCoreData(payload: immunizations)
            }
        case .failure(let error):
            //            showFetchFailed()
            self.fetchStatusList.fetchStatus[.Immunizations] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
    
    private func handleHealthVisitsResponse(result: Result<AuthenticatedHealthVisitsResponseObject, ResultError>) {
        switch result {
        case .success(let healthVisits):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = healthVisits.resultError?.resultMessage, (healthVisits.resourcePayload?.count == 0 || healthVisits.resourcePayload == nil) {
                self.fetchStatusList.fetchStatus[.HealthVisits] = FetchStatus(requestCompleted: true, attemptedCount: healthVisits.totalResultCount ?? 0, successfullCount: 0, error: resultMessage)
            }
            // Note: This is where we would have the retry logic, however this is currently not in the payload
            else {
                self.handleHealthVisitsInCoreData(healthVisits: healthVisits)
            }
        case .failure(let error):
            //            showFetchFailed()
            self.fetchStatusList.fetchStatus[.HealthVisits] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
    
    private func handleCommentsResponse(result: Result<AuthenticatedCommentResponseObject, ResultError>) {
        switch result {
        case .success(let comments):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = comments.resultError?.resultMessage, (comments.resourcePayload.count == 0) {
                self.fetchStatusList.fetchStatus[.Comments] = FetchStatus(requestCompleted: true, attemptedCount: comments.totalResultCount ?? 0, successfullCount: 0, error: resultMessage)
            } else {
                self.handleCommentsInCoredata(comments: comments)
            }
        case .failure(let error):
            //            showFetchFailed()
            self.fetchStatusList.fetchStatus[.Comments] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: error.resultMessage ?? .genericErrorMessage)
        }
    }
    
    private func handlePDFResponse(result: Result<AuthenticatedPDFResponseObject, ResultError>, completion: @escaping (String?) -> Void) {
        switch result {
        case .success(let pdfObject):
            // Note: Have to check for error here because error is being sent back on a 200 response
            if let resultMessage = pdfObject.resultError?.resultMessage, ((pdfObject.resourcePayload?.data ?? "").isEmpty) {
                Logger.log(string: "Error fetching PDF data", type: .Network)
                completion(nil)
            } else {
                completion(pdfObject.resourcePayload?.data)
            }
        case .failure(let error):
            //            showFetchFailed()
            Logger.log(string: "Error fetching PDF data: " + (error.resultMessage ?? ""), type: .Network)
            completion(nil)
        }
    }
    
    
}

// MARK: Handle Vaccine results in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleVaccineCardInCoreData(vaccineCard: GatewayVaccineCardResponse) {
        guard let patient = self.patientDetails else { return }
        
        incrementLoadCounter()
        
        let qrResult = vaccineCard.transformResponseIntoQRCode()
        guard let code = qrResult.qrString else {
            self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 0, error: qrResult.error ?? .genericErrorMessage)
            self.decrementLoadCounter()
            return
        }
        BCVaccineValidator.shared.validate(code: code) { [weak self] result in
            guard let `self` = self else {
                self?.decrementLoadCounter()
                return
            }
            guard let data = result.result else {
                self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 0, error: .invalidQRCodeMessage)
                self.decrementLoadCounter()
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    self?.decrementLoadCounter()
                    return
                }
                var model = self.executingVC.convertScanResultModelIntoLocalData(data: data, source: .healthGateway)
                model.fedCode = vaccineCard.resourcePayload?.federalVaccineProof?.data
                self.coreDataLogic(localModel: model, patient: patient)
                self.decrementLoadCounter()
            }
        }
    }
    
    private func coreDataLogic(localModel: LocallyStoredVaccinePassportModel, patient: AuthenticatedPatientDetailsResponseObject) {
        let model = localModel.transform()
        model.state { [weak self] state in
            guard let `self` = self else {return}
            switch state {
            case .isNew:
                self.storeCard(model: model, patient: patient)
            case .canUpdateExisting, .exists, .isOutdated, .UpdatedFederalPass:
                self.updateCard(model: model, patient: patient)
            }
        }
    }
    
    private func storeCard(model: AppVaccinePassportModel, patient: AuthenticatedPatientDetailsResponseObject) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.executingVC.storeVaccineCard(model: model.transform(),
                                              authenticated: true,
                                              sortOrder: nil,
                                              patientAPI: patient,
                                              manuallyAdded: false,
                                              completion: { _ in
                self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 1, error: nil)
            })
        }
    }
    
    private func updateCard(model: AppVaccinePassportModel, patient: AuthenticatedPatientDetailsResponseObject) {
        let localModel = model.transform()
        StorageService.shared.updateVaccineCard(newData: localModel, authenticated: true, patient: patient, manuallyAdded: false, completion: {[weak self] card in
            guard let `self` = self else {return}
            if card != nil {
                self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 1, error: nil)
            } else {
                self.fetchStatusList.fetchStatus[.VaccineCard] = FetchStatus(requestCompleted: true, attemptedCount: 1, successfullCount: 0, error: .updateCardFailed)
            }
        })
    }
}

// MARK: Handle covid test results in core data
extension AuthenticatedHealthRecordsAPIWorker {
    // TODO: Handle test results response in core data here
    private func handleTestResultsInCoreData(testResult: AuthenticatedTestResultsResponseModel) {
        guard let patient = self.patientDetails else { return }
        guard let orders = testResult.resourcePayload?.orders else { return }
        
        incrementLoadCounter()
        
        StorageService.shared.deleteHealthRecordsForAuthenticatedUser(types: [.CovidTest])
        var errorArrayCount: Int = 0
        var completedCount: Int = 0
        guard let authCreds = self.authCredentials else {
            self.decrementLoadCounter()
            return
        }
        for order in orders {
//            if order.reportAvailable == true {
//                self.getAuthenticatedCovidTestPDF(authCredentials: authCreds, reportId: order.id ?? "") { pdf in
//                    let gatewayResponse = AuthenticatedTestResultsResponseModel.transformToGatewayTestResultResponse(model: order, patient: patient)
//                    // TODO: Adjust core data to save covid test PDF - do the same as lab order
//                    if let id = self.handleTestResultInCoreData(gatewayResponse: gatewayResponse, pdf: pdf, authenticated: true, patientObject: patient) {
//                        completedCount += 1
//                    } else {
//                        errorArrayCount += 1
//                    }
//                }
//            } else {
                let gatewayResponse = AuthenticatedTestResultsResponseModel.transformToGatewayTestResultResponse(model: order, patient: patient)
                // TODO: Adjust core data to save covid test PDF - do the same as lab order
                if let id = self.handleTestResultInCoreData(gatewayResponse: gatewayResponse, pdf: nil, authenticated: true, patientObject: patient) {
                    completedCount += 1
                } else {
                    errorArrayCount += 1
                }
//            }
        }
        let error: String? = errorArrayCount > 0 ? .genericErrorMessage : nil
        self.fetchStatusList.fetchStatus[.TestResults] = FetchStatus(requestCompleted: true, attemptedCount: errorArrayCount + completedCount, successfullCount: completedCount, error: error)
        self.decrementLoadCounter()
    }
    
    private func handleTestResultInCoreData(gatewayResponse: GatewayTestResultResponse, pdf: String?, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject) -> String? {
        
        incrementLoadCounter()
        
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
        
        guard let object = StorageService.shared.storeCovidTestResults(patient: patient ,gateWayResponse: gatewayResponse, authenticated: authenticated, manuallyAdded: false, pdf: pdf) else {
            self.decrementLoadCounter()
            return nil
        }
        self.decrementLoadCounter()
        return object.id
    }
}

// MARK: Handle Medication Statement in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleMedicationStatementInCoreData(medicationStatement: AuthenticatedMedicationStatementResponseObject, protectiveWord: String?, initialProtectedMedFetch: Bool) {
        guard let patient = self.patientDetails else { return }
        guard let payloads = medicationStatement.resourcePayload else { return }
        incrementLoadCounter()
        
        StorageService.shared.deleteHealthRecordsForAuthenticatedUser(types: [.Prescription])
        var errorArrayCount: Int = 0
        var completedCount: Int = 0
        let dispatchGroup = DispatchGroup()
        for payload in payloads {
            dispatchGroup.enter()
            if let id = handleMedicationStatementInCoreData(object: payload, authenticated: true, patientObject: patient, initialProtectedMedFetch: initialProtectedMedFetch) {
                completedCount += 1
            } else {
                errorArrayCount += 1
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.decrementLoadCounter()
            if let protectiveWord = protectiveWord, completedCount > 0 {
                self.authManager.storeProtectiveWord(protectiveWord: protectiveWord)
                self.authManager.storeMedFetchRequired(bool: false)
            }
            let error: String? = errorArrayCount > 0 ? .genericErrorMessage : nil
            self.fetchStatusList.fetchStatus[.MedicationStatement] = FetchStatus(requestCompleted: true, attemptedCount: errorArrayCount + completedCount, successfullCount: completedCount, error: error)
        }
    }
    
    private func handleMedicationStatementInCoreData(object: AuthenticatedMedicationStatementResponseObject.ResourcePayload, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject, initialProtectedMedFetch: Bool) -> String? {
        incrementLoadCounter()
        
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
        guard let object = StorageService.shared.storePrescription(patient: patient, object: object, initialProtectedMedFetch: initialProtectedMedFetch) else {
            self.decrementLoadCounter()
            return nil
        }
        self.decrementLoadCounter()
        return object.id
    }
}

// MARK: Handle Special Authority Drugs in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleSpecialAuthorityDrugsInCoreData(specialAuthDrugs: AuthenticatedSpecialAuthorityDrugsResponseModel) {
        guard let patient = self.patientDetails else { return }
        guard let drugs = specialAuthDrugs.resourcePayload else { return }
        incrementLoadCounter()
        
        StorageService.shared.deleteHealthRecordsForAuthenticatedUser(types: [.SpecialAuthorityDrug])
        var errorArrayCount: Int = 0
        var completedCount: Int = 0
        guard let authCreds = self.authCredentials else {
            self.decrementLoadCounter()
            return
        }
        for drug in drugs {
            if self.handleSpecialAuthorityDrugsInCoreData(object: drug, authenticated: true, patientObject: patient) != nil {
                completedCount += 1
            } else {
                errorArrayCount += 1
            }
            
        }
        self.decrementLoadCounter()
        let error: String? = errorArrayCount > 0 ? .genericErrorMessage : nil
        // For now, just calling success so that the entire fetch can pass
        self.fetchStatusList.fetchStatus[.SpecialAuthorityDrugs] = FetchStatus(requestCompleted: true, attemptedCount: errorArrayCount + completedCount, successfullCount: completedCount, error: error)
    }
    
    private func handleSpecialAuthorityDrugsInCoreData(object: AuthenticatedSpecialAuthorityDrugsResponseModel.SpecialAuthorityDrug, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject) -> SpecialAuthorityDrug? {
        
        incrementLoadCounter()
        
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
        
        guard let object = StorageService.shared.storeSpecialAuthorityMedication(patient: patient, object: object, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
        self.decrementLoadCounter()
        return object
    }
}

// MARK: Handle Laboratory Orders in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleLaboratoryOrdersInCoreData(labOrders: AuthenticatedLaboratoryOrdersResponseObject) {
        guard let patient = self.patientDetails else { return }
        guard let orders = labOrders.resourcePayload?.orders else { return }
        incrementLoadCounter()
        
        StorageService.shared.deleteHealthRecordsForAuthenticatedUser(types: [.LaboratoryOrder])
        var errorArrayCount: Int = 0
        var completedCount: Int = 0
        guard let authCreds = self.authCredentials else {
            self.decrementLoadCounter()
            return
        }
        for order in orders {
//            if order.reportAvailable == true {
//                self.getAuthenticatedLaboratoryOrderPDF(authCredentials: authCreds, reportId: order.labPdfId ?? "") { pdf in
//                    if let id = self.handleLaboratoryOrdersInCoreData(object: order, pdf: pdf, authenticated: true, patientObject: patient) {
//                        completedCount += 1
//                    } else {
//                        errorArrayCount += 1
//                    }
//                }
//
//            } else {
                if let id = self.handleLaboratoryOrdersInCoreData(object: order, pdf: nil, authenticated: true, patientObject: patient) {
                    completedCount += 1
                } else {
                    errorArrayCount += 1
                }
//            }
        }
        self.decrementLoadCounter()
        let error: String? = errorArrayCount > 0 ? .genericErrorMessage : nil
        // For now, just calling success so that the entire fetch can pass
        self.fetchStatusList.fetchStatus[.LaboratoryOrders] = FetchStatus(requestCompleted: true, attemptedCount: errorArrayCount + completedCount, successfullCount: completedCount, error: error)
    }
    
    private func handleLaboratoryOrdersInCoreData(object: AuthenticatedLaboratoryOrdersResponseObject.ResourcePayload.Order, pdf: String?, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject) -> String? {
        incrementLoadCounter()
        
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
        guard let object = StorageService.shared.storeLaboratoryOrder(patient: patient, gateWayObject: object, pdf: pdf) else {
            self.decrementLoadCounter()
            return nil
        }
        self.decrementLoadCounter()
        return object.id
    }
}

// MARK: Handle Immunizations in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleImmunizationsInCoreData(immunizations: AuthenticatedImmunizationsResponseObject) {
        
        guard let patient = self.patientDetails else { return }
        guard let immz = immunizations.resourcePayload?.immunizations else { return }
        incrementLoadCounter()
        
        StorageService.shared.deleteHealthRecordsForAuthenticatedUser(types: [.Immunization])
        var errorArrayCount: Int = 0
        var completedCount: Int = 0
        guard let authCreds = self.authCredentials else {
            self.decrementLoadCounter()
            return
        }
        for immunization in immz {
            if let id = self.handleImmunizationsInCoreData(object: immunization, authenticated: true, patientObject: patient) {
                completedCount += 1
            } else {
                errorArrayCount += 1
            }
            
        }
        self.decrementLoadCounter()
        let error: String? = errorArrayCount > 0 ? .genericErrorMessage : nil
        // For now, just calling success so that the entire fetch can pass
        self.fetchStatusList.fetchStatus[.Immunizations] = FetchStatus(requestCompleted: true, attemptedCount: errorArrayCount + completedCount, successfullCount: completedCount, error: error)
    }
    
    private func handleImmunizationsInCoreData(object: AuthenticatedImmunizationsResponseObject.ResourcePayload.Immunization, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject) -> String? {
        
        incrementLoadCounter()
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
        
        
        guard let object = StorageService.shared.storeImmunization(patient: patient, object: object, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
       
        self.decrementLoadCounter()
        return object.id
    }
}


// MARK: Handle Immunization Recommendations in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleImmunizationsRecommendationsInCoreData(payload: AuthenticatedImmunizationsResponseObject) {
        
        guard let patient = self.patientDetails else { return }
        guard let objects = payload.resourcePayload?.recommendations else { return }

        
        StorageService.shared.deleteHealthRecordsForAuthenticatedUser(types: [.Recommendation])
        guard let authCreds = self.authCredentials else {
            return
        }
        for object in objects {
            _ = self.handleImmunizationsRecommendationsInCoreData(object: object, authenticated: true, patientObject: patient)
            
        }
    }
    
    private func handleImmunizationsRecommendationsInCoreData(object: AuthenticatedImmunizationsResponseObject.ResourcePayload.Recommendation, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject) -> String? {
        
        incrementLoadCounter()
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
        
        guard let object = StorageService.shared.storeRecommendation(patient: patient, object: object, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
       
        self.decrementLoadCounter()
        return object.recommendationSetID
    }
}
// MARK: Handle Health Visits in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleHealthVisitsInCoreData(healthVisits: AuthenticatedHealthVisitsResponseObject) {
        guard let patient = self.patientDetails else { return }
        guard let healthVisitList = healthVisits.resourcePayload else { return }
        incrementLoadCounter()
        
        StorageService.shared.deleteHealthRecordsForAuthenticatedUser(types: [.HealthVisit])
        var errorArrayCount: Int = 0
        var completedCount: Int = 0
        guard let authCreds = self.authCredentials else {
            self.decrementLoadCounter()
            return
        }
        for healthVisit in healthVisitList {
            if let id = self.handleHealthVisitsInCoreData(object: healthVisit, authenticated: true, patientObject: patient) {
                completedCount += 1
            } else {
                errorArrayCount += 1
            }
            
        }
        self.decrementLoadCounter()
        let error: String? = errorArrayCount > 0 ? .genericErrorMessage : nil
        // For now, just calling success so that the entire fetch can pass
        self.fetchStatusList.fetchStatus[.HealthVisits] = FetchStatus(requestCompleted: true, attemptedCount: errorArrayCount + completedCount, successfullCount: completedCount, error: error)
    }
    
    private func handleHealthVisitsInCoreData(object: AuthenticatedHealthVisitsResponseObject.HealthVisit, authenticated: Bool, patientObject: AuthenticatedPatientDetailsResponseObject) -> HealthVisit? {
        
        incrementLoadCounter()
        
        guard let patient = StorageService.shared.fetchOrCreatePatient(phn: patientObject.resourcePayload?.personalhealthnumber, name: patientObject.getFullName, birthday: patientObject.getBdayDate, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
        
        guard let object = StorageService.shared.storeHealthVisit(patient: patient, object: object, authenticated: authenticated) else {
            self.decrementLoadCounter()
            return nil
        }
        self.decrementLoadCounter()
        return object
    }
}

// MARK: Handle Comments in core data
extension AuthenticatedHealthRecordsAPIWorker {
    private func handleCommentsInCoredata(comments: AuthenticatedCommentResponseObject) {
        incrementLoadCounter()
        // TODO: Maybe we should look at making this synchronus
        StorageService.shared.storeComments(in: comments)
        // Note: Attempted and successful counts are 0 as we aren't displaying how many comments have been fetched, just happens in the background
        self.fetchStatusList.fetchStatus[.Comments] = FetchStatus(requestCompleted: true, attemptedCount: 0, successfullCount: 0, error: nil)
        decrementLoadCounter()
    }
}

// MARK: Structs used for various fetch types
struct AuthenticatedAPIWorkerRetryDetails {
    var authenticatedPatientDetails: AuthenticatedPatientDetails?
    var authenticatedQueueItPingTestResultsDetails: AuthenticatedQueueItPingTestResultsDetails?
    var authenticatedVaccineCardDetails: AuthenticatedVaccineCardDetails?
    var authenticatedTestResultsDetails: AuthenticatedTestResultsDetails?
    var authenticatedMedicationStatementDetails: AuthenticatedMedicationStatementDetails?
    var authenticatedSpecialAuthorityDrugsDetails: AuthenticatedSpecialAuthorityDrugsDetails?
    var authenticatedLaboratoryOrdersDetails: AuthenticatedLaboratoryOrdersDetails?
    var authenticatedImmunizationsDetails: AuthenticatedImmunizationsDetails?
    var authenticatedHealthVisitsDetails: AuthenticatedHealthVisitsDetails?
    var authenticatedCommentsDetails: AuthenticatedCommentsDetails?
    var authenticatedLabOrderPDFDetails: AuthenticatedLabOrderPDFDetails?
    var authenticatedCovidTestPDFDetails: AuthenticatedCovidTestPDFDetails?
    
    struct AuthenticatedPatientDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
    
    struct AuthenticatedQueueItPingTestResultsDetails {
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
    
    struct AuthenticatedSpecialAuthorityDrugsDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
    
    struct AuthenticatedLaboratoryOrdersDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
    
    struct AuthenticatedImmunizationsDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
    
    struct AuthenticatedHealthVisitsDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
    
    struct AuthenticatedCommentsDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
    
    struct AuthenticatedLabOrderPDFDetails {
        var authCredentials: AuthenticationRequestObject
        var queueItToken: String?
    }
    
    struct AuthenticatedCovidTestPDFDetails {
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
    
    var getFetchStatusTypes: [AuthenticationFetchType] {
        guard fetchStatus.count > 0 else { return [] }
        return fetchStatus.map { $0.key }
    }
    
    var isCompleted: Bool {
        guard fetchStatus.count > 0 else { return false }
        return fetchStatus.count == fetchStatus.map({ $0.value.requestCompleted }).filter({ $0 == true }).count
    }
    
    var canFetchComments: Bool {
        var tempCommentsList = fetchStatus
        tempCommentsList.removeValue(forKey: .Comments)
        guard tempCommentsList.count > 0 else { return false }
        return tempCommentsList.count == tempCommentsList.map({ $0.value.requestCompleted }).filter({ $0 == true }).count
    }
    
    var isStatusListMoreThanJustComments: Bool {
        var tempList = fetchStatus
        tempList.removeValue(forKey: .Comments)
        return tempList.count > 0
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

// MARK: Initialize and deinit of fetch status values
extension AuthenticatedHealthRecordsAPIWorker {
    // TODO: Should make this a little more clean, seems pretty clunky right now
    private func initializeFetchStatusList(withSpecificTypes types: [AuthenticationFetchType]?) {
        guard let types = types else {
            self.fetchStatusList = FetchStatusList(fetchStatus: [
                .VaccineCard : FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0),
                .TestResults : FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0),
                .MedicationStatement : FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0),
                .SpecialAuthorityDrugs: FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0),
                .LaboratoryOrders : FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0),
                .Immunizations: FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0),
                .HealthVisits: FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0),
                .Comments : FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0)
            ])
            return
        }
        for type in types {
            fetchStatusList.fetchStatus[type] = FetchStatus(requestCompleted: false, attemptedCount: 0, successfullCount: 0)
        }
    }
    
    private func deinitializeStatusList() {
        self.fetchStatusList = FetchStatusList(fetchStatus: [:])
    }
}

extension AuthenticatedHealthRecordsAPIWorker {
    private func decrementLoadCounter() {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.dataLoadCount -= 1
            }
        }
       
    }
    
    private func incrementLoadCounter() {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.dataLoadCount += 1
            }
        }
    }
}
