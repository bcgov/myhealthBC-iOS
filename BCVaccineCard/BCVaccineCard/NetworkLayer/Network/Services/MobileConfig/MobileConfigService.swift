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
        if let cache = MobileConfigStorage.cachedConfig {
            let timeDiff = Date().timeIntervalSince(cache.datetime)
            if timeDiff <= 5 {
                Logger.log(string: "MobileConfigService returning cached", type: .Network)
                return completion(cache.config)
            }
            Logger.log(string: "MobileConfigService timediff = \(timeDiff)", type: .Network)
        }
        
        if !callers.isEmpty {
            Logger.log(string: "MobileConfigService queuing", type: .Network)
            callers.append(completion)
            return
        }
        callers.append(completion)
        
        guard NetworkConnection.shared.hasConnection else {
            Logger.log(string: "MobileConfigService Offline", type: .Network)
            return completion(MobileConfigStorage.offlineConfig)
        }
        network.addLoader(message: .empty)
        let request = NetworkRequest<DefaultParams, MobileConfigurationResponseObject>(
            url: Constants.Network.MobileConfig,
            type: .Get,
            parameters: nil,
            headers: nil,
            completion: { responseData in
                self.network.removeLoader()
                Logger.log(string: "MobileConfigService response received", type: .Network)
                if let response = responseData {
                    MobileConfigStorage.store(config: response)
                }
                while !self.callers.isEmpty {
                    if let callback = self.callers.popLast() {
                        callback(responseData)
                    }
                }
                Logger.log(string: "MobileConfigService responded to callers", type: .Network)
                return
            })
        Logger.log(string: "MobileConfigService Calling", type: .Network)
        network.request(with: request)
    }
}
