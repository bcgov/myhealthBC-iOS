//
//  AuthenticationViewController.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-22.
//

import UIKit

/*
We can call the BCSC auth in 2 ways:
1) AuthenticationViewController.displayFullScreen()
    - Replaces the VC in window with AuthenticationViewController
    - then sets the VC in window to be Tab Bar
2) BaseViewController.showLogin()
    - Shows AuthenticationViewController as a modal on the current view controller
 */

extension BaseViewController {
    func showLogin(initialView: AuthenticationViewController.InitialView,completion: @escaping(_ authenticated: Bool)->Void) {
        self.view.startLoadingIndicator()
        let vc = AuthenticationViewController.constructAuthenticationViewController(returnToHealthPass: false, isModal: true, initialView: initialView, completion: { [weak self] result in
            guard let `self` = self else {return}
            self.view.endLoadingIndicator()
            switch result {
            case .Completed:
                self.alert(title: .loginSuccess, message: .recordsWillBeAutomaticallyAdded) {
                    // Will be fetching on completion, before user interacts with this message
                    self.performAuthenticatedBackgroundFetch(isManualFetch: true)
                    self.postAuthChangedSettingsReloadRequired()
                    completion(true)
                }
            case .Cancelled, .Failed:
                completion(false)
                break
            }
        })
        self.present(vc, animated: true, completion: nil)
    }
}

class AuthenticationViewController: UIViewController {
    
    enum InitialView {
        case Landing
        case AuthInfo
        case Auth
    }
    
    enum AuthenticationStatus {
        case Completed
        case Cancelled
        case Failed
    }
    
    class func constructAuthenticationViewController(returnToHealthPass: Bool, isModal: Bool, initialView: InitialView, fromOnboardingFlow: Bool = false, completion: @escaping(AuthenticationStatus)->Void) -> AuthenticationViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: AuthenticationViewController.self)) as? AuthenticationViewController {
            vc.completion = completion
            vc.returnToHealthPass = returnToHealthPass
            vc.initialView = initialView
            vc.fromOnboardingFlow = fromOnboardingFlow
            if #available(iOS 13.0, *) {
                vc.isModalInPresentation = isModal
            }
            return vc
        }
        return AuthenticationViewController()
    }
    
    fileprivate let childTag = 19141244
    fileprivate let dismissDelay: TimeInterval = 1
    
    private var completion: ((AuthenticationStatus)->Void)?
    private var returnToHealthPass: Bool = true
    private var initialView: InitialView = .Landing
    private var fromOnboardingFlow: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch initialView {
        case .Landing:
            showLanding(fromOnboardingFlow: self.fromOnboardingFlow)
        case .AuthInfo:
            showInfo()
        case .Auth:
            performAuthentication()
        }
        
    }
    
    private func showLanding(fromOnboardingFlow: Bool = false) {
        removeChild()
        let authView: AuthenticationView = AuthenticationView.fromNib()
        authView.tag = childTag
        authView.setup(in: self.view) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .Login:
                self.showInfo(fromOnboardingFlow: fromOnboardingFlow)
            case .Cancel:
                self.dismissView(withDelay: false, status: .Cancelled, fromOnboardingFlow: fromOnboardingFlow)
            }
        }
    }
    
    private func showInfo(fromOnboardingFlow: Bool = false) {
        removeChild()
        let authInfoView: AuthenticationInfoView = AuthenticationInfoView.fromNib()
        authInfoView.tag = childTag
        authInfoView.setup(in: self.view) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .Continue:
                self.performAuthentication()
            case .Cancel:
                self.dismissView(withDelay: false, status: .Cancelled, fromOnboardingFlow: fromOnboardingFlow)
            case .Back:
                self.showLanding(fromOnboardingFlow: fromOnboardingFlow)
            }
        }
    }
    
    private func performAuthentication(fromOnboardingFlow: Bool = false) {
        self.view.startLoadingIndicator()
        AuthManager().authenticate(in: self, completion: { [weak self] result in
            guard let self = self else {return}
            self.view.endLoadingIndicator()
            switch result {
            case .Unavailable:
                // TODO:
                print("Handle Unavailable")
                self.dismissView(withDelay: false, status: .Failed, fromOnboardingFlow: fromOnboardingFlow)
            case .Success:
                self.dismissView(withDelay: true, status: .Completed, fromOnboardingFlow: fromOnboardingFlow)
            case .Fail:
                // TODO:
                print("Handle fail")
                self.dismissView(withDelay: false, status: .Failed, fromOnboardingFlow: fromOnboardingFlow)
            }
        })
    }
    
    fileprivate func removeChild() {
        if let currentChild = self.view.viewWithTag(childTag) {
            currentChild.removeFromSuperview()
        }
    }
    
    private func dismissView(withDelay: Bool, status: AuthenticationStatus, fromOnboardingFlow: Bool = false) {
        
        if withDelay {
            self.view.startLoadingIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) { [weak self] in
                guard let self = self else {return}
                self.dismissView(withDelay: false, status: status)
            }
        }
        self.removeChild()
        
        dismissAndReturnCompletion(status: status)
        if self.returnToHealthPass && status == .Completed {
            dismissFullScreen()
        } else if fromOnboardingFlow {
            self.instantiateTabBar()
        }
    }
    
    private func dismissAndReturnCompletion(status: AuthenticationStatus) {
        self.dismiss(animated: true, completion: {
            self.returnCompletion(status: status)
        })
    }
    
    private func returnCompletion(status: AuthenticationStatus) {
        if let completion = completion {
            completion(status)
        }
    }
    
    func dismissFullScreen() {
        // Note - prob not here
        // TODO: FETCH RECORDS FOR AUTHENTICATED USER
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = TabBarController.constructTabBarController()
        AppDelegate.sharedInstance?.window?.rootViewController = vc
        guard let authToken = AuthManager().authToken, let hdid = AuthManager().hdid else {return}
        let authCreds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
        vc.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: true, isManualFetch: true)
    }
    
    private func instantiateTabBar() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = TabBarController.constructTabBarController()
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
    
    public static func displayFullScreen(returnToHealthPass: Bool, initialView: InitialView, fromOnboardingFlow: Bool = false) {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = AuthenticationViewController.constructAuthenticationViewController(returnToHealthPass: returnToHealthPass, isModal: false, initialView: initialView, fromOnboardingFlow: fromOnboardingFlow, completion: {_ in})
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
    
}
