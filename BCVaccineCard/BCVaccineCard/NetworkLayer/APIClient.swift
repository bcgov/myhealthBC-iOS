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
    
    func getAuthenticatedPatientDetails(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedPatientDetailsResponseObject>) {
        
        let url = configureURL(token: token, endpoint: self.endpoints.getAuthenticatedPatientDetails(hdid: authCredentials.hdid))
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
    }
    
    func getAuthenticatedMedicationStatement(_ authCredentials: AuthenticationRequestObject, token: String?, executingVC: UIViewController, includeQueueItUI: Bool, completion: @escaping NetworkRequestCompletion<AuthenticatedMedicationStatementResponseObject>) {
        
        let url = configureURL(token: token, endpoint: self.endpoints.getAuthenticatedMedicationStatement(hdid: authCredentials.hdid))
        
        let headerParameters: Headers = [
            Constants.AuthenticationHeaderKeys.authToken: authCredentials.bearerAuthToken
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, checkQueueIt: true, executingVC: executingVC, includeQueueItUI: includeQueueItUI, andCompletion: completion)
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
