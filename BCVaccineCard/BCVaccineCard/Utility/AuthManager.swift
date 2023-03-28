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
import BCVaccineValidator

extension AuthManager {
    enum AuthenticationResult {
        case Unavailable
        case Success
        case Fail
    }
}

enum AuthStatus {
    case Authenticated
    case AuthenticationExpired
    case UnAuthenticated
}

class AuthManager {
    private enum Key: String {
        case authTokenExpiery
        case authToken
        case refreshToken
        case idToken
        case protectiveWord
        case medicalFetchRequired
    }
    let defaultUserID = "default"
    private let keychain = Keychain(service: "ca.bc.gov.myhealth")
    private let configService = MobileConfigService(network: AFNetwork())
    private var timer: Timer? = nil
    
    // MARK: Computed
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
    
    var displayName: String? {
        guard let stringToken = authToken else {return nil}
        do {
            let jwt = try decode(jwt: stringToken)
            let firstNameClaim = jwt.claim(name: "given_name")
            let lastNameClaim = jwt.claim(name: "family_name")
            var result = ""
            if let first = firstNameClaim.string {
                result += first
            }
            if let last = lastNameClaim.string {
                result += " \(last)"
            }
            return result
        } catch {
            return nil
        }
    }
    
    var firstName: String? {
        guard let stringToken = authToken else {return nil}
        do {
            let jwt = try decode(jwt: stringToken)
            let firstNameClaim = jwt.claim(name: "given_name")
            if let first = firstNameClaim.string {
                return first
            }
            return nil
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
    
    var authStaus: AuthStatus {
        guard authToken != nil else {
            return .UnAuthenticated
        }
        guard let accessExpiry = authTokenExpiery else { return .UnAuthenticated }
        if accessExpiry > Date() {
            return .Authenticated
        } else {
            return .AuthenticationExpired
        }
    }
    
    var authTokenExpiery: Date? {
        if let timeIntervalString = keychain[Key.authTokenExpiery.rawValue],
           let  timeInterval = Double(timeIntervalString) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }
    
    var refreshTokenExpiery: Date? {
        guard let stringToken = refreshToken else {return nil}
        do {
            let jwt = try decode(jwt: stringToken)
            return jwt.expiresAt
        } catch {
            return nil
        }
    }
    
    var isAuthenticated: Bool {
        guard authToken != nil else {
            return false
        }
        guard let accessExpiry = authTokenExpiery else { return false }
        return accessExpiry > Date()
    }
    
    var protectiveWord: String? {
        guard let proWord = keychain[Key.protectiveWord.rawValue] else {
            return nil
        }
        return proWord.isEmpty ? nil : proWord
    }
    
    // MARK: Network
    func authenticate(in viewController: UIViewController, completion: @escaping(AuthenticationResult) -> Void) {
        
        configService.fetchConfig(completion: { mobileConfig in
            guard let issuer = mobileConfig?.authentication?.endpoint,
                  let clientId = mobileConfig?.authentication?.clientID,
                  let redirectURIString = mobileConfig?.authentication?.redirectURI,
                  let redirectURI = URL(string: redirectURIString),
                let idphint = mobileConfig?.authentication?.identityProviderID
            else {
                return completion(.Unavailable)
            }
            self.discoverConfiguration(issuer: issuer) { result in
                guard let configuration = result, let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return completion(.Unavailable)
                }
                let request = OIDAuthorizationRequest(configuration: configuration,
                                                      clientId: clientId,
                                                      scopes: [OIDScopeOpenID, OIDScopeProfile],
                                                      redirectURL: redirectURI,
                                                      responseType: OIDResponseTypeCode,
                                                      additionalParameters: ["kc_idp_hint": idphint])
                
                LocalAuthManager.block = true
                appDelegate.currentAuthorizationFlow =
                OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
                    if let authState = authState {
                        self.store(state: authState)
                        self.authStatusChanged(authenticated: authState.isAuthorized)
                        return completion(.Success)
                    } else {
                        Logger.log(string: "Authorization error: \(error?.localizedDescription ?? "Unknown error")", type: .Auth)
                        return completion(.Fail)
                    }
                }
            }
        })
       
    }
    
    func topMostController() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return nil
        }

        var topController = rootViewController

        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        return topController
    }
    
    func signout(completion: @escaping(Bool)->Void) {
        guard let topMost = topMostController() else {return completion(false)}
        signout(in: topMost, completion: completion)
    }
    
    
    func signout(in viewController: UIViewController, completion: @escaping(Bool)->Void) {
        configService.fetchConfig(completion: { mobileConfig in
            guard let issuer = mobileConfig?.authentication?.endpoint,
                  let redirectURIString = mobileConfig?.authentication?.redirectURI,
                  let redirectURI = URL(string: redirectURIString)
            else {
                return completion(false)
            }
            self.discoverConfiguration(issuer: issuer) { result in
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
                        self.removeProtectiveWord()
                        SessionStorage.onSignOut()
                        StorageService.shared.deleteAuthenticatedPatient()
                        self.clearData()
                        self.authStatusChanged(authenticated: false)
                        
                        Defaults.loginProcessStatus = LoginProcessStatus(hasStartedLoginProcess: false, hasCompletedLoginProcess: false, hasFinishedFetchingRecords: false, loggedInUserAuthManagerDisplayName: nil)
                        return completion(true)
                    }
                    if error != nil {
                        return completion(false)
                    }
                })
            }
        })
    }
    
    func storeProtectiveWord(protectiveWord: String) {
        self.store(string: protectiveWord, for: .protectiveWord)
    }
    
    func removeProtectiveWord() {
        self.delete(key: .protectiveWord)
    }
    
    private func refetchAuthToken() {
        configService.fetchConfig(completion: { mobileConfig in
            guard let issuer = mobileConfig?.authentication?.endpoint,
                  let clientId = mobileConfig?.authentication?.clientID
            else {
                return
            }
            self.discoverConfiguration(issuer: issuer) { result in
                guard let configuration = result, let refreshToken = self.refreshToken else { return }
                
                let request = OIDTokenRequest(configuration: configuration,
                                              grantType: OIDGrantTypeRefreshToken,
                                              authorizationCode: nil,
                                              redirectURL: nil,
                                              clientID: clientId,
                                              clientSecret: nil,
                                              scope: nil,
                                              refreshToken: refreshToken,
                                              codeVerifier: nil,
                                              additionalParameters: nil)
                
                LocalAuthManager.block = true
                OIDAuthorizationService.perform(request) { tokenResponse, error in
                    if let tokenResponse = tokenResponse {
                        self.store(tokenResponse: tokenResponse)
                    } else {
                        Logger.log(string: "Refetch error: \(error?.localizedDescription ?? "Unknown error")", type: .Auth)
                    }
                }
            }
        })
    }
    
    private func discoverConfiguration(issuer: String, completion: @escaping(OIDServiceConfiguration?)->Void) {
        guard let issuer = URL(string: issuer) else {
            return completion(nil)
        }
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { result, error in
            guard let configuration = result else {
                Logger.log(string: "Error retrieving discovery document: \(error?.localizedDescription ?? "Unknown error")", type: .Auth)
                return completion(nil)
            }
            return completion(configuration)
        }
    }
    
    // MARK: STORAGE
    public func clearData() {
        removeAuthTokens()
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
        
        if let idToken = state.lastTokenResponse?.idToken {
            store(string: idToken, for: .idToken)
        }
        
    }
    
    private func store(tokenResponse: OIDTokenResponse) {
        if let authToken = tokenResponse.accessToken {
            let previousToken = self.authToken
            store(string: authToken, for: .authToken)
        }
        
        if let refreshToken = tokenResponse.refreshToken {
            store(string: refreshToken, for: .refreshToken)
        }
        
        if let expiery = tokenResponse.accessTokenExpirationDate {
            store(date: expiery, for: .authTokenExpiery)
        }
        
        if let idToken = tokenResponse.idToken {
            store(string: idToken, for: .idToken)
        }
    }
    
    private func removeAuthTokens() {
        delete(key: .authToken)
        delete(key: .refreshToken)
        delete(key: .authTokenExpiery)
        delete(key: .idToken)
        self.removeProtectiveWord()
    }
    
//    private func removeAuthenticatedPatient() {
//        guard let patient = StorageService.shared.fetchAuthenticatedPatient() else { return }
//        if let phn = patient.phn {
//            StorageService.shared.deletePatient(phn: phn)
//        } else if let dob = patient.birthday, let name = patient.name {
//            StorageService.shared.deletePatient(name: name, birthday: dob)
//        } else {
//            StorageService.shared.deleteAuthenticatedPatient()
//        }
//    }
    
    private func store(string: String, for key: Key) {
        do {
            try keychain.set(string, key: key.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private func delete(key: Key) {
        do {
            try keychain.remove(key.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private func store(date: Date, for key: Key) {
        let dateDouble = date.timeIntervalSince1970
        do {
            try keychain.set(String(dateDouble), key: key.rawValue)
        }
        catch let error {
            Logger.log(string: error.localizedDescription, type: .Auth)
        }
    }
    
    private func authStatusChanged(authenticated: Bool) {
        let info: [String: Bool] = [Constants.AuthStatusKey.key: authenticated]
        NotificationCenter.default.post(name: .authStatusChanged, object: nil, userInfo: info)
    }
    
    func logoutPermissionCancelled() {
        self.clearData()
        self.authStatusChanged(authenticated: false)
    }
}


extension AuthManager {
    func initAuthExpieryTimer() {
        if let authTokenExpiery = authTokenExpiery, isAuthenticated {
            let timer = Timer(fireAt: authTokenExpiery, interval: 0, target: self, selector: #selector(authExpired), userInfo: nil, repeats: false)
            self.timer?.invalidate()
            self.timer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    @objc func authExpired() {
        guard !isAuthenticated else {return}
        timer?.invalidate()
        let info: [String: Bool] = [Constants.AuthStatusKey.key: false]
        NotificationCenter.default.post(name: .authTokenExpired, object: nil)
        NotificationCenter.default.post(name: .authStatusChanged, object: nil, userInfo: info)
       
    }
    
    // Note - due to hack, we won't be using this function, currently
    private func fetchAccessTokenWithRefeshToken() {
        refetchAuthToken()
    }
    
}
