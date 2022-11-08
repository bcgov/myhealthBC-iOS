//
//  MobileConfigService.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2022-11-03.
//

import Foundation

struct MobileConfigService {
    let network: Network
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    func fetchConfig(completion: @escaping (MobileConfigurationResponseObject?)->Void) {
        guard NetworkConnection.shared.hasConnection else {
            return completion(MobileConfigStorage.cachedConfig)
        }
        network.addLoader(message: .empty)
        let request = NetworkRequest<DefaultParams, MobileConfigurationResponseObject>(
            url: UrlAccessor.mobileConfigURL,
            type: .Get,
            parameters: nil,
            headers: nil,
            completion: { responseData in
                if let response = responseData {
                    MobileConfigStorage.store(config: response)
                }
                self.network.removeLoader()
                return completion(responseData)
            })
        network.request(with: request)
    }
    
    // Using hard coded auth configs
    func fetchDefaultAuthConfig(completion: @escaping (MobileConfigurationResponseObject?)->Void) {
        fetchConfig { remoteResponse in
            guard let response = remoteResponse else {
                return completion(nil)
            }
            let modified = MobileConfigurationResponseObject(online: response.online, baseURL: response.baseURL, authentication: defaultAuth(), version: response.version)
            return completion(modified)
        }
    }
    
    fileprivate func defaultAuth() -> AuthenticationConfig {
#if PROD
        return AuthenticationConfig(endpoint: "https://oidc.gov.bc.ca/auth/realms/ff09qn3f", identityProviderID: "bcsc2", clientID: "myhealthapp", redirectURI: "myhealthbc://*")
#elseif TEST
        return AuthenticationConfig(endpoint: "https://test.oidc.gov.bc.ca/auth/realms/ff09qn3f", identityProviderID: "bcsc", clientID: "myhealthapp", redirectURI: "myhealthbc://*")
#else
        return AuthenticationConfig(endpoint: "https://dev.oidc.gov.bc.ca/auth/realms/ff09qn3f", identityProviderID: "bcsc", clientID: "myhealthapp", redirectURI: "myhealthbc://*")
#endif
    }
}
