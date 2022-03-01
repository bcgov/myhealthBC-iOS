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
    var localAuthManager: LocalAuthManager?
    
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
        authManager?.checkAuthTokenExpiry()
        listenToAppState()
        localAuthManager = LocalAuthManager()
        localAuthManager?.listenToAppLaunch()
    }
    
    private func listenToAppState() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func didBecomeActive(_ notification: Notification) {
        NotificationCenter.default.post(name: .launchedFromBackground, object: nil)
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BCVaccineCard")
        
        do {
            let options = [
                EncryptedStorePassphraseKey : CoreDataEncryptionKeyManager.shared.key
            ]
            
            let description = try EncryptedStore.makeDescription(options: options, configuration: nil)
            container.persistentStoreDescriptions = [ description ]
        }
        catch {
            // TODO: WE need to handle this better
            fatalError("Could not initialize encrypted database storage: " + error.localizedDescription)
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // TODO: WE need to handle this better
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
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

public extension UIApplication {

    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController

            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}


extension UIApplication {
    @discardableResult
    static func openAppSettings() -> Bool {
        guard
            let settingsURL = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsURL)
            else {
                return false
        }

        UIApplication.shared.open(settingsURL)
        return true
    }
}
