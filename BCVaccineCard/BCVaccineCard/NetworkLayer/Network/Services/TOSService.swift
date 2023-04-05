//
//  TOSService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-02-14.
//

import Foundation
struct TOSService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    fileprivate static var blockSync: Bool = false
    
    var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    func fetchTOS(completion: @escaping (TermsOfServiceResponse?)->Void) {
        guard NetworkConnection.shared.hasConnection else {
            return completion(nil)
        }
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            let request = NetworkRequest<DefaultParams, TermsOfServiceResponse>(
                url: endpoints.termsOfService(base: baseURL),
                type: .Get,
                parameters: nil,
                headers: nil,
                completion: { responseData in
                    return completion(responseData)
                }, onError: nil)
            network.request(with: request)
        }
    }
    
    func accept(termsOfServiceId: String, completion: @escaping(AuthenticatedUserProfileResponseObject?)->Void) {
        guard let token = authManager.authToken, let hdid = authManager.hdid else {
            return completion(nil)
        }
        configService.fetchConfig { response in
            guard let config = response,
                  config.online,
                  let baseURLString = config.baseURL,
                  let baseURL = URL(string: baseURLString)
            else {
                return completion(nil)
            }
            let headers = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            
            let parameters = AuthenticatedUserProfileRequestObject(profile: AuthenticatedUserProfileRequestObject.ResourcePayload(hdid: hdid, termsOfServiceId: termsOfServiceId))
            
            let requestModel = NetworkRequest<AuthenticatedUserProfileRequestObject, AuthenticatedUserProfileResponseObject>(url: endpoints.userProfile(base: baseURL, hdid: hdid), type: .Post, parameters: parameters, headers: headers) { result in
                return completion(result)
            }
            
            network.request(with: requestModel)
        }
    }
}
