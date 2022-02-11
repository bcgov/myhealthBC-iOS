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
    
    public static let shared = LocalAuthManager()
    
    public static var shouldAuthenticate = true {
        didSet {
            Logger.log(string: "SET SHOULD AUTHENTICATE - \(shouldAuthenticate)", type: .localAuth)
        }
    }
    private static var block = true {
        didSet {
            Logger.log(string: "Blocking local authentication popups - \(block)", type: .localAuth)
        }
    }
    
    //MARK: Handle launch from background
    private func launchedFromBackground() {
        guard !LocalAuthManager.block else {return}
        LocalAuthManager.shouldAuthenticate = true
        Logger.log(string: "Should perfom local authentication", type: .localAuth)
        Notification.Name.shouldPerformLocalAuth.post(object: nil, userInfo: nil)
    }
    
    public func listenToAppLaunch() {
        Notification.Name.launchedFromBackground.onPost(object: nil, queue: .main) {[weak self] _ in
            guard let `self` = self else {return}
            self.launchedFromBackground()
            Logger.log(string: "App launched from background", type: .localAuth)
            LocalAuthManager.block = false
        }
    }
    
    private var view: LocalAuthView?
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
    
    public var appHasPermission: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
    
    public var isBiometricAvailable: Bool {
       return availableAuthMethods.contains(where: {$0 == .deviceOwnerAuthenticationWithBiometrics})
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
        if !LocalAuthManager.shouldAuthenticate {return}
        let viewType: LocalAuthView.ViewType = availableAuthMethods.isEmpty ? .EnableAuthentication : .Authenticate
        view?.dismiss(animated: false)
        view = LocalAuthView.fromNib()
        Logger.log(string: "Performing local authentication", type: .localAuth)
        view?.display(on: viewController, type: viewType, manager: self) {
            self.openAuthSettings()
        } useTouchId: {
            self.useAuth(policy: .deviceOwnerAuthentication, completion: completion)
        } usePasscode: {
            self.useAuth(policy: .deviceOwnerAuthentication, completion: completion)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if viewType == .Authenticate {
                self.useAuth(policy: .deviceOwnerAuthentication, completion: completion)
            }
        }
    }
    
    private func openAuthSettings() {
        self.view?.parent?.alertConfirmation(title: .allowSecurityAccessTitle, message: .allowSecurityAccessMessage, confirmTitle: .settings, confirmStyle: .default, onConfirm: {
            UIApplication.openAppSettings()
        },cancelTitle: .notNow, onCancel: {})
    }
    
    private func useAuth(policy: LAPolicy, completion: @escaping(_ status: AuthStatus) -> Void) {
        performAuth(policy: policy) { biometricStatus in
            switch biometricStatus {
            case .Authorized:
                LocalAuthManager.shouldAuthenticate = false
                self.view?.setState(state: .Success)
                return completion(biometricStatus)
            case .Unauthorized:
                self.view?.setState(state: .Fail)
                return completion(biometricStatus)
                
            case .Unavailable:
                self.performAuth(policy: .deviceOwnerAuthentication, completion: { passStatus in
                    switch passStatus {
                    case .Authorized:
                        LocalAuthManager.shouldAuthenticate = false
                        self.view?.setState(state: .Success)
                        return completion(passStatus)
                    case .Unauthorized:
                        self.view?.setState(state: .Fail)
                        return completion(passStatus)
                    case .Unavailable:
                        self.view?.setState(state: .Unavailable)
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
            LocalAuthManager.block = true
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

