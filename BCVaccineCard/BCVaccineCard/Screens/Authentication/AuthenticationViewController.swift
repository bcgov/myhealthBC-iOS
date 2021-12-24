//
//  AuthenticationViewController.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-22.
//

import UIKit

class AuthenticationViewController: UIViewController {
    
    enum AuthenticationStatus {
        case Completed
        case Cancelled
        case Failed
    }
    
    class func constructAuthenticationViewController(returnToHealthPass: Bool, completion: @escaping(AuthenticationStatus)->Void) -> AuthenticationViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: AuthenticationViewController.self)) as? AuthenticationViewController {
            vc.completion = completion
            vc.returnToHealthPass = returnToHealthPass
            return vc
        }
        return AuthenticationViewController()
    }
    
    fileprivate let childTag = 19141244
    fileprivate let dismissDelay: TimeInterval = 1
    
    private var completion: ((AuthenticationStatus)->Void)?
    private var returnToHealthPass: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLanding()
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
        AuthManager().authenticate(in: self, completion: { [weak self] result in
            guard let self = self else {return}
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
         alternatively, look for:
         // TODO: FETCH RECORDS FOR AUTHENTICATED USER
            where you see that, it would be the place to perform this action.
               but its probably cleaner to do it here.
         */
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
        // TODO: FETCH RECORDS FOR AUTHENTICATED USER
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = TabBarController.constructTabBarController()
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
    
    public static func displayFullScreen() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = Constants.UI.Theme.animationDuration
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = AuthenticationViewController.constructAuthenticationViewController(returnToHealthPass: true, completion: {_ in})
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
    
}
