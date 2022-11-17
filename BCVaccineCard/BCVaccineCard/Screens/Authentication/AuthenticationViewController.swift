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
    func showLogin(initialView: AuthenticationViewController.InitialView, sourceVC: LoginVCSource, presentingViewControllerReference viewController: UIViewController? = nil, completion: @escaping(_ authenticationStatus: AuthenticationViewController.AuthenticationStatus)->Void) {
        self.view.startLoadingIndicator()
        let vc = AuthenticationViewController.constructAuthenticationViewController(createTabBarAndGoToHomeScreen: false, isModal: true, initialView: initialView, sourceVC: sourceVC, completion: { [weak self] result in
            guard let `self` = self else {return}
            self.view.endLoadingIndicator()
            switch result {
            case .Completed:
                let tabVC = self.tabBarController as? TabBarController
                let authWorker = tabVC?.authWorker
                self.view.startLoadingIndicator()
                AuthenticationViewController.checkIfUserCanLoginAndFetchRecords(authWorker: authWorker, sourceVC: sourceVC) { allowed in
                    if allowed {
                        self.performAuthenticatedRecordsFetch(isManualFetch: true, sourceVC: sourceVC)
                        self.postAuthChangedSettingsReloadRequired()
                        self.alert(title: .loginSuccess, message: .recordsWillBeAutomaticallyAdded)
                        self.view.endLoadingIndicator()
                        completion(.Completed)
                    } else {
                        self.view.endLoadingIndicator()
                        completion(.Failed)
                    }
                }
                
            case .Cancelled, .Failed:
                completion(result)
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
    case HealthRecordsVC = "HealthRecordsVC"
    case QRRetrievalVC = "QRRetrievalVC"
    case FetchHealthRecordsVC = "FetchHealthRecordsVC"
    case UserListOfRecordsVC = "UserListOfRecordsVC"
    case TabBar = "TabBar"
    case HomeScreen = "HomeScreenVC"
    
    var getVCType: UIViewController.Type {
        switch self {
        case .BackgroundFetch: return TabBarController.self
        case .AfterOnboarding: return InitialOnboardingViewController.self
        case .SecurityAndDataVC: return SecurityAndDataViewController.self
        case .ProfileAndSettingsVC: return ProfileAndSettingsViewController.self
        case .HealthPassVC: return HealthPassViewController.self
        case .HealthRecordsVC: return HealthRecordsViewController.self
        case .QRRetrievalVC: return QRRetrievalMethodViewController.self
        case .FetchHealthRecordsVC: return FetchHealthRecordsViewController.self
        case .UserListOfRecordsVC: return UsersListOfRecordsViewController.self
        case .TabBar: return TabBarController.self
        case .HomeScreen: return HomeScreenViewController.self
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
   
    class func constructAuthenticationViewController(createTabBarAndGoToHomeScreen: Bool, isModal: Bool, initialView: InitialView, sourceVC: LoginVCSource, presentingViewControllerReference viewController: UIViewController? = nil, completion: @escaping(AuthenticationStatus)->Void) -> AuthenticationViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: AuthenticationViewController.self)) as? AuthenticationViewController {
            vc.completion = completion
            vc.createTabBarAndGoToHomeScreen = createTabBarAndGoToHomeScreen
            vc.initialView = initialView
            vc.sourceVC = sourceVC
            vc.presentingVCReference = viewController
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
    private var createTabBarAndGoToHomeScreen: Bool = true
    private var initialView: InitialView = .Landing
    private var sourceVC: LoginVCSource = .AfterOnboarding
    private var presentingVCReference: UIViewController?
    private var throttleAPIWorker: LoginThrottleAPIWorker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeNecessaryProperties()
        switch self.initialView {
        case .Landing:
            self.showLanding(sourceVC: self.sourceVC)
        case .AuthInfo:
            self.showInfo(sourceVC: self.sourceVC)
        case .Auth:
            self.performAuthentication(sourceVC: self.sourceVC, completion: nil)
        }
    }
    
    private func initializeNecessaryProperties() {
        NotificationCenter.default.addObserver(self, selector: #selector(queueItUIManuallyClosed), name: .queueItUIManuallyClosed, object: nil)
        throttleAPIWorker = LoginThrottleAPIWorker(delegateOwner: self)
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
                self.performAuthentication(sourceVC: sourceVC) { online in
                    if !online {
                        authInfoView.continueButton.isUserInteractionEnabled = true
                    }
                }
            case .Cancel:
                self.dismissView(withDelay: false, status: .Cancelled, sourceVC: sourceVC)
            case .Back:
                self.showLanding(sourceVC: sourceVC)
            }
        }
    }
    
    private func performAuthentication(sourceVC: LoginVCSource, completion: ((Bool) -> Void)?) {
        throttleAPIWorker?.throttleHGMobileConfigEndpoint(completion: { response in
            if response == .Online {
                self.view.startLoadingIndicator()
                AuthManager().authenticate(in: self, completion: { [weak self] result in
                    guard let self = self else {return}
                    self.view.endLoadingIndicator()
                    switch result {
                    case .Unavailable:
                        AppDelegate.sharedInstance?.showToast(message: "Authentication server is unavailable", style: .Warn)
                        self.dismissView(withDelay: false, status: .Failed, sourceVC: sourceVC)
                    case .Success:
                        Defaults.loginProcessStatus = LoginProcessStatus(hasStartedLoginProcess: true, hasCompletedLoginProcess: true, hasFinishedFetchingRecords: false, loggedInUserAuthManagerDisplayName: AuthManager().displayName)
                        self.dismissView(withDelay: true, status: .Completed, sourceVC: sourceVC)
                    case .Fail:
                        AppDelegate.sharedInstance?.showToast(message: "Authentication Failed", style: .Warn)
                        self.dismissView(withDelay: false, status: .Failed, sourceVC: sourceVC)
                    }
                })
            } else {
                completion?(false)
            }
            // Note: Toast will be shown if response is not "Online", so we don't need an else statement here, as we won't be showing a pop-up and won't be dismissing the screen
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
        } else {
            self.removeChild()
            
            dismissAndReturnCompletion(status: status)
            if self.createTabBarAndGoToHomeScreen {
                let authStatus: AuthenticationStatus? = status == .Completed ? .Completed : nil
                dismissFullScreen(sourceVC: sourceVC, authStatus: authStatus)
            }
        }
    }
    
    private func dismissAndReturnCompletion(status: AuthenticationStatus) {
        if sourceVC == .HomeScreen && status == .Completed {
            // Note: This is so that the user doesn't see the home screen after a successfull login
            let view = self.presentingVCReference?.view
            AppDelegate.sharedInstance?.addLoadingViewHack(addToView: view)
        }
        self.dismiss(animated: true, completion: {
            self.returnCompletion(status: status)
        })
    }
    
    private func returnCompletion(status: AuthenticationStatus) {
        if let completion = completion {
            completion(status)
        }
    }
    
    // Note: This authStatus is to determine whether tab bar needs to prompt a login success message or not
    func dismissFullScreen(sourceVC: LoginVCSource, authStatus: AuthenticationStatus?) {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = TabBarController.constructTabBarController(status: authStatus)
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
    
    public static func displayFullScreen(createTabBarAndGoToHomeScreen: Bool, initialView: InitialView, sourceVC: LoginVCSource) {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = AuthenticationViewController.constructAuthenticationViewController(createTabBarAndGoToHomeScreen: createTabBarAndGoToHomeScreen, isModal: false, initialView: initialView, sourceVC: sourceVC) {_ in}
        AppDelegate.sharedInstance?.window?.rootViewController = vc
        // Note: This is required for the edge case where a user logs in from onboarding flow
        BaseURLWorker.setup(BaseURLWorker.Config(delegateOwner: vc))
        BaseURLWorker.shared.setBaseURL {}
    }
    
}

// MARK: Checks if user is 12 and over AND has accepted terms and conditions
extension AuthenticationViewController {
    public static func checkIfUserCanLoginAndFetchRecords(authWorker: AuthenticatedHealthRecordsAPIWorker?, sourceVC: LoginVCSource, completion: @escaping (Bool) -> Void) {
        guard let authToken = AuthManager().authToken, let hdid = AuthManager().hdid else { return }
        let authCreds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
        authWorker?.checkIfUserCanLoginAndFetchRecords(authCredentials: authCreds, sourceVC: sourceVC, completion: completion)
    }
}

// MARK: QueueIt UI Hack
extension AuthenticationViewController {
    @objc private func queueItUIManuallyClosed(_ notification: Notification) {
        self.dismissView(withDelay: false, status: .Cancelled, sourceVC: self.sourceVC)
    }
}
