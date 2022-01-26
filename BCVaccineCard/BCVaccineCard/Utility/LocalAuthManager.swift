//
//  LocalAuthManager.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-25.
//

import Foundation
import LocalAuthentication

class LocalAuthManager {
    private lazy var view: LocalAuthView = LocalAuthView()

    public enum AuthStatus {
        case Authorized
        case Unauthorized
        case Unavailable
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

    public func availableAuthMethods() -> [LAPolicy] {
        let context = LAContext()
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

    public func performLocalAuth(on viewController: UIViewController, completion: @escaping(_ status: AuthStatus) -> Void) {
        view.display(on: viewController)
        performAuth(policy: .deviceOwnerAuthenticationWithBiometrics) { biometricStatus in
            switch biometricStatus {
            case .Authorized:
                self.view.style(state: .Success)
                return completion(biometricStatus)
            case .Unauthorized:
                self.view.style(state: .Fail)
                return completion(biometricStatus)

            case .Unavailable:
                self.performAuth(policy: .deviceOwnerAuthentication, completion: { passStatus in
                    switch passStatus {
                    case .Authorized:
                        self.view.style(state: .Success)
                        return completion(passStatus)
                    case .Unauthorized:
                        self.view.style(state: .Fail)
                        return completion(passStatus)
                    case .Unavailable:
                        self.view.style(state: .Unavailable)
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

import UIKit
class LocalAuthView: UIView {
    
    weak var parent: UIViewController?
    
    enum State {
        case Success
        case Fail
        case Unavailable
    }

    func display(on viewController: UIViewController) {
        viewController.view.addSubview(self)
        addEqualSizeContraints(to: viewController.view)
        self.backgroundColor = AppColours.appBlue
        self.parent = viewController
        layoutIfNeeded()
    }

    func style(state: LocalAuthView.State) {
        switch state {
        case .Success:
            setSuccess()
        case .Fail:
            setFail()
        case .Unavailable:
            setUnAvailable()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            [weak self] in
            guard let self = self else {return}
            UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseOut) {
                [weak self] in
                guard let self = self else {return}
                if state == .Success {
                    self.alpha = 0
                    self.layoutIfNeeded()
                }
            } completion: { [weak self] done in
                guard let self = self else {return}
                if state == .Success {
                    self.removeFromSuperview()
                }
            }
        }
    }

    func setSuccess() {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else {return}
            UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseOut) {
                [weak self] in
                guard let self = self else {return}
                self.alpha = 0
                self.layoutIfNeeded()
            } completion: { [weak self] done in
                guard let self = self else {return}
                self.removeFromSuperview()
            }
        }
    }

    func setFail() {
        // TODO
        self.backgroundColor = .systemPink
    }

    func setUnAvailable() {
        // TODO
        self.backgroundColor = .red
        guard let parent = parent else {
            return
        }
        parent.alertConfirmation(title: <#T##String#>, message: <#T##String#>, confirmTitle: <#T##String#>, confirmStyle: <#T##UIAlertAction.Style#>, onConfirm: <#T##() -> Void#>, onCancel: <#T##() -> Void#>)

    }
}

extension UIView {
    func findTopMostVC() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
