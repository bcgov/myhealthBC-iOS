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
    
    func accept(termsOfServiceId: String,
                completion: @escaping(AuthenticatedUserProfileResponseObject?)->Void
    ) {
        let patientService = PatientService(network: network, authManager: authManager, configService: configService)
        network.addLoader(message: .empty, caller: .TOSService_Accept)
        patientService.fetchProfile { profile in
            network.removeLoader(caller: .TOSService_Accept)
            if let profile = profile,
                profile.resourcePayload?.acceptedTermsOfService == true && profile.resourcePayload?.hasTermsOfServiceUpdated == true
            {
                return  acceptUpdatedTOS(termsOfServiceId: termsOfServiceId, completion: completion)
            } else {
                return acceptInitialTOS(termsOfServiceId: termsOfServiceId, completion: completion)
            }
        }
    }
    
    // Post
    private func acceptInitialTOS(termsOfServiceId: String, completion: @escaping(AuthenticatedUserProfileResponseObject?)->Void) {
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
            
            let finalUrl: URL = endpoints.userProfile(base: baseURL, hdid: hdid)
            
            let headers: [String: String] = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
                Constants.AuthenticationHeaderKeys.hdid: hdid
            ]
            
            let requestModel = NetworkRequest<AuthenticatedUserProfileRequestObject, AuthenticatedUserProfileResponseObject>(url: finalUrl, type: .Post, parameters: parameters, headers: headers) { result in
                return completion(result)
            }
            
            network.request(with: requestModel)
        }
    }
        // PUT
    private func acceptUpdatedTOS(termsOfServiceId: String, completion: @escaping(AuthenticatedUserProfileResponseObject?)->Void) {
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
            
            let stringBody: String = termsOfServiceId
            let finalUrl: URL = endpoints.acceptTermsOfService(base: baseURL, hdid: hdid)
            
            let headers: [String: String] = [
                Constants.AuthenticationHeaderKeys.authToken: "Bearer \(token)",
            ]
            
            
            let requestModel = NetworkRequest<AuthenticatedUserProfileRequestObject, AuthenticatedUserProfileResponseObject>(url: finalUrl, type: .Put, parameters: parameters, stringBody: stringBody, headers: headers) { result in
                return completion(result)
            }
            
            CustomNetwork().request(with: requestModel)
        }
    }
    
    /*
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
     */
}
