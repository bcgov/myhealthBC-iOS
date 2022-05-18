//
//  AppDelegate.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-14.

import UIKit
import CoreData
import BCVaccineValidator
import EncryptedCoreData
import IQKeyboardManagerSwift
import AppAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let sharedInstance = UIApplication.shared.delegate as? AppDelegate
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var window: UIWindow?
    var authManager: AuthManager?
    var localAuthManager: LocalAuthManager?
    var protectiveWordEnteredThisSession = false
    
    var lastLocalAuth: Date? = nil
    var dataLoadCount: Int = 0 {
        didSet {
            print(dataLoadCount)
            if dataLoadCount > 0 {
                showLoader()
            } else {
                hideLoaded()
            }
        }
    }
    
    // Note - this is used to smooth the transition when adding a health record and showing the detail screen
    private var loadingViewHack: UIView?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configure()
        return true
    }
    
    func showLoader() {
        self.window?.viewWithTag(9912341)?.removeFromSuperview()
        let loaderView: UIView = UIView(frame: self.window?.bounds ?? .zero)
        loaderView.backgroundColor = .orange
        loaderView.tag = 9912341
        self.window?.addSubview(loaderView)
        loaderView.alpha = 0.5
    }
    
    func hideLoaded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard self.dataLoadCount < 1 else {return}
            self.window?.viewWithTag(9912341)?.removeFromSuperview()
        }
    }
    
    private func configure() {
        //use .Prod or .Test for different endpoints for keys
#if PROD
        BCVaccineValidator.shared.setup(mode: .Prod, remoteRules: false)
#elseif DEV
        BCVaccineValidator.shared.setup(mode: .Test, remoteRules: false)
#endif
        AnalyticsService.shared.setup()
        authManager = AuthManager()
        clearKeychainIfNecessary(authManager: authManager)
        setupRootViewController()
        authManager?.initTokenExpieryTimer()
        listenToAppState()
        localAuthManager = LocalAuthManager()
        localAuthManager?.listenToAppStates()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
    }
    
    private func clearKeychainIfNecessary(authManager: AuthManager?) {
        if !Defaults.hasAppLaunchedBefore {
            authManager?.clearData()
            Defaults.hasAppLaunchedBefore = true
        }
        guard let loginStatus = Defaults.loginProcessStatus else {
            if authManager?.isAuthenticated == true {
                authManager?.clearData()
            }
            return
        }
        if loginStatus.hasStartedLoginProcess && !loginStatus.hasCompletedLoginProcess {
            authManager?.clearData()
        }
        // Note: This is also where we can handle refetch logic - though for now, we are going to adjust this to occur on app launch
    }
    
    private func listenToAppState() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func didBecomeActive(_ notification: Notification) {
        NotificationCenter.default.post(name: .launchedFromBackground, object: nil)
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        NotificationCenter.default.post(name: .didEnterBackground, object: nil)
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
    func addLoadingViewHack(addToView view: UIView? = nil) {
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        loadingViewHack = UIView(frame: rect)
        loadingViewHack?.isUserInteractionEnabled = true
        loadingViewHack?.backgroundColor = .white
        loadingViewHack?.startLoadingIndicator(backgroundColor: .white)
        let tap = UIGestureRecognizer(target: self, action: #selector(dismissLoadingHack))
        loadingViewHack?.addGestureRecognizer(tap)
        if let view = view {
            view.addSubview(loadingViewHack!)
        } else {
            self.window?.addSubview(loadingViewHack!)
        }
        
    }
    
    func removeLoadingViewHack() {
        loadingViewHack?.endLoadingIndicator()
        loadingViewHack?.removeFromSuperview()
    }
    
    @objc private func dismissLoadingHack(_ sender: UIGestureRecognizer? = nil) {
        self.removeLoadingViewHack()
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
