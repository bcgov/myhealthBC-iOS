//
//  AppDelegate.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-14.
//

import UIKit
import CoreData
import BCVaccineValidator
import EncryptedCoreData
//import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let sharedInstance = UIApplication.shared.delegate as? AppDelegate
    var window: UIWindow?
    
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
        setupGatewayFactory()
        setupRootViewController()
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

// MARK: Gateway setup
extension AppDelegate {
    private func setupGatewayFactory() {
        GatewayAccess.initialize(withFactory: WorkerFactory(remoteFactory: RemoteFactory()))
    }
    
}

// MARK: Root setup
extension AppDelegate {
    private func setupRootViewController() {
        let unseen = Defaults.unseenOnBoardingScreens()
        guard let first = unseen.first else {
            let vc = TabBarController.constructTabBarController()
            self.window?.rootViewController = vc
            // Display Auth
            self.performLocalAuth(on: vc)
            return
        }
        
        let vc = InitialOnboardingViewController.constructInitialOnboardingViewController(startScreenNumber: first, screensToShow: unseen)
        self.window?.rootViewController = vc
        // Display Auth
        self.performLocalAuth(on: vc)
    }
    
    private func performLocalAuth(on viewController: UIViewController) {
        let manager = LocalAuthManager()
        if manager.availableAuthMethods().isEmpty {
            localNoAvailableAuth()
            return
        }
        // Use the manager to perform authentication. It has a view of its own which is auto dismissed.
        // localAuthFailed () is called if it was unsuccessful for FE to know how to handle it
        manager.performLocalAuth(on: viewController) { [weak self] status in
            if status != .Authorized {self?.localAuthFailed()}
        }
    }
    
    private func localAuthFailed() {
        //TODO:
    }
    
    private func localNoAvailableAuth() {
        //TODO:
        self.window?.rootViewController?.view.startLoadingIndicator(backgroundColor: .white)
        self.window?.rootViewController?.alert(title: "Unsecure device", message: "Please enable authentication on your device to proceed")
    }
}

