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
    var networkService: Network?
    var syncService: SyncService?
    var configService: MobileConfigService?
    
    
    var coreDataContext: NSManagedObjectContext?
    
    fileprivate var dataLoadCount: Int = 0 
    internal var dataLoadHideTimer: Timer? = nil
    internal var dataLoadTag = 9912341
    internal var dataLoadTextTag = 9912342
    internal var loaderCallers: [LoaderCaller] = []
    
    var cachedCommunicationPreferences: CommunicationPreferences?
    
    // Note - this is used to smooth the transition when adding a health record and showing the detail screen
    private var loadingViewHack: UIView?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UpdateServiceStorage.setOrResetstoredAppVersion()
        MigrationService().removeExistingDBIfNeeded()
        CoreDataProvider.shared.loadManagedContext { context in
            if context == nil {
                // Could not load storage
                self.showDBLoadError()
            } else {
                self.coreDataContext = context
                self.configure()
            }
        }
        
        return true
    }
    
    private func configure() {
        AppStates.shared.listen()
        //use .Prod or .Test for different endpoints for keys
#if PROD
        BCVaccineValidator.shared.setup(mode: .Prod, remoteRules: false)
#elseif TEST
        BCVaccineValidator.shared.setup(mode: .Test, remoteRules: false)
#elseif DEV
        BCVaccineValidator.shared.setup(mode: .Test, remoteRules: false)
#endif
        AnalyticsService.shared.setup()
        
        let networkService = AFNetwork()
        let authManager = AuthManager()
        let configService = MobileConfigService(network: networkService)
        let syncService = SyncService(network: networkService, authManager: authManager, configService: configService)
        SessionStorage.protectiveWordEnabled = authManager.protectiveWord != nil
        self.networkService = networkService
        self.authManager = authManager
        self.configService = configService
        self.syncService = syncService
        
        clearKeychainIfNecessary(authManager: authManager)
        setupRootViewController()
        authManager.initAuthExpieryTimer()
        listenToAppState()
        localAuthManager = LocalAuthManager()
        localAuthManager?.listenToAppStates()
        initNetworkListener()
        initKeyboardManager()
        
        AppStates.shared.listenToAuth { authenticated in
            if authenticated {
                authManager.initAuthExpieryTimer()
            }
        }
    }
    
    private func initKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [HealthRecordDetailViewController.self, NoteViewController.self]
    }
    
    private func initNetworkListener() {
        NetworkConnection.shared.initListener(onChange: {isOnline in
            if isOnline {
                self.whenAppisOnline()
            }
        })
    }
    
    // Perform whatever app needs to do when it comes onlines
    private func whenAppisOnline() {
        guard NetworkConnection.shared.hasConnection else {return}
        self.syncCommentsIfNeeded()
    }
    
    private func syncCommentsIfNeeded() {
        CommentService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork())).submitUnsyncedComments{}
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
        /*add necessary support for migration*/
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions =  [description]
        /*add necessary support for migration*/
        do {
            let options = [
                EncryptedStorePassphraseKey : CoreDataEncryptionKeyManager.shared.key
            ]
            
            // TODO: fix for 'NSKeyedUnarchiveFromData' should not be used
            //https://github.com/project-imas/encrypted-core-data/compare/master...fitmecare:encrypted-core-data:master
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
    
    
//    // MARK: - Core Data Saving support
//
//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
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
    func setupRootViewController() {
        guard let authManager = authManager,
              let syncService = syncService,
              let networkService = networkService,
              let configService = configService
            else {
            showToast(message: "Fatal Error")
            return
        }
        let vc = AppTabBarController.construct(authManager: authManager,
                                               syncService: syncService,
                                               networkService: networkService,
                                               configService: configService)
        self.window?.rootViewController = vc
//        let unseen = Defaults.unseenOnBoardingScreens()
//        guard let first = unseen.first else {
//            let vc = AppTabBarController.construct(authManager: authManager,
//                                                   syncService: syncService,
//                                                   networkService: networkService,
//                                                   configService: configService)
//            self.window?.rootViewController = vc
//            return
//        }
//
//        let vc = InitialOnboardingViewController.constructInitialOnboardingViewController(startScreenNumber: first, screensToShow: unseen)
//        self.window?.rootViewController = vc
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

// MARK: Loading UI
enum LoaderMessage: String {
    case SyncingRecords = "Syncing Records"
    case FetchingConfig = " "
    case empty = ""
}

extension LoaderMessage {
    func isNetworkDependent() -> Bool {
        return self == .SyncingRecords || self == .FetchingConfig
    }
}


/// These will help us debug loader issues - for example finding decrementLoader() that never gets called in a function
/// Keep the naming unique for each function: Classname_functionName
enum LoaderCaller {
    case PatientService_fetchAndStoreDetails
    case PatientService_fetchAndStoreOrganDonorStatus
    case PatientService_fetchAndStoreDiagnosticImaging
    case PatientService_validateProfile
    case CovidTestsService_fetchAndStore
    case VaccineCardService_fetchAndStore_Patient
    case VaccineCardService_fetchAndStore_Dependent
    case VaccineCardService_fetchAndStore_DependentsOfPatient
    case VaccineCardService_fetchAndStore_FormInfo
    case ClinicalDocumentService_fetchAndStore
    case DependentService_fetchDependents
    case DependentService_addDependent
    case FeedbackService_postFeedback
    case HealthVisitsService_fetchAndStore
    case MobileConfigService_fetchConfig
    case MedicationService_fetchAndStore
    case SpecialAuthorityDrugService_fetchAndStore
    case HospitalVisitsService_fetchAndStore
    case PDFService_fetchPDF
    case PDFService_DonorStatus
    case PDFService_DiagnosticImaging
    case CommentService_submitUnsyncedComments
    case CommentService_fetchAndStore
    case LabOrderService_fetchAndStore
    case ImmnunizationsService_fetchAndStore
    case HealthRecordsService_fetchAndStore
    case NotificationService_fetchAndStore
    case NotificationService_dismiss
    case NotificationService_dismissAll
    case Notes_fetchAndStore
}


extension AppDelegate {
    // Triggered by dataLoadCount
    func incrementLoader(message: LoaderMessage, caller: LoaderCaller) {
        if !NetworkConnection.shared.hasConnection && message.isNetworkDependent() {
            return
        }
        dataLoadCount += 1
        dataLoadHideTimer?.invalidate()
        showLoader(message: message)
        
        loaderCallers.append(caller)
        Logger.log(string: "\n\nLoader + + + + + + + \nAdded:\n\(caller)\nTotal:\(dataLoadCount)\n\n", type: .general)
    }
    
    func decrementLoader(caller: LoaderCaller) {
        dataLoadCount -= 1
        dataLoadHideTimer?.invalidate()
        if dataLoadCount < 1 {
            dataLoadHideTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hideLoader), userInfo: nil, repeats: false)
        }
        
        if dataLoadCount < 0 {
            dataLoadCount = 0
        }
        if let idx = loaderCallers.firstIndex(of: caller) {
            loaderCallers.remove(at: idx)
        }
        
        Logger.log(string: "\n\nLoader - - - - - - - \nRemoved:\n\(caller)\nRemaining:\n\(dataLoadCount)\n\(loaderCallers)\n\n", type: .general)
    }
    
    /// Do not call this function manually. use dataLoadCount
    fileprivate func showLoader(message: LoaderMessage) {
        // If already shown, dont do anything - just update message
        if let existing = self.window?.viewWithTag(dataLoadTag), let textLabel = existing.viewWithTag(dataLoadTextTag) as? UILabel {
            if textLabel.text == message.rawValue {
                return
            } else if message.rawValue.count > textLabel.text?.count ?? 0 {
                textLabel.text = message.rawValue
                return
            }
            
            return
        }
        
        // if somehow you're here and its already shown... remove it
        self.window?.viewWithTag(dataLoadTag)?.removeFromSuperview()
        // create container and add it to the window
        let loaderView: UIView = UIView(frame: self.window?.bounds ?? .zero)
        // Add below toast if toast is shown
        if let toast = self.window?.viewWithTag(Constants.UI.Toast.tag) {
            window?.insertSubview(loaderView, belowSubview: toast)
        } else {
            window?.addSubview(loaderView)
        }
        
        if window?.rootViewController?.presentedViewController is UIAlertController {
            Logger.log(string: "An alert is being hidden", type: .general)
            // Should handle this OR remove the alert saying data is being fetched afrer login
//            if let alert = window?.rootViewController?.presentedViewController as? UIAlertController  {
//                window?.insertSubview(loaderView, at: <#T##Int#>)
//            }
        }
       
        
        loaderView.tag = dataLoadTag
        
        // Create subviews for indicator and label
        let indicator = UIActivityIndicatorView(frame: .zero)
        let label = UILabel(frame: .zero)
        
        loaderView.addSubview(indicator)
        loaderView.addSubview(label)
        indicator.center(in: loaderView, width: 30, height: 30)
        label.center(in: loaderView, width: loaderView.bounds.width, height: 32, verticalOffset: 32, horizontalOffset: 0)
        
        // Style
        loaderView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        label.textColor = AppColours.appBlue
        label.text = message.rawValue
        label.font = UIFont.bcSansBoldWithSize(size: 17)
        label.textAlignment = .center
        label.tag = dataLoadTextTag
        
        indicator.tintColor = AppColours.appBlue
        indicator.color = AppColours.appBlue
        indicator.startAnimating()
        window?.layoutIfNeeded()
    }
    
    // Triggered by dataLoadCount
    @objc fileprivate func hideLoader() {
        self.window?.viewWithTag(self.dataLoadTag)?.removeFromSuperview()
    }
}

extension AppDelegate {
    func showExternalURL(url: String) {
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "This action requires an internet connection")
            return
        }
        guard let root = window?.rootViewController else {return}
        if let predentedVC = root.presentedViewController {
            predentedVC.openURLInSafariVC(withURL: url)
        } else {
            root.openURLInSafariVC(withURL: url)
        }
    }
}
