//
//  AuthenticationViewController.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-22.
//

import UIKit

extension BaseViewController {
    func showLogin(initialView: AuthenticationViewController.InitialView,completion: @escaping(_ authenticated: Bool)->Void) {
        self.view.startLoadingIndicator()
        let vc = AuthenticationViewController.constructAuthenticationViewController(returnToHealthPass: false, isModal: true, initialView: initialView, completion: { [weak self] result in
            guard let self = self else {return}
            self.view.endLoadingIndicator()
            switch result {
            case .Completed:
                self.alert(title: .loginSuccess, message: .recordsWillBeAutomaticallyAdded) {
                    // TODO: FETCH RECORDS FOR AUTHENTICATED USER
                    // Will be fetching on completion, before user interacts with this message
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
    
    class func constructAuthenticationViewController(returnToHealthPass: Bool, isModal: Bool, initialView: InitialView, completion: @escaping(AuthenticationStatus)->Void) -> AuthenticationViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: AuthenticationViewController.self)) as? AuthenticationViewController {
            vc.completion = completion
            vc.returnToHealthPass = returnToHealthPass
            vc.initialView = initialView
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch initialView {
        case .Landing:
            showLanding()
        case .AuthInfo:
            showInfo()
        case .Auth:
            performAuthentication()
        }
        
    }
    
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
        self.view.startLoadingIndicator()
        AuthManager().authenticate(in: self, completion: { [weak self] result in
            guard let self = self else {return}
            self.view.endLoadingIndicator()
            switch result {
            case .Unavailable:
                // TODO:
                print("Handle Unavailable")
                self.dismissView(withDelay: false, status: .Failed)
            case .Success:
                self.dismissView(withDelay: true, status: .Completed)
            case .Fail:
                // TODO:
                print("Handle fail")
                self.dismissView(withDelay: false, status: .Failed)
            }
        })
    }
    
    fileprivate func removeChild() {
        if let currentChild = self.view.viewWithTag(childTag) {
            currentChild.removeFromSuperview()
        }
    }
    
    private func dismissView(withDelay: Bool, status: AuthenticationStatus) {
        // TODO: Here we can fetch user records before dismissing
        /**
         look for:
         // TODO: FETCH RECORDS FOR AUTHENTICATED USER
         where you see that, it would be the place to perform the fetch.
         but its probably cleaner to do it here.
         */
        if status == .Completed {
            // TODO: Fetch records here
            // use AuthManager().hdid and AuthManager().authToken
            // Steps: follow the '// TODO: CONNOR' comments and you'll see a number
        }
        
        if withDelay {
            self.view.startLoadingIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) { [weak self] in
                guard let self = self else {return}
                self.dismissView(withDelay: false, status: status)
            }
        }
        self.removeChild()
        
        dismissAndReturnCompletion(status: status)
        if self.returnToHealthPass {
            dismissFullScreen()
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
    }
    
    public static func displayFullScreen(returnToHealthPass: Bool, initialView: InitialView) {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = AuthenticationViewController.constructAuthenticationViewController(returnToHealthPass: returnToHealthPass, isModal: false, initialView: initialView, completion: {_ in})
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
    
}
