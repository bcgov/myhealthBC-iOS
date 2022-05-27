//
//  LoginThrottleAPIWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-25.
//

import Foundation
import UIKit

class LoginThrottleAPIWorker: NSObject {
    
    private var apiClient: APIClient
    private var queueItDelegateOwner: UIViewController
    
    
    init(delegateOwner: UIViewController) {
        self.apiClient = APIClient(delegateOwner: delegateOwner)
        self.queueItDelegateOwner = delegateOwner
    }

    func throttleHGMobileConfigEndpoint(completion: @escaping (Bool) -> Void) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        apiClient.throttleHGMobileConfig(token: queueItTokenCached, executingVC: queueItDelegateOwner, includeQueueItUI: true) { [weak self] result, queueItRetryStatus in
            guard let `self` = self else {return}
            if let retry = queueItRetryStatus, retry.retry == true {
                let queueItToken = retry.token
                self.apiClient.throttleHGMobileConfig(token: queueItToken, executingVC: self.queueItDelegateOwner, includeQueueItUI: true) { [weak self] result, _ in
                    guard let `self` = self else {return}
                    self.handleResponse(result: result, completion: completion)
                }
            } else {
                self.handleResponse(result: result, completion: completion)
            }
        }
    }

    private func handleResponse(result: Result<MobileConfigurationResponseObject, ResultError>, completion: @escaping (Bool) -> Void) {
        switch result {
        case .success(let mobileConfig):
            // Note: This is a quickfix for now - should rework so that either we only do this here instead of in tabBar controller
            if let url = URL(string: mobileConfig.baseUrl) {
                BaseURLWorker.shared.baseURL = url
            }
            completion(mobileConfig.online)
        case .failure(let error):
            // TODO: Show error that network isn't available? Have to test it out
            print("CONNOR: ERROR: ", error)
            // Note - if this happens, it's not a throttling issue, it's a network issue
            completion(false)
        }
    }
    
}

