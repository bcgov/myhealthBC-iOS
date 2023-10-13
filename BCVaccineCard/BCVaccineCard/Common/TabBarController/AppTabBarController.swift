//
//  AppTabBarController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-09.
//

import UIKit


class AppTabBarController: UITabBarController {
    
    class func construct(authManager: AuthManager,
                         syncService: SyncService,
                         networkService: Network,
                         configService: MobileConfigService
    ) -> AppTabBarController {
        if let vc =  UIStoryboard(name: "AppTabBar", bundle: nil).instantiateViewController(withIdentifier: String(describing: AppTabBarController.self)) as? AppTabBarController {
            vc.authManager = authManager
            vc.syncService = syncService
            vc.networkService = networkService
            vc.configService = configService
            return vc
        }
        return AppTabBarController()
    }
    
    private var authManager: AuthManager?
    private var syncService: SyncService?
    private var networkService: Network?
    private var configService: MobileConfigService?
    private var networkListener: NetworkConnection?
    private var patient: Patient?
    
    /// Currently available tabs
    var currentTabs: [AppTabs] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkListener = NetworkConnection()
        networkListener?.initListener { connected in
            if connected {
                self.whenConnected()
            } else {
                self.whenDisconnected()
            }
        }
        
        showForceUpateIfNeeded() { updateNeeded in
            guard !updateNeeded else {return}
            if self.authManager?.isAuthenticated == true {
                let storedPatient = StorageService.shared.fetchAuthenticatedPatient()
                self.patient = storedPatient
            }
            self.setup(selectedIndex: 0)
            self.setupListeners()
            self.showOnBoardingIfNeeded() { authenticatedDuringOnBoarding in
                self.setup(selectedIndex: 0)
                if authenticatedDuringOnBoarding {
                    self.performSync()
                }
            }
        }
    }
    
    override var selectedIndex: Int {
        didSet {
            guard let selectedVC = viewControllers?[selectedIndex] else { return }
            selectedViewController?.tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansBoldWithSize(size: 10)], for: .normal)
        }
    }
    
    override var selectedViewController: UIViewController? {
        didSet {
            guard let vcs = viewControllers else { return }
            for vc in vcs {
                if vc == selectedViewController {
                    vc.tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansBoldWithSize(size: 10)], for: .normal)
                } else {
                    vc.tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansRegularWithSize(size: 10)], for: .normal)
                }
            }
        }
    }
    
    // MARK: Events
    private func setupListeners() {
        // When authentication status changes, we can set the records tab to the appropriate VC
        // and fetch records - after validation
        AppStates.shared.listenToAuth { authenticated in
            self.performSync()
        }
        
        // Listen to Terms of service acceptance
        AppStates.shared.listenToTermsOfServiceAgreement { accepted in
            if !accepted {
                self.logout(reason: .TOSRejected, completion: {})
            } else {
                self.performSync()
            }
        }
        
        // Local auth happens on records tab only.
        // When its done, we should fetch records if user is authenticated.
        AppStates.shared.listenLocalAuth {
            self.performSync(showToast: false)
        }
        
        // When patient profile is stored, reload tabs
        AppStates.shared.listenToPatient {
            let storedPatient = StorageService.shared.fetchAuthenticatedPatient()
            self.patient = storedPatient
            self.setTabs()
        }
        
        // Sync when requested manually
        AppStates.shared.listenToSyncRequest {
            self.performSync()
        }
    }
    
    // MARK: Auth and validation
    private func validateAuthenticatedUser(completion: @escaping(Bool) -> Void) {
        guard let networkService = networkService, let authManager = authManager, let configService = configService else {
            return completion(false)
        }
        let patientService = PatientService(network: networkService, authManager: authManager, configService: configService)
        
        patientService.validateProfile {[weak self] validationResult in
            guard let `self` = self else {return}
            switch validationResult {
            case .UnderAge:
                self.logout(reason: .Underage, completion: {
                    return completion(false)
                })
            case .TOSNotAccepted, .TOSUpdated:
                if let presented = self.presentedViewController {
                    self.presentedViewController?.dismiss(animated: true) {
                        self.show(route: .TermsOfService, withNavigation: false)
                    }
                } else {
                    self.show(route: .TermsOfService, withNavigation: false)
                }
                return completion(false)
            case .CouldNotValidate:
                self.logout(reason: .FailedToValidate, completion: {
                    return completion(false)
                })
            case .Valid:
                return completion(true)
            }
        }
    }
    
    func logout(reason: AuthManager.AutoLogoutReason, completion: @escaping()->Void) {
        authManager?.signout(in: self, completion: {[weak self] success in
            guard let `self` = self else {return}
            self.authManager?.clearData()
            switch reason {
            case .Underage:
                self.showAlertForUserUnder(ageInYears: Constants.AgeLimit.ageLimitForRecords)
                return completion()
            case .FailedToValidate:
                self.showAlertForUserProfile()
                return completion()
            case .TOSRejected:
                self.showTermOfServiceRejected()
                return completion()
            }
        })
    }
    
    func showTermOfServiceRejected() {
        let message = String.termsOfServiceMessage
        self.alert(title: .termsOfService, message: message)
    }
    
    func showAlertForUserUnder(ageInYears age: Int) {
        self.alert(title: .ageRestriction, message: .ageRestrictionMessage(age: String(age)))
    }
    
    func showAlertForUserProfile() {
        self.alert(title: .loginError, message: .loginErrorMessage)
    }
    
    private func showSuccessfulLoginAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.alert(title: .loginSuccess, message: .recordsWillBeAutomaticallyAdded)
        }
    }
    
    // MARK: OnBoard
    private func showOnBoardingIfNeeded(completion: @escaping(_ authenticated: Bool)->Void) {
        let unseen = Defaults.unseenOnBoardingScreens()
        guard let first = unseen.first else {
            return completion(false)
        }
        let vm = InitialOnboardingViewController.ViewModel(delegate: self, startScreenNumber: first, screensToShow: unseen, completion: completion)
        let vc = InitialOnboardingViewController.construct(viewModel: vm)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
    
    // MARK: Setup
    private func setup(selectedIndex: Int) {
        tabBar.tintColor = AppColours.appBlue
        tabBar.unselectedItemTintColor = AppColours.textGray
        tabBar.barTintColor = .white
        tabBar.isHidden = false
        setTabs()
    }
    
    // MARK: Sync
    func performSync(showDialog: Bool? = false, showToast: Bool = true) {
        setTabs()
        guard authManager?.isAuthenticated == true, NetworkConnection.shared.hasConnection == true else {
            return
        }
        self.validateAuthenticatedUser() { valid in
            guard valid else {
                self.setTabs()
                return
            }
            if let showDialog = showDialog, showDialog {
                self.showSuccessfulLoginAlert()
            }
            self.syncService?.performSync(showToast: showToast) {[weak self] patient in
                self?.setTabs()
            }
        }
    }
    
    // MARK: Set and create tabs
    private func setTabs() {
        if AuthManager().authToken != nil {
            currentTabs = authenticatedTabs
            viewControllers = setViewControllers(tabs: authenticatedTabs)
        } else {
            currentTabs = unAuthenticatedTabs
            viewControllers = setViewControllers(tabs: unAuthenticatedTabs)
        }
        tabBar.isHidden = false
        view.layoutIfNeeded()
        tabBar.layoutIfNeeded()
    }
    
    private func setViewControllers(tabs: [AppTabs]) -> [UIViewController] {
        return tabs.compactMap({setViewController(tab: $0)})
    }
    
    private func setViewController(tab vc: AppTabs) -> UIViewController? {
        
        guard let authManager = authManager,
              let syncService = syncService,
              let networkService = networkService,
              let configService = configService
        else {
            return nil
        }
        
        guard let properties = vc.properties(
            delegate: self,
            authManager: authManager,
            syncService: syncService,
            networkService: networkService,
            configService: configService,
            patient: self.patient
        )  else {
            return nil
        }
        
        let tabBarItem = UITabBarItem(title: properties.title, image: properties.unselectedTabBarImage, selectedImage: properties.selectedTabBarImage)
//        tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansBoldWithSize(size: 10)], for: .normal)
        tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansRegularWithSize(size: 10)], for: .normal)
        let viewController = properties.baseViewController
        viewController.tabBarItem = tabBarItem
        viewController.title = properties.title
        let navController = CustomNavigationController.init(rootViewController: viewController)
        return navController
    }
    
    func whenConnected() {
        showForceUpateIfNeeded(completion: {_ in})
        if !SessionStorage.syncPerformedThisSession, SessionStorage.lastLocalAuth != nil {
            performSync()
        }
    }
    
    func whenDisconnected() {
        
    }
}


extension AppTabBarController: TabDelegate {
    func switchTo(tab: AppTabs) {
        let availableTabs: [AppTabs]
        if AuthManager().isAuthenticated {
            availableTabs = authenticatedTabs
        } else {
            availableTabs = unAuthenticatedTabs
        }
        self.selectedIndex = availableTabs.firstIndex(where: {$0 == tab}) ?? 0
    }
    
    func showLogin() {
        showLogin(initialView: .Landing, presentationStyle: .fullScreen, showTabOnSuccess: .Home)
    }
}
