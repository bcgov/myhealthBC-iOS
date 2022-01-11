//
//  AuthManager.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-10-27.
//

import Foundation
import AppAuth
import KeychainAccess
import JWTDecode

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
        case idToken
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
    
    var hdid: String? {
        guard let stringToken = authToken else {return nil}
        do {
            let jwt = try decode(jwt: stringToken)
            let claim = jwt.claim(name: "hdid")
            return claim.string
        } catch {
            return nil
        }
    }
    
    var refreshToken: String? {
        guard let token = keychain[Key.refreshToken.rawValue] else {
            return nil
        }
        return token.isEmpty ? nil : token
    }
    
    var idToken: String? {
        guard let token = keychain[Key.idToken.rawValue] else {
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
    
    var isAuthenticated: Bool {
        guard let exp = authTokenExpiery, authToken != nil else {
            return false
        }
        // TODO: After token refresh is implemented, use this
        // return exp > Date()
        // For now:
        return true
    }
    
    // MARK: Network
    func authenticate(in viewController: UIViewController, completion: @escaping(AuthenticationResult) -> Void) {
        guard let redirectURI = URL(string: Constants.Auth.redirectURI) else {
            return
        }
        discoverConfiguration { result in
            guard let configuration = result, let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return completion(.Unavailable)
            }
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
    
    func signout(in viewController: UIViewController, completion: @escaping(Bool)->Void) {
        guard let redirectURI = URL(string: Constants.Auth.redirectURI) else {
            return
        }
        discoverConfiguration { result in
            guard let configuration = result,
                  let token = self.idToken,
                  let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return completion(false)
            }
            let request = OIDEndSessionRequest(configuration: configuration,
                                               idTokenHint: token,
                                               postLogoutRedirectURL: redirectURI,
                                               additionalParameters: nil)
            guard let agent = OIDExternalUserAgentIOS(presenting: viewController) else {
                return completion(false)
            }
            
            appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: agent, callback: { (response, error) in
                if response != nil {
                    HTTPCookieStorage.shared.cookies?.forEach { cookie in
                        HTTPCookieStorage.shared.deleteCookie(cookie)
                    }
                    self.removeAuthTokens()
                    return completion(true)
                }
                if error != nil {
                    return completion(false)
                }
            })
        }
    }
    
    private func discoverConfiguration(completion: @escaping(OIDServiceConfiguration?)->Void) {
        guard let issuer = URL(string: Constants.Auth.issuer) else {
            return completion(nil)
        }
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { result, error in
            guard let configuration = result else {
                print("Error retrieving discovery document: \(error?.localizedDescription ?? "Unknown error")")
                return completion(nil)
            }
            return completion(configuration)
        }
    }
    
    // MARK: STORAGE
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
        
        if let idToken = state.lastTokenResponse?.idToken {
            store(string: idToken, for: .idToken)
        }
    }
    
    private func removeAuthTokens() {
        delete(key: .authToken)
        delete(key: .refreshToken)
        delete(key: .authTokenExpiery)
        delete(key: .idToken)
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
