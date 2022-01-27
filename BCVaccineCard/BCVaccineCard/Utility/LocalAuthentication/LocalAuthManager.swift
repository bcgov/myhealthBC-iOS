//
//  LocalAuthManager.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-25.
//

import Foundation
import LocalAuthentication
import UIKit

class LocalAuthManager {
    private lazy var view: LocalAuthView = LocalAuthView()
    private let context = LAContext()
    
    public enum AuthStatus {
        case Authorized
        case Unauthorized
        case Unavailable
    }
    
    enum AvailableMethods {
        case FaceID
        case TouchID
        case Password
        case None
    }
    
    public var biometricType: LABiometryType {
        
        return context.biometryType
    }
    
    public var availableAuthMethods: [LAPolicy] {
        var result: [LAPolicy] = []
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            result.append(.deviceOwnerAuthenticationWithBiometrics)
        }
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            result.append(.deviceOwnerAuthentication)
        }
        return result
    }
    
    public var isEnabled: Bool {
        // TODO
        return true
    }
    
    public func enable() {
        // TODO
    }
    
    public func disable() {
        // TODO
    }
    
    public func performLocalAuth(on viewController: UIViewController, completion: @escaping(_ status: AuthStatus) -> Void) {
        let viewType: LocalAuthView.ViewType = availableAuthMethods.isEmpty ? .EnableAuthentication : .Authenticate
        
        view.display(on: viewController, type: viewType, manager: self) {
            self.openAuthSettings()
        } useTouchId: {
            self.useAuth(policy: .deviceOwnerAuthenticationWithBiometrics, completion: completion)
        } usePasscode: {
            self.useAuth(policy: .deviceOwnerAuthentication, completion: completion)
        }
    }
    
    private func openAuthSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
    
    private func useAuth(policy: LAPolicy, completion: @escaping(_ status: AuthStatus) -> Void) {
        performAuth(policy: policy) { biometricStatus in
            switch biometricStatus {
            case .Authorized:
                self.view.setState(state: .Success)
                return completion(biometricStatus)
            case .Unauthorized:
                self.view.setState(state: .Fail)
                return completion(biometricStatus)
                
            case .Unavailable:
                self.performAuth(policy: .deviceOwnerAuthentication, completion: { passStatus in
                    switch passStatus {
                    case .Authorized:
                        self.view.setState(state: .Success)
                        return completion(passStatus)
                    case .Unauthorized:
                        self.view.setState(state: .Fail)
                        return completion(passStatus)
                    case .Unavailable:
                        self.view.setState(state: .Unavailable)
                        return completion(passStatus)
                    }
                })
            }
        }
    }
    
    private func performAuth(policy: LAPolicy, completion: @escaping(_ status: AuthStatus) -> Void) {
        let context = LAContext()
        let reason = "Your records contain your personal infromation. Unlock My Health BC with biometric authentication."
        var error: NSError?
        if context.canEvaluatePolicy(policy, error: &error) {
            
            context.evaluatePolicy(policy, localizedReason: reason) {
                success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        return completion(.Authorized)
                    } else {
                        return completion(.Unauthorized)
                    }
                }
            }
        } else {
            return completion(.Unavailable)
        }
    }
}

