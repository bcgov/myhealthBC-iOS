//
//  UpdateManager.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-02.
//

import Foundation
import KeychainAccess

struct UpdateManager {
    
    let network: Network
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    func isUpdateAvailableInStore(completion: @escaping (Bool)->Void) {
        guard let currentVersion = UpdateManagerStorage.currentAppVersion,
              let bundleId = UpdateManagerStorage.bundleId,
              NetworkConnection.shared.hasConnection
        else {
            return completion(false)
        }
        
        let url = URL(string: "https://itunes.apple.com/ca/lookup?bundleId=\(bundleId)")!
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
        UpdateManagerStorage.setOrResetstoredAppVersion()
        guard NetworkConnection.shared.hasConnection else {
            return completion(false)
        }
        let request = NetworkRequest<DefaultParams, MobileConfigurationResponseObject>(
            url: endpoints.mobileConfiguration,
            type: .Get,
            parameters: nil,
            headers: nil,
            completion: { responseData in
                guard let response = responseData, let latest = response.version else {
                    return completion(false)
                }
                
                guard let current = UpdateManagerStorage.storedCofigVersion else {
                    UpdateManagerStorage.storeConfig(version: latest)
                    return completion(false)
                }
                
                return completion(current < latest)
        })
        network.request(with: request)
    }
}
