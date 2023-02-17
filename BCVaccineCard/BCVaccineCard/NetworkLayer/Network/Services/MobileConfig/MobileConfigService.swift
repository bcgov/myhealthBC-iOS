//
//  MobileConfigService.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-11-03.
//

import Foundation

class MobileConfigService {
    let network: Network

    private var callers: [((MobileConfigurationResponseObject?)->Void)] = []
    
    init(network: Network) {
        self.network = network
    }
    
    func fetchConfig(completion: @escaping (MobileConfigurationResponseObject?)->Void) {
        if !callers.isEmpty {
            callers.append(completion)
            return
        }
        callers.append(completion)
        if let cache = MobileConfigStorage.cachedConfig {
            let timeDiff = Date().timeIntervalSince(cache.datetime)
            if timeDiff <= 5 {
                return completion(cache.config)
            }
            print(timeDiff)
        }
        
        guard NetworkConnection.shared.hasConnection else {
            return completion(MobileConfigStorage.offlineConfig)
        }
        let request = NetworkRequest<DefaultParams, MobileConfigurationResponseObject>(
            url: Constants.Network.MobileConfig,
            type: .Get,
            parameters: nil,
            headers: nil,
            completion: { responseData in
                if let response = responseData {
                    MobileConfigStorage.store(config: response)
                }
                while !self.callers.isEmpty {
                    if let callback = self.callers.popLast() {
                        callback(responseData)
                    }
                }
                return
            })
        network.request(with: request)
    }
}
