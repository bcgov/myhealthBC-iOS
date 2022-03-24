//
//  HealthGatewayBCWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
//

import UIKit

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
        let url = configureURL(token: token, endpoint: self.endpoints.getVaccineCard)
        
        let headerParameters: Headers = [
            Constants.GatewayVaccineCardRequestParameters.phn: model.phn,
            Constants.GatewayVaccineCardRequestParameters.dateOfBirth: model.dateOfBirth,
            Constants.GatewayVaccineCardRequestParameters.dateOfVaccine: model.dateOfVaccine
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
    }
    
    func getTestResult(_ model: GatewayTestResultRequest, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<GatewayTestResultResponse>) {
        let url = configureURL(token: token, endpoint: self.endpoints.getTestResults)
        
        let headerParameters: Headers = [
            Constants.GatewayTestResultsRequestParameters.phn: model.phn,
            Constants.GatewayTestResultsRequestParameters.dateOfBirth: model.dateOfBirth,
            Constants.GatewayTestResultsRequestParameters.collectionDate: model.collectionDate
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
    }
    
    func getAuthenticatedVaccineCard(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>) {
        let url = configureURL(token: token, endpoint: self.endpoints.getAuthenticatedVaccineCard)
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken,
        ]
        
        let parameters: [String: String] = [
            Constants.AuthenticationHeaderKeys.hdid: authCredentials.hdid
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, parameters: parameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletionHandler: completion)
    }
    
    func getAuthenticatedTestResults(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedTestResultsResponseModel>) {
        let url = configureURL(token: token, endpoint: self.endpoints.getAuthenticatedTestResults)
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken,
        ]
        
        let parameters: [String: String] = [
            Constants.AuthenticationHeaderKeys.hdid: authCredentials.hdid
        ]
       
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, parameters: parameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletionHandler: completion)
    }
    
    func getAuthenticatedLaboratoryOrders(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedLaboratoryOrdersResponseObject>) {
        let url = configureURL(token: token, endpoint: self.endpoints.getAuthenticatedLaboratoryOrders)
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken,
        ]
        
        let parameters: [String: String] = [
            Constants.AuthenticationHeaderKeys.hdid: authCredentials.hdid
        ]
       
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, parameters: parameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletionHandler: completion)
    }
    
    func getAuthenticatedPatientDetails(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedPatientDetailsResponseObject>) {
        let url = configureURL(token: token, endpoint: self.endpoints.getAuthenticatedPatientDetails(hdid: authCredentials.hdid))
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
    }
    
    func getAuthenticatedMedicationStatement(_ authCredentials: AuthenticationRequestObject, protectiveWord: String? = nil, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedMedicationStatementResponseObject>) {
        let url = configureURL(token: token, endpoint: self.endpoints.getAuthenticatedMedicationStatement(hdid: authCredentials.hdid))
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken,
            Constants.AuthenticatedMedicationStatementParameters.protectiveWord: (protectiveWord ?? "")
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
    }
    
    func getAuthenticatedComments(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedCommentResponseObject>) {
        let url = configureURL(token: token, endpoint: self.endpoints.authenticatedComments(hdid: authCredentials.hdid))
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
    }
    
    func getAuthenticatedLaboratoryOrderPDF(_ authCredentials: AuthenticationRequestObject, token: String?, reportId: String, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedPDFResponseObject>) {
        let url = configureURL(token: token, endpoint: self.endpoints.getAuthenticatedLaboratoryOrderPDF(repordId: reportId))
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken,
            Constants.AuthenticationHeaderKeys.hdid: authCredentials.hdid
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
    }
    
}

// MARK: For validating age
extension APIClient {
    
    func checkIfProfileIsValid(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping (Bool?, ResultError?) -> Void) {
        self.getValidateProfileStatus(authCredentials, token: token, executingVC: executingVC, includeQueueItUI: includeQueueItUI) { [weak self] result, queueItRetryStatus in
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
        let url = configureURL(token: token, endpoint: self.endpoints.validateProfile(hdid: authCredentials.hdid))
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
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
            print(error)
            completion(nil, error)
        }
    }
}

// MARK: For displaying terms of service
extension APIClient {
    
    func getTermsOfServiceString(token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping (String?, ResultError?) -> Void) {
        self.getTermsOfService(token: token, executingVC: executingVC, includeQueueItUI: includeQueueItUI) { [weak self] result, queueItRetryStatus in
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
        let url = configureURL(token: token, endpoint: self.endpoints.getTermsOfService)
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
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
            print(error)
            completion(nil, error)
        }
    }
}

// MARK: QUEUEIT Logic here
extension APIClient {
    
    func configureURL(token: String?, endpoint: URL) -> URL? {
        var url: URL?
        if let token = token {
            let queryItems = [URLQueryItem(name: Constants.QueueItStrings.queueittoken, value: token)]
            var urlComps = URLComponents(string: endpoint.absoluteString)
            urlComps?.queryItems = queryItems
            url = urlComps?.url
        } else {
            url = endpoint
        }
        return url
    }
}
