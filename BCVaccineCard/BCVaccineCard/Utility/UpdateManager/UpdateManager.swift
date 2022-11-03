//
//  UpdateManager.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-02.
//

import Foundation

struct UpdateManager {
    
    let network: Network
    static var updateDilogShownThisSession = false
    
    func isUpdateAvailableInStore(completion: @escaping (Bool)->Void) {
        guard let bundleInfo = Bundle.main.infoDictionary else {
            return completion(false)
        }
        
        guard let bundleId = bundleInfo["CFBundleIdentifier"] as? String,
              let currentVersion : String = bundleInfo["CFBundleShortVersionString"] as? String
        else {
            return completion(false)
        }
        
        let url = URL(string: "https://itunes.apple.com/ca/lookup?bundleId=\(bundleId)")!
        let request = NetworkRequest<DefaultParams, AppStoreVersionData>(
            url: url,
            type: .Get,
            parameters: nil,
            encoder: .json,
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
}
