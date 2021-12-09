//
//  HealthGatewayBCWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
//

import Foundation

class APIClient {
        
    init() {
        
    }
    
    private let endpoints: EndpointsAccessor = {
       return UrlAccessor()
    }()
    
    private let remote: RemoteAccessor = {
        return NetworkAccessor()
    }()
    
    // TODO: Include interceptor and queue it logic here
    
    func getVaccineCard(_ model: GatewayVaccineCardRequest, token: String?, completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>) {
        let interceptor = NetworkRequestInterceptor()
        let url = configureURL(token: token, endpoint: self.endpoints.getVaccineCard)
        
        let headerParameters: Headers = [
            Constants.GatewayVaccineCardRequestParameters.phn: model.phn,
            Constants.GatewayVaccineCardRequestParameters.dateOfBirth: model.dateOfBirth,
            Constants.GatewayVaccineCardRequestParameters.dateOfVaccine: model.dateOfVaccine
        ]
        
        guard let unwrappedURL = url else { return }
        self.remote.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, andCompletion: completion)
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
    
    
    func queueItInitialRequest() {
        
    }
}
