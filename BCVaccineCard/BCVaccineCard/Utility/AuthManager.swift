//
//  AuthManager.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-10-27.
//

import Foundation
import AppAuth
import KeychainAccess

extension Constants {
    struct Auth {
        static let issuer = "https://dev.oidc.gov.bc.ca/auth/realms/ff09qn3f"
        static let clientID = "myhealthapp"
        static let redirectURI = "myhealthbc://*"
        static let params = ["kc_idp_hint": "bcsc"]
    }
}

extension AuthManager {
    enum AuthenticationResult {
        case Unavailable
        case Success
        case Fail
    }
}

class AuthManager {
    private enum Key: String {
        case authTokenExpiery
        case authToken
        case refreshToken
    }
    let defaultUserID = "default"
    private let keychain = Keychain(service: "ca.bc.gov.myhealth")
    
    
    func userId() -> String {
        return defaultUserID
    }
    
    var authToken: String? {
        guard let token = keychain[Key.authToken.rawValue] else {
            return nil
        }
        return token.isEmpty ? nil : token
    }
    
    var refreshToken: String? {
        guard let token = keychain[Key.refreshToken.rawValue] else {
            return nil
        }
        return token.isEmpty ? nil : token
    }
    
    var authTokenExpiery: Date? {
        if let timeIntervalString = keychain[Key.authTokenExpiery.rawValue],
           let  timeInterval = Double(timeIntervalString) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }
    
    public func isAuthenticated() -> Bool {
       
        guard let exp = authTokenExpiery, authToken != nil else {
            return false
        }
        // TODO: After token refresh is implemented, use this
//        return exp > Date()
        // For now:
        return true
    }
    
    func authenticate(in viewController: UIViewController, completion: @escaping(AuthenticationResult) -> Void) {
        guard let issuer = URL(string: Constants.Auth.issuer),
              let redirectURI = URL(string: Constants.Auth.redirectURI)
        else {
            return
        }
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { result, error in
            guard let configuration = result, let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("Error retrieving discovery document: \(error?.localizedDescription ?? "Unknown error")")
                return completion(.Unavailable)
            }
            // perform the auth request...
            let request = OIDAuthorizationRequest(configuration: configuration,
                                                  clientId: Constants.Auth.clientID,
                                                  scopes: [OIDScopeOpenID, OIDScopeProfile],
                                                  redirectURL: redirectURI,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: Constants.Auth.params)
            
            
            appDelegate.currentAuthorizationFlow =
            OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
                if let authState = authState {
                    self.store(state: authState)
                    return completion(.Success)
                } else {
                    print("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
                    return completion(.Fail)
                }
            }
            
        }
    }
    
    func signout(in viewController: UIViewController) {
        removeAuthTokens()
        guard let issuer = URL(string: Constants.Auth.issuer),
              let redirectURI = URL(string: Constants.Auth.redirectURI)
        else {
            return
        }
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { result, error in
            guard let configuration = result,
                  let token = self.authToken,
                  let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                print("Error retrieving discovery document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let request = OIDEndSessionRequest(configuration: configuration,
                                               idTokenHint: token,
                                               postLogoutRedirectURL: redirectURI,
                                               additionalParameters: Constants.Auth.params)
            guard let agent = OIDExternalUserAgentIOS(presenting: viewController) else {
                return
            }
            appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: agent,
                                                                                   callback: { (response, error) in
                if let response = response {
                    //delete cookies just in case
                    HTTPCookieStorage.shared.cookies?.forEach { cookie in
                        HTTPCookieStorage.shared.deleteCookie(cookie)
                    }
                    // successfully logout
                }
                if let err = error {
                    // print Error
                }
            })
        }
    }
    
    private func store(state: OIDAuthState) {
        guard state.isAuthorized else { return }
        if let authToken = state.lastTokenResponse?.accessToken {
            store(string: authToken, for: .authToken)
        }
        if let refreshToken = state.lastTokenResponse?.refreshToken {
            store(string: refreshToken, for: .refreshToken)
        }
        if let expiery = state.lastTokenResponse?.accessTokenExpirationDate {
            store(date: expiery, for: .authTokenExpiery)
        }
        
    }
    
    private func removeAuthTokens() {
        delete(key: .authToken)
        delete(key: .refreshToken)
        delete(key: .authTokenExpiery)
    }
    
    private func store(string: String, for key: Key) {
        do {
            try keychain.set(string, key: key.rawValue)
        }
        catch let error {
            print(error)
        }
    }
    
    private func delete(key: Key) {
        do {
            try keychain.remove(key.rawValue)
        }
        catch let error {
            print(error)
        }
    }
    
    private func store(date: Date, for key: Key) {
        let dateDounle = date.timeIntervalSince1970
        do {
            try keychain.set(String(dateDounle), key: key.rawValue)
        }
        catch let error {
            print(error)
        }
    }
}
