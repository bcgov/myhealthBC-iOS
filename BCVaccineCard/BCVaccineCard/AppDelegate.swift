//
//  AppDelegate.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-14.

import UIKit
import CoreData
import BCVaccineValidator
import EncryptedCoreData
import AppAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let sharedInstance = UIApplication.shared.delegate as? AppDelegate
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var window: UIWindow?
    var authManager: AuthManager?
    
    // Note - this is used to smooth the transition when adding a health record and showing the detail screen
    private var loadingViewHack: UIView?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configure()
        return true
    }
    
    private func configure() {
        //use .Prod or .Test for different endpoints for keys
#if PROD
        BCVaccineValidator.shared.setup(mode: .Prod, remoteRules: false)
#elseif DEV
        BCVaccineValidator.shared.setup(mode: .Test, remoteRules: false)
        //        FirebaseApp.configure()
#endif
        AnalyticsService.shared.setup()
        setupRootViewController()
        authManager = AuthManager()
        authManager?.initTokenExpieryTimer()
    }
}

// MARK: Auth {
extension AppDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      // Sends the URL to the current authorization flow (if any) which will
      // process it if it relates to an authorization response.
      if let authorizationFlow = self.currentAuthorizationFlow,
                                 authorizationFlow.resumeExternalUserAgentFlow(with: url) {
        self.currentAuthorizationFlow = nil
        return true
      }

      // Your additional URL handling (if any)

      return false
    }
}

// MARK: Root setup
extension AppDelegate {
    private func setupRootViewController() {
        let unseen = Defaults.unseenOnBoardingScreens()
        guard let first = unseen.first else {
            let vc = TabBarController.constructTabBarController()
            self.window?.rootViewController = vc
            return
        }
        
        let vc = InitialOnboardingViewController.constructInitialOnboardingViewController(startScreenNumber: first, screensToShow: unseen)
        self.window?.rootViewController = vc
        
    }
}

// MARK: For custom navigation routing hack with multiple pushes
extension AppDelegate {
    func addLoadingViewHack() {
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        loadingViewHack = UIView(frame: rect)
        loadingViewHack?.backgroundColor = .white
        loadingViewHack?.startLoadingIndicator(backgroundColor: .white)
        self.window?.addSubview(loadingViewHack!)
    }
    
    func removeLoadingViewHack() {
        loadingViewHack?.endLoadingIndicator()
        loadingViewHack?.removeFromSuperview()
    }
}

