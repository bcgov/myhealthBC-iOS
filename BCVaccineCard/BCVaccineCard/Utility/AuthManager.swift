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
        static let issuer: String = "https://dev.oidc.gov.bc.ca/auth/realms/ff09qn3f"
        static let clientID = "healthgateway"
        static let redirectURI = "myhealthbc://"
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
        return keychain[Key.authToken.rawValue]
    }
    
    var refreshToken: String? {
        return keychain[Key.refreshToken.rawValue]
    }
    
    var authTokenExpiery: Date? {
        if let timeIntervalString = keychain[Key.authTokenExpiery.rawValue],
           let  timeInterval = Double(timeIntervalString) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }
    
    func authenticate(in viewController: UIViewController) {
        guard let issuer = URL(string: Constants.Auth.issuer),
              let redirectURI = URL(string: Constants.Auth.redirectURI)
        else {
            return
        }
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { result, error in
            guard let configuration = result else {
                print("Error retrieving discovery document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            // perform the auth request...
            let request = OIDAuthorizationRequest(configuration: configuration,
                                                  clientId: Constants.Auth.clientID,
                                                  scopes: [OIDScopeOpenID, OIDScopeProfile],
                                                  redirectURL: redirectURI,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            
            // performs authentication request
            print("Initiating authorization request with scope: \(request.scope ?? "nil")")
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.currentAuthorizationFlow =
            OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
                if let authState = authState {
                    self.store(state: authState)
                    print("Got authorization tokens. Access token: " +
                          "\(authState.lastTokenResponse?.accessToken ?? "nil")")
                } else {
                    print("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
            
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
    
    private func store(string: String, for key: Key) {
        do {
            try keychain.set(string, key: key.rawValue)
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
