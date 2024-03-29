//
//  FeedbackService.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-03-24.
//

import Foundation

struct FeedbackService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    public func postFeedback(for patient: Patient, object: PostFeedback, completion: @escaping(Bool?) -> Void) {
        network.addLoader(message: .empty, caller: .FeedbackService_postFeedback)
        postFeedbackNetworkRequest(object: object) { passed in
            network.removeLoader(caller: .FeedbackService_postFeedback)
            completion(passed)
        }
    }

    private func postFeedbackNetworkRequest(object: PostFeedback, completion: @escaping(Bool?) -> Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return completion(false)}
        guard NetworkConnection.shared.hasConnection else {
            network.showToast(message: .noInternetConnection, style: .Warn)
            return completion(nil)
        }
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(false)
            }
            
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            // TODO: Figure out a way to get some sort of response to test here for status code
            let requestModel = NetworkRequest<PostFeedback, Int>(url: endpoints.feedback(base: baseURL, hdid: hdid), type: .Post, parameters: object, headers: headers) { statusCode in
                guard let statusCode = statusCode else { return completion(false) }
                let success = (200...299).contains(statusCode) ? true : false
                return completion(success)
            } onError: { error in
                switch error {
                default:
                    return completion(false)
                }
            }
            
            network.request(with: requestModel)
        }
    }

    
}
