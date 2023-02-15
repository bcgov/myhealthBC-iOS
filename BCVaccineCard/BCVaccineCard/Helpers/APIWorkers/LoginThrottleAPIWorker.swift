//
//  LoginThrottleAPIWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-25.
//

//enum ThrottleResponseValues {
//    case Online
//    case Offline
//    case NoInternet
//}
//
//import Foundation
//import UIKit
//
//class LoginThrottleAPIWorker: NSObject {
//    
//    private var apiClient: APIClient
//    private var queueItDelegateOwner: UIViewController
//    
//    
//    init(delegateOwner: UIViewController) {
//        self.apiClient = APIClient(delegateOwner: delegateOwner)
//        self.queueItDelegateOwner = delegateOwner
//    }
//
//    func throttleHGMobileConfigEndpoint(completion: @escaping (ThrottleResponseValues) -> Void) {
//        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
//        apiClient.throttleHGMobileConfig(token: queueItTokenCached, executingVC: queueItDelegateOwner, includeQueueItUI: true) { [weak self] result, queueItRetryStatus in
//            guard let `self` = self else {return}
//            if let retry = queueItRetryStatus, retry.retry == true {
//                let queueItToken = retry.token
//                self.apiClient.throttleHGMobileConfig(token: queueItToken, executingVC: self.queueItDelegateOwner, includeQueueItUI: true) { [weak self] result, _ in
//                    guard let `self` = self else {return}
//                    self.handleResponse(result: result, completion: completion)
//                }
//            } else {
//                self.handleResponse(result: result, completion: completion)
//            }
//        }
//    }
//
//    private func handleResponse(result: Result<MobileConfigurationResponseObject, ResultError>, completion: @escaping (ThrottleResponseValues) -> Void) {
//        switch result {
//        case .success(let mobileConfig):
//            // Note: This is a quickfix for now - should rework so that either we only do this here instead of in tabBar controller
//            if let urlString = mobileConfig.baseURL,
//               let url = URL(string: urlString) {
//                BaseURLWorker.shared.baseURL = url
//            }
//            if mobileConfig.online == false {
//                AppDelegate.sharedInstance?.showToast(message: "Maintenance is underway. Please try later.", style: .Warn)
//            }
//            let val = mobileConfig.online ? ThrottleResponseValues.Online : ThrottleResponseValues.Offline
//            completion(val)
//        case .failure(let error):
//            Logger.log(string: error.localizedDescription, type: .Network)
//            AppDelegate.sharedInstance?.showToast(message: "Please check your internet connection", style: .Warn)
//            completion(ThrottleResponseValues.NoInternet)
//        }
//    }
//    
//}

