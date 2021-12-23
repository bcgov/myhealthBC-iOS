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
                self.showHomeScreen()
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
                self.showHomeScreen()
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
                print("Handle Unavailable")
            case .Success:
                self.showHomeScreen()
            case .Fail:
                print("Handle fail")
            }
        })
    }
    
    fileprivate func removeChild() {
        if let currentChild = self.view.viewWithTag(childTag) {
            currentChild.removeFromSuperview()
        }
    }
    
    private func showHomeScreen() {
        self.view.startLoadingIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {return}
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
