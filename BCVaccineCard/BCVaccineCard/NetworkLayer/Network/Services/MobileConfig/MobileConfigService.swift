//
//  MobileConfigService.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-11-03.
//

import Foundation

struct MobileConfigService {
    let network: Network
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    func fetchConfig(completion: @escaping (MobileConfigurationResponseObject?)->Void) {
        guard NetworkConnection.shared.hasConnection else {
            return completion(MobileConfigStorage.cachedConfig)
        }
        network.addLoader(message: .empty)
        let request = NetworkRequest<DefaultParams, MobileConfigurationResponseObject>(
            url: UrlAccessor.mobileConfigURL,
            type: .Get,
            parameters: nil,
            headers: nil,
            completion: { responseData in
                if let response = responseData {
                    MobileConfigStorage.store(config: response)
                }
                self.network.removeLoader()
                return completion(responseData)
            }, onError: nil)
        network.request(with: request)
    }
}
