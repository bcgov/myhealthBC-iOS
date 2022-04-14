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
        let vc = AuthenticationViewController.constructAuthenticationViewController(createTabBarAndGoToHomeScreen: false, isModal: true, initialView: initialView, sourceVC: sourceVC, completion: { [weak self] result in
            guard let `self` = self else {return}
            self.view.endLoadingIndicator()
            switch result {
            case .Completed:
                let tabVC = self.tabBarController as? TabBarController
                let authWorker = tabVC?.authWorker
                AuthenticationViewController.checkIfUserCanLoginAndFetchRecords(authWorker: authWorker, sourceVC: sourceVC) { allowed in
                    if allowed {
                        self.performAuthenticatedRecordsFetch(isManualFetch: true, sourceVC: sourceVC)
                        self.postAuthChangedSettingsReloadRequired()
                        self.alert(title: .loginSuccess, message: .recordsWillBeAutomaticallyAdded)
                    }
                    completion(allowed)
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
    case TabBar = "TabBar"
    
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
        case .TabBar: return TabBarController.self
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
    // TODO: When show landing screen is shown, we should hit MobileConfiguration endpoint to see if we can login or not - then implement QueueIt UI on this view controller
    class func constructAuthenticationViewController(createTabBarAndGoToHomeScreen: Bool, isModal: Bool, initialView: InitialView, sourceVC: LoginVCSource, completion: @escaping(AuthenticationStatus)->Void) -> AuthenticationViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: AuthenticationViewController.self)) as? AuthenticationViewController {
            vc.completion = completion
            vc.createTabBarAndGoToHomeScreen = createTabBarAndGoToHomeScreen
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
    private var createTabBarAndGoToHomeScreen: Bool = true
    private var initialView: InitialView = .Landing
    private var sourceVC: LoginVCSource = .AfterOnboarding
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
            self.performAuthentication(sourceVC: self.sourceVC)
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
                self.performAuthentication(sourceVC: sourceVC)
            case .Cancel:
                self.dismissView(withDelay: false, status: .Cancelled, sourceVC: sourceVC)
            case .Back:
                self.showLanding(sourceVC: sourceVC)
            }
        }
    }
    
    private func performAuthentication(sourceVC: LoginVCSource) {
        throttleAPIWorker?.throttleHGMobileConfigEndpoint(completion: { canProceed in
            if canProceed {
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
                        Defaults.loginProcessStatus = LoginProcessStatus(hasStartedLoginProcess: true, hasCompletedLoginProcess: true, hasFinishedFetchingRecords: false)
                        self.dismissView(withDelay: true, status: .Completed, sourceVC: sourceVC)
                    case .Fail:
                        // TODO:
                        print("Handle fail")
                        self.dismissView(withDelay: false, status: .Failed, sourceVC: sourceVC)
                    }
                })
            } else {
                print("Error")
                self.alert(title: .error, message: "There was an error trying to login, please try again later.") {
                    self.dismissView(withDelay: false, status: .Cancelled, sourceVC: self.sourceVC)
                }
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
//        guard let authToken = AuthManager().authToken, let hdid = AuthManager().hdid else {return}
//        let authCreds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
//        vc.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: true, isManualFetch: true, sourceVC: sourceVC)
    }
    
    public static func displayFullScreen(createTabBarAndGoToHomeScreen: Bool, initialView: InitialView, sourceVC: LoginVCSource) {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
//        let vc = AuthenticationViewController.constructAuthenticationViewController(createTabBarAndGoToHomeScreen: returnToHealthPass, isModal: false, initialView: initialView, sourceVC: sourceVC, completion: {_ in})
        let vc = AuthenticationViewController.constructAuthenticationViewController(createTabBarAndGoToHomeScreen: createTabBarAndGoToHomeScreen, isModal: false, initialView: initialView, sourceVC: sourceVC) {_ in}
        AppDelegate.sharedInstance?.window?.rootViewController = vc
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
