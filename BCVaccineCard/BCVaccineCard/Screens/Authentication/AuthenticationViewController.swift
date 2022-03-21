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
    func showLogin(initialView: AuthenticationViewController.InitialView, sourceVC: LoginVCSource, completion: @escaping(_ authenticated: Bool)->Void) {
        self.view.startLoadingIndicator()
        let vc = AuthenticationViewController.constructAuthenticationViewController(returnToHealthPass: false, isModal: true, initialView: initialView, sourceVC: sourceVC, completion: { [weak self] result in
            guard let `self` = self else {return}
            self.view.endLoadingIndicator()
            switch result {
            case .Completed:
                self.alert(title: .loginSuccess, message: .recordsWillBeAutomaticallyAdded) {
                    // Will be fetching on completion, before user interacts with this message
                    self.performAuthenticatedBackgroundFetch(isManualFetch: true, sourceVC: sourceVC)
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

// MARK: This is for resetting the appropriate view controller
enum LoginVCSource: String {
    case BackgroundFetch = "BackgroundFetch"
    case AfterOnboarding = "AfterOnboarding"
    case SecurityAndDataVC = "SecurityAndDataVC"
    case ProfileAndSettingsVC = "ProfileAndSettingsVC"
    case HealthPassVC = "HealthPassVC"
    case QRRetrievalVC = "QRRetrievalVC"
    case FetchHealthRecordsVC = "FetchHealthRecordsVC"
    case UserListOfRecordsVC = "UserListOfRecordsVC"
    
    var getVCType: UIViewController.Type {
        switch self {
        case .BackgroundFetch: return TabBarController.self
        case .AfterOnboarding: return InitialOnboardingViewController.self
        case .SecurityAndDataVC: return SecurityAndDataViewController.self
        case .ProfileAndSettingsVC: return ProfileAndSettingsViewController.self
        case .HealthPassVC: return HealthPassViewController.self
        case .QRRetrievalVC: return QRRetrievalMethodViewController.self
        case .FetchHealthRecordsVC: return FetchHealthRecordsViewController.self
        case .UserListOfRecordsVC: return UsersListOfRecordsViewController.self
        }
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
    
    class func constructAuthenticationViewController(returnToHealthPass: Bool, isModal: Bool, initialView: InitialView, sourceVC: LoginVCSource, completion: @escaping(AuthenticationStatus)->Void) -> AuthenticationViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: AuthenticationViewController.self)) as? AuthenticationViewController {
            vc.completion = completion
            vc.returnToHealthPass = returnToHealthPass
            vc.initialView = initialView
            vc.sourceVC = sourceVC
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
    private var sourceVC: LoginVCSource = .AfterOnboarding
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch initialView {
        case .Landing:
            showLanding(sourceVC: sourceVC)
        case .AuthInfo:
            showInfo(sourceVC: sourceVC)
        case .Auth:
            performAuthentication(sourceVC: sourceVC)
        }
        
    }
    
    private func showLanding(sourceVC: LoginVCSource) {
        removeChild()
        let authView: AuthenticationView = AuthenticationView.fromNib()
        authView.tag = childTag
        authView.setup(in: self.view) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .Login:
                self.showInfo(sourceVC: sourceVC)
            case .Cancel:
                self.dismissView(withDelay: false, status: .Cancelled, sourceVC: sourceVC)
            }
        }
    }
    
    private func showInfo(sourceVC: LoginVCSource) {
        removeChild()
        let authInfoView: AuthenticationInfoView = AuthenticationInfoView.fromNib()
        authInfoView.tag = childTag
        authInfoView.setup(in: self.view) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .Continue:
                self.performAuthentication(sourceVC: sourceVC)
            case .Cancel:
                self.dismissView(withDelay: false, status: .Cancelled, sourceVC: sourceVC)
            case .Back:
                self.showLanding(sourceVC: sourceVC)
            }
        }
    }
    
    private func performAuthentication(sourceVC: LoginVCSource) {
        self.view.startLoadingIndicator()
        AuthManager().authenticate(in: self, completion: { [weak self] result in
            guard let self = self else {return}
            self.view.endLoadingIndicator()
            switch result {
            case .Unavailable:
                // TODO:
                print("Handle Unavailable")
                self.dismissView(withDelay: false, status: .Failed, sourceVC: sourceVC)
            case .Success:
                self.dismissView(withDelay: true, status: .Completed, sourceVC: sourceVC)
            case .Fail:
                // TODO:
                print("Handle fail")
                self.dismissView(withDelay: false, status: .Failed, sourceVC: sourceVC)
            }
        })
    }
    
    fileprivate func removeChild() {
        if let currentChild = self.view.viewWithTag(childTag) {
            currentChild.removeFromSuperview()
        }
    }
    
    private func dismissView(withDelay: Bool, status: AuthenticationStatus, sourceVC: LoginVCSource) {
        
        if withDelay {
            self.view.startLoadingIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) { [weak self] in
                guard let self = self else {return}
                self.dismissView(withDelay: false, status: status, sourceVC: sourceVC)
            }
        }
        self.removeChild()
        
        dismissAndReturnCompletion(status: status)
        if self.returnToHealthPass && status == .Completed {
            dismissFullScreen(sourceVC: sourceVC)
        } else if sourceVC == .AfterOnboarding {
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
    
    func dismissFullScreen(sourceVC: LoginVCSource) {
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
        vc.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: true, isManualFetch: true, sourceVC: sourceVC)
    }
    
    private func instantiateTabBar() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = TabBarController.constructTabBarController()
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
    
    public static func displayFullScreen(returnToHealthPass: Bool, initialView: InitialView, sourceVC: LoginVCSource) {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = AuthenticationViewController.constructAuthenticationViewController(returnToHealthPass: returnToHealthPass, isModal: false, initialView: initialView, sourceVC: sourceVC, completion: {_ in})
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
    
}
