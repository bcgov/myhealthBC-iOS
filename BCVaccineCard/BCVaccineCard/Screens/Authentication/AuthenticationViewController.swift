//
//  AuthenticationViewController.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-22.
//

import UIKit

class AuthenticationViewController: UIViewController {
    
    class func constructAuthenticationViewController(returnToHealthPass: Bool, completion: @escaping()->Void) -> AuthenticationViewController {
        if let vc = Storyboard.authentication.instantiateViewController(withIdentifier: String(describing: AuthenticationViewController.self)) as? AuthenticationViewController {
            vc.completion = completion
            vc.returnToHealthPass = returnToHealthPass
            return vc
        }
        return AuthenticationViewController()
    }
    
    fileprivate let childTag = 19141244
    fileprivate let dismissDelay: TimeInterval = 1
    
    private var completion: (()->Void)?
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
                self.dismissView()
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
                self.dismissView()
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
                // TODO
                print("Handle Unavailable")
                self.dismissView()
            case .Success:
                self.dismissViewWithDelay()
            case .Fail:
                // TODO
                print("Handle fail")
                self.dismissView()
            }
        })
    }
    
    fileprivate func removeChild() {
        if let currentChild = self.view.viewWithTag(childTag) {
            currentChild.removeFromSuperview()
        }
    }
    
    private func dismissView() {
        self.removeChild()
        let comp = self.completion
        self.dismiss(animated: true, completion: {
            if let comp = comp {
                comp()
            }
        })
        if self.returnToHealthPass {
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.3
            AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
            let vc = TabBarController.constructTabBarController()
            AppDelegate.sharedInstance?.window?.rootViewController = vc
        }
        
    }
    
    private func dismissViewWithDelay() {
        self.view.startLoadingIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) { [weak self] in
            guard let self = self else {return}
            self.dismissView()
        }
    }
    
    public static func displayFullScreen() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.3
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = AuthenticationViewController.constructAuthenticationViewController(returnToHealthPass: true, completion: {})
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
    
}
