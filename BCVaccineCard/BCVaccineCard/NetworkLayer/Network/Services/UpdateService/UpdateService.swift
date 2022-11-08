//
//  UpdateManager.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-02.
//

import Foundation
import KeychainAccess
import StoreKit

struct UpdateService {
    
    let network: Network
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    func isUpdateAvailableInStore(completion: @escaping (Bool)->Void) {
        guard let currentVersion = UpdateServiceStorage.currentAppVersion,
              let bundleId = UpdateServiceStorage.bundleId,
              NetworkConnection.shared.hasConnection
        else {
            return completion(false)
        }
        
        let storeURL = "https://itunes.apple.com/ca/lookup?bundleId=\(bundleId)"
        let url = URL(string: storeURL)!
        let request = NetworkRequest<DefaultParams, AppStoreVersionData>(
            url: url,
            type: .Get,
            parameters: nil,
            headers: nil,
            completion: { responseData in
                guard let response = responseData,
                      let results = response.results,
                      !results.isEmpty,
                      let last = results.last,
                      let storeVersion = last.version
                else {
                    return completion(false)
                }
                return completion(storeVersion > currentVersion)
        })
        network.request(with: request)
    }
    
    func isBreakingConfigChangeAvailable(completion: @escaping (Bool)->Void) {
        UpdateServiceStorage.setOrResetstoredAppVersion()
        
        MobileConfigService(network: network).fetchConfig { responseData in
            guard let response = responseData, let latest = response.version else {
                return completion(false)
            }
            
            guard let current = UpdateServiceStorage.appCofigVersion else {
                UpdateServiceStorage.storeConfig(version: latest)
                return completion(false)
            }
            return completion(current < latest)
        }
    }
}
