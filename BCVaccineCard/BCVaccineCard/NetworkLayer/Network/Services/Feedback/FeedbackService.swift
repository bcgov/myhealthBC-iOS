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
    
    public func postFeedback(for patient: Patient, object: PostFeedback, completion: @escaping(Bool) -> Void) {
        network.addLoader(message: .empty)
        postFeedbackNetworkRequest(object: object) { passed in
            network.removeLoader()
            guard passed else {
                return completion(false)
            }
            completion(true)
        }
    }

    private func postFeedbackNetworkRequest(object: PostFeedback, completion: @escaping(Bool) -> Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {return completion(false)}
        guard NetworkConnection.shared.hasConnection else {return completion(false)}
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
                print(statusCode)
                completion(true)
            } onError: { error in
                switch error {
                case .FailedAfterRetry:
                    network.showToast(message: "Could not post feedback, please try again later", style: .Warn)
                }
                
            }
            
            network.request(with: requestModel)
        }
    }

    
}
