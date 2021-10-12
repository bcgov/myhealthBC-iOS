//
//  InitialOnboardingViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit

class InitialOnboardingViewController: UIViewController {
    
    class func constructInitialOnboardingViewController() -> InitialOnboardingViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: InitialOnboardingViewController.self)) as? InitialOnboardingViewController {
            vc.screenNumber = .one
            return vc
        }
        return InitialOnboardingViewController()
    }
    
    @IBOutlet weak var initialOnboardingView: InitialOnboardingView!
    
    private var screenNumber: InitialOnboardingView.ScreenNumber!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        initialOnboardingView.initialConfigure(screenNumber: screenNumber, delegateOwner: self)
    }

}

extension InitialOnboardingViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .next, let newScreenNumber = self.screenNumber.increment() {
            self.screenNumber = newScreenNumber
            self.initialOnboardingView.adjustUI(screenNumber: self.screenNumber, delegateOwner: self)
        }
        if type == .getStarted {
            // TODO: adjust user defaults to show that screen has been shown
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.3
            AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
            let vc = TabBarController.constructTabBarController()
            AppDelegate.sharedInstance?.window?.rootViewController = vc
        }
    }
}
