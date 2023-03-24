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
    
    private var authenticatedTabs: [AppTabs] {
        return [.Home, .AuthenticatedRecords, .Proofs, .Dependents]
    }
    
    private var unAuthenticatedTabs: [AppTabs] {
        return [.Home, .UnAuthenticatedRecords, .Proofs, .Dependents]
    }
    
    /// Currently available tabs
    var currentTabs: [AppTabs] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkListener?.initListener { connected in
            if connected {
                self.whenConnected()
            } else {
                self.whenDisconnected()
            }
        }
        
        showForceUpateIfNeeded() { updateNeeded in
            guard !updateNeeded else {return}
            self.setup(selectedIndex: 0)
            self.setupListeners()
            self.showOnBoardingIfNeeded() { authenticatedDuringOnBoarding in
                self.setup(selectedIndex: 0)
                if authenticatedDuringOnBoarding {
                    self.showSuccessfulLoginAlert()
                    self.performSync()
                }
            }
        }
    }
    
    private func setupListeners() {
        // When authentication status changes, we can set the records tab to the appropriate VC
        // and fetch records
        AppStates.shared.listenToAuth { authenticated in
            if authenticated {
                self.showSuccessfulLoginAlert()
            }
            self.setTabs()
            self.performSync()
        }
        
        // Local auth happens on records tab only.
        // When its done, we should fetch records if user is authenticated.
        AppStates.shared.listenLocalAuth {
            self.performSync()
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
    
    private func showSuccessfulLoginAlert() {
        self.alert(title: .loginSuccess, message: .recordsWillBeAutomaticallyAdded)
    }
    
    // MARK: Setup
    private func setup(selectedIndex: Int) {
        tabBar.tintColor = AppColours.appBlue
        tabBar.barTintColor = .white
        tabBar.isHidden = false
        setTabs()
    }
    
    // MARK: Sync
    func performSync() {
        guard authManager?.isAuthenticated == true else {
            setTabs()
            return
        }
        syncService?.performSync() {[weak self] patient in
            self?.setTabs()
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
        tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansBoldWithSize(size: 10)], for: .normal)
        let viewController = properties.baseViewController
        viewController.tabBarItem = tabBarItem
        viewController.title = properties.title
        let navController = CustomNavigationController.init(rootViewController: viewController)
        return navController
    }
    
    func whenConnected() {
        showForceUpateIfNeeded(completion: {_ in})
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
}
