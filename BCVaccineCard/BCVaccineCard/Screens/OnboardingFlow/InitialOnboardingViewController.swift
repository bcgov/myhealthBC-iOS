//
//  InitialOnboardingViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit

protocol OnboardSkipDelegate {
    func skip()
}

class InitialOnboardingViewController: UIViewController {
    
    class func constructInitialOnboardingViewController(startScreenNumber: OnboardingScreenType, screensToShow: [OnboardingScreenType]) -> InitialOnboardingViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: InitialOnboardingViewController.self)) as? InitialOnboardingViewController {
            vc.screensToShow = screensToShow
            vc.screenNumber = startScreenNumber
            return vc
        }
        return InitialOnboardingViewController()
    }
    
    @IBOutlet weak var initialOnboardingView: InitialOnboardingView!
    
    private var screensToShow: [OnboardingScreenType] = []
    private var screenNumber: OnboardingScreenType = .healthPasses
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        initialOnboardingView.initialConfigure(screenNumber: screenNumber, screensToShow: self.screensToShow, delegateOwner: self, skipDelegate: self)
    }
    
}

extension InitialOnboardingViewController: AppStyleButtonDelegate, OnboardSkipDelegate {
    func skip() {
        // TODO: version
        Defaults.storeInitialOnboardingScreensSeen(types: screensToShow)
        goToAuthentication()
    }
    
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .next, let newScreenNumber = self.initialOnboardingView.increment(screenNumber: self.screenNumber, screensToShow: self.screensToShow) {
            self.screenNumber = newScreenNumber
            self.initialOnboardingView.adjustUI(screenNumber: self.screenNumber, screensToShow: self.screensToShow, delegateOwner: self, skipDelegate: self)
        }
        if type == .getStarted || type == .ok {
            // TODO: version
            Defaults.storeInitialOnboardingScreensSeen(types: screensToShow)
            
            goToAuthentication()
        }
    }
    
    private func goToAuthentication() {
        AuthenticationViewController.displayFullScreen(returnToHealthPass: true, initialView: .Landing, sourceVC: .AfterOnboarding)
    }
}


