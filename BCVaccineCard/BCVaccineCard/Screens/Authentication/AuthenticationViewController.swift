//
//  AuthenticationViewController.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-22.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class AuthenticationViewController: UIViewController {
   
    class func construct(viewModel: ViewModel) -> AuthenticationViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: AuthenticationViewController.self)) as? AuthenticationViewController {
            vc.completion = viewModel.completion
            vc.initialView = viewModel.initialView
            vc.viewModel = viewModel
            if #available(iOS 13.0, *) {
                vc.isModalInPresentation = true
            }
            return vc
        }
        return AuthenticationViewController()
    }
    
    fileprivate let childTag = 19141244
    fileprivate let dismissDelay: TimeInterval = 1
    
    private var viewModel: ViewModel?
    private var completion: ((AuthenticationStatus)->Void)?
    private var initialView: InitialView = .Landing
//    private var throttleAPIWorker: LoginThrottleAPIWorker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        initializeNecessaryProperties()
        switch self.initialView {
        case .Landing:
            self.showLanding()
        case .AuthInfo:
            self.showInfo()
        case .Auth:
            self.performAuthentication()
        }
    }
    
//    private func initializeNecessaryProperties() {
//        NotificationCenter.default.addObserver(self, selector: #selector(queueItUIManuallyClosed), name: .queueItUIManuallyClosed, object: nil)
//        throttleAPIWorker = LoginThrottleAPIWorker(delegateOwner: self)
//    }
    
    private func showLanding() {
        removeChild()
        let authView: AuthenticationView = AuthenticationView.fromNib()
        authView.tag = childTag
        authView.setup(in: self.view) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .Login:
                self.showInfo()
            case .Cancel:
                self.dismissView(withDelay: false, status: .Cancelled)
            }
        }
    }
    
    private func showInfo() {
        removeChild()
        let authInfoView: AuthenticationInfoView = AuthenticationInfoView.fromNib()
        authInfoView.tag = childTag
        authInfoView.setup(in: self.view) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .Continue:
                self.performAuthentication()
            case .Cancel:
                self.dismissView(withDelay: false, status: .Cancelled)
            case .Back:
                self.showLanding()
            }
        }
    }
    
    private func performAuthentication() {
        guard let configService = viewModel?.configService,
              let authManager = viewModel?.authManager else {
            return
        }
        configService.fetchConfig { config in
            guard let config = config, config.online else {
                return
            }
            authManager.authenticate(in: self, completion: { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .Unavailable:
                    self.showToast(message: "Authentication server is unavailable", style: .Warn)
                    self.dismissView(withDelay: false, status: .Failed)
                case .Success:
                    Defaults.loginProcessStatus = LoginProcessStatus(hasStartedLoginProcess: true, hasCompletedLoginProcess: true, hasFinishedFetchingRecords: false, loggedInUserAuthManagerDisplayName: AuthManager().displayName)
                    self.dismissView(withDelay: true, status: .Completed)
                case .Fail:
                    self.dismissView(withDelay: false, status: .Failed)
                }
            })
        }
    }
    
    fileprivate func removeChild() {
        if let currentChild = self.view.viewWithTag(childTag) {
            currentChild.removeFromSuperview()
        }
    }
    
    private func dismissView(withDelay: Bool, status: AuthenticationStatus) {
        
        if withDelay {
            self.view.startLoadingIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) { [weak self] in
                guard let self = self else {return}
                self.dismissView(withDelay: false, status: status)
            }
        } else {
            self.removeChild()
            
            dismissAndReturnCompletion(status: status)
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
//    func dismissFullScreen(authStatus: AuthenticationStatus?) {
//        AppDelegate.sharedInstance?.setupRootViewController()
//    }
    
    /// Used only for initial authentication.
    /// sets auth view as the app's root view controller and after gets app to reset its root view controller
//    public static func displayFullScreen(completion: @escaping (AuthenticationStatus?)->Void) {
//        let networkService = AFNetwork()
//        let authManager = AuthManager()
//        let configService = MobileConfigService(network: networkService)
//        let transition = CATransition()
//        transition.type = .fade
//        transition.duration = Constants.UI.Theme.animationDuration
//        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
//        let vm = AuthenticationViewController.ViewModel(initialView: .Landing,
//                                                        configService: configService,
//                                                        authManager: authManager,
//                                                        completion: completion)
//        let vc = AuthenticationViewController.construct(viewModel: vm)
//        AppDelegate.sharedInstance?.window?.rootViewController = vc
//    }
    
}

// MARK: Checks if user is 12 and over AND has accepted terms and conditions
//extension AuthenticationViewController {
//    public static func checkIfUserCanLoginAndFetchRecords(completion: @escaping (Bool) -> Void) {
//        PatientService(network: AFNetwork(), authManager: AuthManager()).validateProfile(completion: completion)
//    }
//}

// MARK: QueueIt UI Hack
//extension AuthenticationViewController {
//    @objc private func queueItUIManuallyClosed(_ notification: Notification) {
//        self.dismissView(withDelay: false, status: .Cancelled, sourceVC: self.sourceVC)
//    }
//}
