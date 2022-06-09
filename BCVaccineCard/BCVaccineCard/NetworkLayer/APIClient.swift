//
//  HealthGatewayBCWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
//

import UIKit

class APIClientCache {
    struct ConfigureURLQueueObject {
        let endpoint: URL
        let callback: (URL?)->Void
    }
    
    static var isCookieSet: Bool = false {
        didSet {
            settingCookie = false
            executeConfigureURLQueue()
        }
    }
    static var settingCookie: Bool = false
    static var configureURLQueue: [ConfigureURLQueueObject] = []
    
    static func executeConfigureURLQueue() {
        while !configureURLQueue.isEmpty {
            if let element = configureURLQueue.popLast() {
                element.callback(element.endpoint)
            }
        }
    }
}

class APIClient {
    
    private var delegateOwner: UIViewController
    private var interceptor: Interceptor
    
    

    
    init(delegateOwner: UIViewController, interceptor: Interceptor = NetworkRequestInterceptor()) {
        self.delegateOwner = delegateOwner
        self.interceptor = interceptor
    }
    
    private var endpoints: EndpointsAccessor {
        return UrlAccessor()
    }
    
    private var remote: RemoteAccessor {
        return NetworkAccessor()
    }
    
    func getVaccineCard(_ model: GatewayVaccineCardRequest, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>) {
        configureURL(token: token, endpoint: self.endpoints.getVaccineCard, completion: { url in
            let headerParameters: Headers = [
                Constants.GatewayVaccineCardRequestParameters.phn: model.phn,
                Constants.GatewayVaccineCardRequestParameters.dateOfBirth: model.dateOfBirth,
                Constants.GatewayVaccineCardRequestParameters.dateOfVaccine: model.dateOfVaccine
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: self.interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
    }
    
    func getTestResult(_ model: GatewayTestResultRequest, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<GatewayTestResultResponse>) {
        configureURL(token: token, endpoint: self.endpoints.getTestResults, completion: { url in
            let headerParameters: Headers = [
                Constants.GatewayTestResultsRequestParameters.phn: model.phn,
                Constants.GatewayTestResultsRequestParameters.dateOfBirth: model.dateOfBirth,
                Constants.GatewayTestResultsRequestParameters.collectionDate: model.collectionDate
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: self.interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
    }
    
    func getAuthenticatedVaccineCard(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>) {
        configureURL(token: token, endpoint: self.endpoints.getAuthenticatedVaccineCard, completion: { url in
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken,
            ]
            
            let parameters: [String: String] = [
                Constants.AuthenticationHeaderKeys.hdid: authCredentials.hdid
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, parameters: parameters, interceptor: self.interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletionHandler: completion)
        })
        
        
    }
    
    func getAuthenticatedTestResults(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedTestResultsResponseModel>) {
        configureURL(token: token, endpoint: self.endpoints.getAuthenticatedTestResults, completion: { url in
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken,
            ]
            
            let parameters: [String: String] = [
                Constants.AuthenticationHeaderKeys.hdid: authCredentials.hdid
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, parameters: parameters, interceptor: self.interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletionHandler: completion)
        })
    }
    
    func getAuthenticatedLaboratoryOrders(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedLaboratoryOrdersResponseObject>) {
        configureURL(token: token, endpoint: self.endpoints.getAuthenticatedLaboratoryOrders, completion: { url in
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken,
            ]
            
            let parameters: [String: String] = [
                Constants.AuthenticationHeaderKeys.hdid: authCredentials.hdid
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, parameters: parameters, interceptor: self.interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletionHandler: completion)
        })
        
    }
    
    func getAuthenticatedPatientDetails(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedPatientDetailsResponseObject>) {
        configureURL(token: nil, endpoint: self.endpoints.getAuthenticatedPatientDetails(hdid: authCredentials.hdid), completion: { url in
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: self.interceptor, checkQueueIt: false, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
        
        
    }
    
    func getAuthenticatedMedicationStatement(_ authCredentials: AuthenticationRequestObject, protectiveWord: String? = nil, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedMedicationStatementResponseObject>) {
        configureURL(token: token, endpoint: self.endpoints.getAuthenticatedMedicationStatement(hdid: authCredentials.hdid), completion: { url in
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken,
                Constants.AuthenticatedMedicationStatementParameters.protectiveWord: (protectiveWord ?? "")
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: self.interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
    }
    
    func getAuthenticatedComments(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedCommentResponseObject>) {
        configureURL(token: token, endpoint: self.endpoints.authenticatedComments(hdid: authCredentials.hdid), completion: { url in
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: self.interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
        
        
    }
    
    func getAuthenticatedLabTestPDF(_ authCredentials: AuthenticationRequestObject, token: String?, reportId: String, executingVC: UIViewController, includeQueueItUI: Bool, type: LabTestType, completion: @escaping NetworkRequestCompletion<AuthenticatedPDFResponseObject>) {
        configureURL(token: token, endpoint: self.endpoints.getAuthenticatedLabTestPDF(repordId: reportId), completion: { url in
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
            ]
            
            let parameters = AuthenticatedPDFRequestObject(hdid: authCredentials.hdid, isCovid19: type.getBoolStringValue)
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, parameters: parameters, interceptor: self.interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletionHandler: completion)
        })
    }
    
}

// MARK: For throttling HG
extension APIClient {
    func throttleHGMobileConfig(token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<MobileConfigurationResponseObject>) {
        configureURL(token: nil, endpoint: self.endpoints.throttleHG, completion: { url in
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, interceptor: self.interceptor, checkQueueIt: false, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
    }
}

// MARK: For fetching the base URL
extension APIClient {
    func getBaseURLFromMobileConfig(token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping(String?) -> Void) {
        self.getBaseUrlAPILogic(token: token, executingVC: executingVC, includeQueueItUI: includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.getBaseUrlAPILogic(token: queueItToken, executingVC: executingVC, includeQueueItUI: includeQueueItUI) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleBaseURLResponse(result: result, completion: completion)
                }
            } else {
                self.handleBaseURLResponse(result: result, completion: completion)
            }
        }
    }
    
    private func getBaseUrlAPILogic(token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<MobileConfigurationResponseObject>) {
        configureURL(token: nil, endpoint: self.endpoints.getBaseURL, completion: { url in
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, interceptor: self.interceptor, checkQueueIt: false, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
    }
    
    private func handleBaseURLResponse(result: Result<MobileConfigurationResponseObject, ResultError>, completion: @escaping(String?) -> Void) {
        switch result {
        case .success(let configResponse):
            completion(configResponse.baseUrl)
        case .failure(let error):
            Logger.log(string: error.localizedDescription, type: .Network)
            completion(nil)
        }
    }
}

// MARK: For validating age
extension APIClient {
    
    func checkIfProfileIsValid(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping (Bool?, ResultError?) -> Void) {
        self.getValidateProfileStatus(authCredentials, token: nil, executingVC: executingVC, includeQueueItUI: includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.getValidateProfileStatus(authCredentials, token: queueItToken, executingVC: executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleValidationResponse(result: result, completion: completion)
                }
            } else {
                self.handleValidationResponse(result: result, completion: completion)
            }
        }
    }
    
    private func getValidateProfileStatus(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedValidAgeCheck>) {
        configureURL(token: nil, endpoint: self.endpoints.validateProfile(hdid: authCredentials.hdid), completion: { url in
            
            
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: self.interceptor, checkQueueIt: false, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
    }
    
    private func handleValidationResponse(result: Result<AuthenticatedValidAgeCheck, ResultError>, completion: @escaping(Bool?, ResultError?) -> Void) {
        switch result {
        case .success(let validation):
            if let resultError = validation.resultError, validation.resourcePayload == nil {
                completion(nil, resultError)
            } else if let valid = validation.resourcePayload {
                completion(valid, nil)
            } else {
                completion(false, nil)
            }
        case .failure(let error):
            Logger.log(string: error.localizedDescription, type: .Network)
            completion(nil, error)
        }
    }
}

// MARK: For handling user profile, used for terms of service check
extension APIClient {
    
    // This function is used to check if user has accepted terms of service or not
    func hasUserAcceptedTermsOfService(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping (Bool?, ResultError?) -> Void) {
        self.getUserProfile(authCredentials, token: nil, executingVC: executingVC, includeQueueItUI: includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.getUserProfile(authCredentials, token: queueItToken, executingVC: executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleGetUserProfileResponse(result: result, completion: completion)
                }
            } else {
                self.handleGetUserProfileResponse(result: result, completion: completion)
            }
        }
        
    }
    
    private func getUserProfile(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedUserProfileResponseObject>) {
        configureURL(token: nil, endpoint: self.endpoints.userProfile(hdid: authCredentials.hdid), completion: { url in
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
            ]
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: self.interceptor, checkQueueIt: false, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
    }
    
    private func handleGetUserProfileResponse(result: Result<AuthenticatedUserProfileResponseObject, ResultError>, completion: @escaping(Bool?, ResultError?) -> Void) {
        switch result {
        case .success(let profile):
            if profile.resourcePayload?.hdid == nil || profile.resourcePayload?.acceptedTermsOfService == false {
                completion(false, nil)
            } else if let accepted = profile.resourcePayload?.acceptedTermsOfService, accepted == true {
                completion(true, nil)
            } else if let resultError = profile.resultError {
                completion(nil, resultError)
            } else {
                let error = ResultError(resultMessage: "An unexpected error has occured")
                completion(nil, error)
            }
        case .failure(let error):
            Logger.log(string: error.localizedDescription, type: .Network)
            completion(nil, error)
        }
    }
    
    // This function is used to respond to the displayed terms of service
    func respondToTermsOfService(_ authCredentials: AuthenticationRequestObject, accepted: Bool, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping (Bool?, ResultError?) -> Void) {
        self.postUserProfile(authCredentials, accepted: accepted, token: nil, executingVC: executingVC, includeQueueItUI: includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.postUserProfile(authCredentials, accepted: accepted, token: queueItToken, executingVC: executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handlePostUserProfileResponse(result: result, completion: completion)
                }
            } else {
                self.handlePostUserProfileResponse(result: result, completion: completion)
            }
        }
    }
    
    private func postUserProfile(_ authCredentials: AuthenticationRequestObject, accepted: Bool, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedUserProfileResponseObject>) {
        configureURL(token: nil, endpoint: self.endpoints.userProfile(hdid: authCredentials.hdid), completion: { url in
            
            let headerParameters: Headers = [
                Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
            ]
            
            let parameters = AuthenticatedUserProfileRequestObject(profile: AuthenticatedUserProfileRequestObject.ResourcePayload(hdid: authCredentials.hdid, acceptedTermsOfService: accepted))
            
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .post, headers: headerParameters, parameters: parameters, interceptor: self.interceptor, checkQueueIt: false, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletionHandler: completion)
        })
        
    }
    
    private func handlePostUserProfileResponse(result: Result<AuthenticatedUserProfileResponseObject, ResultError>, completion: @escaping(Bool?, ResultError?) -> Void) {
        switch result {
        case .success(let profile):
            if profile.resourcePayload?.hdid == nil {
                let error = ResultError(resultMessage: "There was an error with your request")
                completion(nil, error)
            } else if let _ = profile.resourcePayload?.hdid, let acceptedStatus = profile.resourcePayload?.acceptedTermsOfService {
                completion(acceptedStatus, nil)
            } else if let resultError = profile.resultError {
                completion(nil, resultError)
            } else {
                let error = ResultError(resultMessage: "An unexpected error has occured")
                completion(nil, error)
            }
        case .failure(let error):
            Logger.log(string: error.localizedDescription, type: .Network)
            completion(nil, error)
        }
    }
}
// MARK: For displaying terms of service
extension APIClient {
    
    func getTermsOfServiceString(token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping (String?, ResultError?) -> Void) {
        self.getTermsOfService(token: nil, executingVC: executingVC, includeQueueItUI: includeQueueItUI) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.getTermsOfService(token: queueItToken, executingVC: executingVC, includeQueueItUI: false) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleTermsOfServiceResponse(result: result, completion: completion)
                }
            } else {
                self.handleTermsOfServiceResponse(result: result, completion: completion)
            }
        }
        
        
    }
    
    private func getTermsOfService(token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<TermsOfServiceResponse>) {
        configureURL(token: nil, endpoint: self.endpoints.getTermsOfService, completion: { url
            in
            guard let unwrappedURL = url else { return }
            self.remote.request(withURL: unwrappedURL, method: .get, interceptor: self.interceptor, checkQueueIt: false, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
        })
        
        
    }
    
    private func handleTermsOfServiceResponse(result: Result<TermsOfServiceResponse, ResultError>, completion: @escaping (String?, ResultError?) -> Void) {
        switch result {
        case .success(let termsOfService):
            if let resultError = termsOfService.resultError, termsOfService.resourcePayload == nil {
                completion(nil, resultError)
            } else if let content = termsOfService.resourcePayload?.content {
                completion(content, nil)
            } else {
                let error = ResultError(resultMessage: "We're sorry, there was an issue fetching terms of service.")
                completion(nil, error)
            }
        case .failure(let error):
            Logger.log(string: error.localizedDescription, type: .Network)
            completion(nil, error)
        }
    }
}


// MARK: QUEUEIT Logic here
extension APIClient {
    
    func configureURL(token: String?, endpoint: URL, completion: @escaping(URL?)->Void) {
        
        if let token = token {
            if APIClientCache.isCookieSet {
                return completion(endpoint)
            }
            
            if APIClientCache.settingCookie {
                APIClientCache.configureURLQueue.append(APIClientCache.ConfigureURLQueueObject(endpoint: endpoint, callback: completion))
                return
            }
            APIClientCache.settingCookie = true
            let queryItems = [URLQueryItem(name: Constants.QueueItStrings.queueittoken, value: token)]
            var urlComps = URLComponents(string: endpoint.absoluteString)
            urlComps?.queryItems = queryItems
            return completion(urlComps?.url)
        } else {
            return completion(endpoint)
        }
        
    }
}

extension URL {
    func hasQueueItToken() -> Bool {
        let urlString = self.absoluteString
        return urlString.contains("queueittoken")
    }
}
