//
//  InitialOnboardingViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit

class InitialOnboardingViewController: UIViewController {
    // TODO: Use the new screensToShow functionality
    class func constructInitialOnboardingViewController(startScreenNumber: InitialOnboardingView.ScreenNumber, screensToShow: [InitialOnboardingView.ScreenNumber]) -> InitialOnboardingViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: InitialOnboardingViewController.self)) as? InitialOnboardingViewController {
            vc.screenNumber = startScreenNumber
            vc.screensToShow = screensToShow
            return vc
        }
        return InitialOnboardingViewController()
    }
    
    @IBOutlet weak var initialOnboardingView: InitialOnboardingView!
    
    private var screensToShow: [InitialOnboardingView.ScreenNumber]! // NEED TO USE THIS NOW
    private var screenNumber: InitialOnboardingView.ScreenNumber!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        initialOnboardingView.initialConfigure(screenNumber: screenNumber, screensToShow: self.screensToShow, delegateOwner: self)
    }

}

extension InitialOnboardingViewController: AppStyleButtonDelegate {
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .next, let newScreenNumber = self.screenNumber.increment() {
            self.screenNumber = newScreenNumber
            self.initialOnboardingView.adjustUI(screenNumber: self.screenNumber, delegateOwner: self)
        }
        if type == .getStarted || type == .ok {
            Defaults.initialOnboardingScreensSeen = self.initialOnboardingView.getAllScreensForDefaults()
            goToHomeTransition()
        }
    }
    
    private func goToHomeTransition() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.3
        AppDelegate.sharedInstance?.window?.layer.add(transition, forKey: "transition")
        let vc = TabBarController.constructTabBarController()
        AppDelegate.sharedInstance?.window?.rootViewController = vc
    }
}


