//
//  RemoteRequestAccessor.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
// https://test.healthgateway.gov.bc.ca/api/immunizationservice/v1/api/VaccineStatus

//import Foundation
//
//protocol HealthGatewayBCAccessor {
//    func requestVaccineCard(_ model: GatewayVaccineCardRequest,
//                            token: String?,
//                            completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>)
//}
//
//struct RemoteRequestAccessor {
//    let accessor: RemoteAccessor
//    let endpointsAccessor: EndpointsAccessor
//}
//
//extension RemoteRequestAccessor: HealthGatewayBCAccessor {
//    
//    func requestVaccineCard(_ model: GatewayVaccineCardRequest, token: String?, completion: @escaping NetworkRequestCompletion<GatewayVaccineCardResponse>) {
//        let interceptor = NetworkRequestInterceptor()
//        var url: URL?
//        if let token = token {
//            let queryItems = [URLQueryItem(name: Constants.QueueItStrings.queueittoken, value: token)]
//            var urlComps = URLComponents(string: self.endpointsAccessor.getVaccineCard.absoluteString)
//            urlComps?.queryItems = queryItems
//            url = urlComps?.url
//        } else {
//            url = self.endpointsAccessor.getVaccineCard
//        }
//
//        let headerParameters: Headers = [
//            Constants.GatewayVaccineCardRequestParameters.phn: model.phn,
//            Constants.GatewayVaccineCardRequestParameters.dateOfBirth: model.dateOfBirth,
//            Constants.GatewayVaccineCardRequestParameters.dateOfVaccine: model.dateOfVaccine
//        ]
//        guard let unwrappedURL = url else { return }
//        self.accessor.request(withURL: unwrappedURL, method: .get, headers: headerParameters, interceptor: interceptor, andCompletion: completion)
//    }    
//}

class QueueItLocal {
    
    static func saveValueToDefaults(customerID: String? = nil, eventAlias: String? = nil, queueitToken: String? = nil, cookieHeader: [String: String]? = nil) {
        if let customerID = customerID {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.customerID = customerID
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: customerID, eventAlias: nil, queueitToken: nil, cookieHeader: nil)
            }
        }
        if let eventAlias = eventAlias {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.eventAlias = eventAlias
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: nil, eventAlias: eventAlias, queueitToken: nil, cookieHeader: nil)
            }
        }
        if let queueitToken = queueitToken {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.queueitToken = queueitToken
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: nil, eventAlias: nil, queueitToken: queueitToken, cookieHeader: nil)
            }
        }
        if let cookieHeader = cookieHeader {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.cookieHeader = cookieHeader
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: customerID, eventAlias: nil, queueitToken: nil, cookieHeader: cookieHeader)
            }
        }
    }
    
    static func fetchValueFromDefaults() -> QueueItCachedObject? {
        guard let cached = Defaults.cachedQueueItObject else { return nil }
        return cached
    }
}
