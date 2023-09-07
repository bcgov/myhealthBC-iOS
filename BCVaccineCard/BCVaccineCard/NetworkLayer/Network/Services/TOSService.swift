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
    
    private enum RequestType {
        case Put
        case Post
    }
    
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
    
    func accept(termsOfServiceId: String,
                completion: @escaping(AuthenticatedUserProfileResponseObject?)->Void
    ) {
        var requestType: RequestType = .Post
        let patientService = PatientService(network: network, authManager: authManager, configService: configService)
        
        patientService.fetchProfile { profile in
            print(profile)
            if let profile = profile,
                profile.resourcePayload?.acceptedTermsOfService == true && profile.resourcePayload?.hasTermsOfServiceUpdated == true
            {
                requestType = .Put
            }
            requestType = .Put
            print(requestType)
            return accept(termsOfServiceId: termsOfServiceId, requestType: requestType, completion: completion)
        }
    }
    
    private func acceptInitial() {
        
    }
    
    private func accept(termsOfServiceId: String,
                        requestType: RequestType,
                completion: @escaping(AuthenticatedUserProfileResponseObject?)->Void
    ) {
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
            
            let parameters = AuthenticatedUserProfileRequestObject(profile: AuthenticatedUserProfileRequestObject.ResourcePayload(hdid: hdid, termsOfServiceId: termsOfServiceId))
            
            let stringBody: String? = requestType == .Put ? termsOfServiceId : nil
            let finalUrl: URL = requestType == .Put ? endpoints.acceptTermsOfService(base: baseURL, hdid: hdid) : endpoints.userProfile(base: baseURL, hdid: hdid)
            
            let headers: [String: String]
            
            if requestType == .Put {
                headers = [
                    Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                ]
            } else {
                headers = [
                    Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                    Constants.AuthenticationHeaderKeys.hdid: hdid
                ]
            }
            
            let requestModel = NetworkRequest<AuthenticatedUserProfileRequestObject, AuthenticatedUserProfileResponseObject>(url: finalUrl, type: requestType == .Post ? .Post : .Put, parameters: parameters, stringBody: stringBody, headers: headers) { result in
                return completion(result)
            }
            
            network.request(with: requestModel)
        }
    }
}
