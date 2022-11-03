//
//  TabBarController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-20.
//

import UIKit

enum TabBarVCs: Int {
    case home = 0, records, healthPass, dependant ,resource
//    case newsFeed
    
    var getIndexOfTab: Int {
        return self.rawValue
    }
    
    struct Properties {
        let title: String
        let selectedTabBarImage: UIImage
        let unselectedTabBarImage: UIImage
        let baseViewController: UIViewController
    }
    
    var properties: Properties? {
        switch self {
        case .home:
            return Properties(title: "Home", selectedTabBarImage: #imageLiteral(resourceName: "home-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "home-tab-unselected"), baseViewController: HomeScreenViewController.constructHomeScreenViewController())
        case .records:
            return Properties(title: .records, selectedTabBarImage: #imageLiteral(resourceName: "records-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "records-tab-unselected"), baseViewController: HealthRecordsViewController.constructHealthRecordsViewController())
        case .healthPass:
            return Properties(title: .passes, selectedTabBarImage: #imageLiteral(resourceName: "passes-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "passes-tab-unselected"), baseViewController: HealthPassViewController.constructHealthPassViewController(fedPassStringToOpen: nil))
        case .dependant:
            return Properties(title: .dependent, selectedTabBarImage: #imageLiteral(resourceName: "dependent-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "dependent-tab-unselected"), baseViewController: DependentsHomeViewController.constructDependentsHomeViewController(patient: StorageService.shared.fetchAuthenticatedPatient()))
        case .resource:
            return Properties(title: .resources, selectedTabBarImage: #imageLiteral(resourceName: "resource-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "resource-tab-unselected"), baseViewController: ResourceViewController.constructResourceViewController())
//        case .newsFeed:
//            return Properties(title: .newsFeed, selectedTabBarImage: #imageLiteral(resourceName: "news-feed-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "news-feed-tab-unselected"), baseViewController: NewsFeedViewController.constructNewsFeedViewController())
        }
    }
}

class TabBarController: UITabBarController {
    
    class func constructTabBarController(status: AuthenticationViewController.AuthenticationStatus? = nil) -> TabBarController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: TabBarController.self)) as? TabBarController {
            vc.authenticationStatus = status
            return vc
        }
        return TabBarController()
    }
    
    private var previousSelectedIndex: Int?
    private var updateRecordsScreenState = false
    private var authenticationStatus: AuthenticationViewController.AuthenticationStatus?
    var authWorker: AuthenticatedHealthRecordsAPIWorker?
    private var throttleAPIWorker: LoginThrottleAPIWorker?
    var routerWorker: RouterWorker?

    override func viewDidLoad() {
        super.viewDidLoad()
        BaseURLWorker.setup(BaseURLWorker.Config(delegateOwner: self))
        showForceUpateIfNeeded(completion: { updateNeeded in
            guard !updateNeeded else {return}
            BaseURLWorker.shared.setBaseURL {
                self.authWorker = AuthenticatedHealthRecordsAPIWorker(delegateOwner: self)
                self.throttleAPIWorker = LoginThrottleAPIWorker(delegateOwner: self)
                self.routerWorker = RouterWorker(delegateOwner: self)
                self.setup(selectedIndex: 0)
                self.showLoginPromptIfNecessary()
            }
        })
        
        
    }
    
    private func showLoginPromptIfNecessary() {
        guard let authStatus = self.authenticationStatus else { return }
        if authStatus == .Completed {
            AuthenticationViewController.checkIfUserCanLoginAndFetchRecords(authWorker: self.authWorker, sourceVC: .AfterOnboarding) { allowed in
                if allowed {
                    self.showSuccessfulLoginAlert()
                    self.customRoutingForRecordsTab(authStatus: authStatus)
                }
            }
        }
    }
    
    private func customRoutingForRecordsTab(authStatus: AuthenticationViewController.AuthenticationStatus) {
        let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentRecordsFlow())
        let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentPassesFlow())
        let scenario = AppUserActionScenarios.LoginSpecialRouting(values: ActionScenarioValues(currentTab: .home, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails, loginSourceVC: .AfterOnboarding, authenticationStatus: authStatus))
        self.routerWorker?.routingAction(scenario: scenario, delayInSeconds: 0.5)
    }

    private func setup(selectedIndex: Int) {
        self.tabBar.tintColor = AppColours.appBlue
        self.tabBar.barTintColor = .white
        self.delegate = self
        self.viewControllers = setViewControllers(withVCs: [.home, .records, .healthPass, .dependant])
        self.scrapeDBForEdgeCaseRecords(authManager: AuthManager(), currentTab: TabBarVCs.init(rawValue: self.selectedIndex) ?? .home, onActualLaunchCheck: true)
        self.selectedIndex = selectedIndex
        setupObserver()
        postBackgroundAuthFetch()
    }
    
    // Note: Leaving this in the notification pattern for now, as perhaps we will call it in a different location (if there are any issues calling it here, that is)
    private func postBackgroundAuthFetch() {
        guard let token = AuthManager().authToken else { return }
        guard let hdid = AuthManager().hdid else { return }
        checkForExpiredUser()
        NotificationCenter.default.post(name: .backgroundAuthFetch, object: nil, userInfo: ["authToken": token, "hdid": hdid])
    }
    
    // Note: This will handle the edge case where we have an authenticated user who's token expired, then user logged in with different credentials, and then killed the app before the check for this edge case could be executed in the AuthenticatedHealthRecordsAPIWorker
    private func checkForExpiredUser() {
        if let authStatus = Defaults.loginProcessStatus,
           authStatus.hasCompletedLoginProcess == true,
           authStatus.hasFinishedFetchingRecords == false,
           let storedName = authStatus.loggedInUserAuthManagerDisplayName,
           let currentName = AuthManager().displayName,
           storedName != currentName {
            StorageService.shared.deleteHealthRecordsForAuthenticatedUser()
            StorageService.shared.deleteAuthenticatedPatient(with: storedName)
            AuthManager().clearMedFetchProtectiveWordDetails()
        }
    }
    
    private func setViewControllers(withVCs vcs: [TabBarVCs]) -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        vcs.forEach { vc in
            guard let properties = vc.properties  else { return }
            let tabBarItem = UITabBarItem(title: properties.title, image: properties.unselectedTabBarImage, selectedImage: properties.selectedTabBarImage)
            tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansBoldWithSize(size: 10)], for: .normal)
            let viewController = properties.baseViewController
            viewController.tabBarItem = tabBarItem
            viewController.title = properties.title
            let navController = CustomNavigationController.init(rootViewController: viewController)
            viewControllers.append(navController)
        }
        return viewControllers
    }
    
    private func setupObserver() {
        NotificationManager.listenToShowTermsOfService(observer: self, selector: #selector(showTermsOfService))
        NotificationManager.listenToTermsOfServiceResponse(observer: self, selector: #selector(termsOfServiceResponse))
        NotificationCenter.default.addObserver(self, selector: #selector(tabChanged), name: .tabChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundAuthFetch), name: .backgroundAuthFetch, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(protectedWordRequired), name: .protectedWordRequired, object: nil)
    }
    
    @objc private func showTermsOfService(_ notification: Notification) {
        guard let authToken = AuthManager().authToken, let hdid = AuthManager().hdid else { return }
        let creds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
        let vc = TermsOfServiceViewController.constructTermsOfServiceViewController(authWorker: self.authWorker, authCredentials: creds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.present(vc, animated: true)
        }
    }
    
    @objc private func termsOfServiceResponse(_ notification: Notification) {
        if let error = notification.userInfo?[Constants.GenericErrorKey.key] as? String {
            let title = notification.userInfo?[Constants.GenericErrorKey.titleKey] as? String ?? .error
            showError(error: error, title: title, resetRecordsTab: true)
        } else {
            guard let response = notification.userInfo?[Constants.TermsOfServiceResponseKey.key] as? Bool, response == true else { return }
            self.showSuccessfulLoginAlert()
        }
    }
    
    @objc private func tabChanged(_ notification: Notification) {
        guard let viewController = (notification.userInfo?["viewController"] as? CustomNavigationController)?.visibleViewController else { return }
        if viewController is NewsFeedViewController {
            NotificationCenter.default.post(name: .reloadNewsFeed, object: nil, userInfo: nil)
        }
    }
    
    @objc private func backgroundAuthFetch(_ notification: Notification) {
        guard let authToken = notification.userInfo?["authToken"] as? String, let hdid = notification.userInfo?["hdid"] as? String else { return }
        let authCreds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
        self.throttleAPIWorker?.throttleHGMobileConfigEndpoint(completion: { response in
            if response == .Online {
                self.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: false, isManualFetch: false, protectiveWord: AuthManager().protectiveWord,sourceVC: .BackgroundFetch)
            }
        })
    }
    
    private func showSuccessfulLoginAlert() {
        self.alert(title: .loginSuccess, message: .recordsWillBeAutomaticallyAdded)
        guard let authToken = AuthManager().authToken, let hdid = AuthManager().hdid else { return }
        let authCreds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
        let protectiveWord = AuthManager().protectiveWord
        self.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: true, isManualFetch: true, protectiveWord: protectiveWord, sourceVC: .AfterOnboarding)
        
    }
    
    private func showError(error: String, title: String, resetRecordsTab: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.alert(title: title, message: error) {
                if resetRecordsTab {
                    self.resetRecordsTab()
                }
            }
        }
    }

}

// MARK: Reset Records Tab
extension TabBarController {
    private func resetRecordsTab() {
        let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentRecordsFlow())
        let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentPassesFlow())
        let currentTab = TabBarVCs.init(rawValue: self.selectedIndex) ?? .home
        let scenario = AppUserActionScenarios.TermsOfServiceRejected(values: ActionScenarioValues(currentTab: currentTab, affectedTabs: [.records], recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails, loginSourceVC: nil, authenticationStatus: nil))
        self.routerWorker?.routingAction(scenario: scenario, delayInSeconds: 0.0)
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Save the previously selected index, so that we can check if the tab was selected again
        self.previousSelectedIndex = tabBarController.selectedIndex
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        NotificationCenter.default.post(name: .tabChanged, object: nil, userInfo: ["viewController": viewController])
    }
}

// MARK: Auth Fetch delegates
extension TabBarController: AuthenticatedHealthRecordsAPIWorkerDelegate {
    func showPatientDetailsError(error: String, showBanner: Bool) {
        guard showBanner else { return }
        showToast(message: error, style: .Warn)
    }
    
    func showFetchStartedBanner(showBanner: Bool) {
        guard showBanner else { return }
        showToast(message: "Retrieving records", style: .Default)
    }
    
    func showFetchCompletedBanner(recordsSuccessful: Int, recordsAttempted: Int, errors: [AuthenticationFetchType : String]?, showBanner: Bool, resetHealthRecordsTab: Bool, loginSourceVC: LoginVCSource, fetchStatusTypes: [AuthenticationFetchType]) {
        guard showBanner else { return }
        // TODO: Connor - handle error case
        if resetHealthRecordsTab {
            guard let patient = StorageService.shared.fetchAuthenticatedPatient() else { return }
            DispatchQueue.main.async {
                let currentTab = TabBarVCs.init(rawValue: self.selectedIndex) ?? .home
                let flowStack = self.getCurrentRecordsAndPassesFlows()
                let recordFlowDetails = RecordsFlowDetails(currentStack: flowStack.recordsStack, actioningPatient: patient, addedRecord: nil)
                let passesFlowDetails = PassesFlowDetails(currentStack: flowStack.passesStack)
                self.routerWorker?.routingAction(scenario: .AuthenticatedFetch(values: ActionScenarioValues(currentTab: currentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails, loginSourceVC: loginSourceVC)))
            }
        }
        // TODO: Make this a little more reusable - hacky approach
        if (fetchStatusTypes.contains(.LaboratoryOrders) && fetchStatusTypes.contains(.MedicationStatement) && fetchStatusTypes.contains(.SpecialAuthorityDrugs) && fetchStatusTypes.contains(.TestResults) && fetchStatusTypes.contains(.VaccineCard)) && fetchStatusTypes.contains(.Immunizations) && fetchStatusTypes.contains(.HealthVisits) || (fetchStatusTypes.contains(.MedicationStatement) && fetchStatusTypes.contains(.Comments)) {
            let message = (recordsSuccessful >= recordsAttempted || errors?.count == 0) ? "Records retrieved" : "Not all records were fetched successfully"
            showToast(message: message)
        }
        NotificationCenter.default.post(name: .authFetchComplete, object: nil, userInfo: nil)
        var loginProcessStatus = Defaults.loginProcessStatus ?? LoginProcessStatus(hasStartedLoginProcess: true, hasCompletedLoginProcess: true, hasFinishedFetchingRecords: false, loggedInUserAuthManagerDisplayName: AuthManager().displayName)
        loginProcessStatus.hasFinishedFetchingRecords = true
        Defaults.loginProcessStatus = loginProcessStatus
    }
    func showAlertForLoginAttemptDueToValidation(error: ResultError?) {
        Logger.log(string: error?.localizedDescription ?? "", type: .Network)
        self.alert(title: "Login Error", message: "We're sorry, there was an error logging in. Please try again later.")
    }
    
    func showAlertForUserUnder(ageInYears age: Int) {
        self.alert(title: "Age Restriction", message: "You must be \(age) year's of age or older to use Health Gateway.")
    }
    
    func showAlertForUserProfile(error: ResultError?) {
        self.alert(title: "Error", message: error?.resultMessage ?? "Unexpected error")
    }
}

// MARK: This is to handle the protected word prompt
extension TabBarController {
    @objc private func protectedWordRequired(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String] else { return }
        guard let purposeRawValue = userInfo[ProtectiveWordPurpose.purposeKey], let purpose = ProtectiveWordPurpose(rawValue: purposeRawValue) else { return }
        let vc = ProtectiveWordPromptViewController.constructProtectiveWordPromptViewController(purpose: purpose)
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: This is an edge case function that we will use in both HealthRecordsVC and UserListOfRecords VC
extension TabBarController {
    // NOTE: This is a hacky check to see if there are patient records that are stored that shouldn't be stored (This occurs if a user logs out while they are fetching records in the background - new records will continue to be stored after the user logs out)
    func scrapeDBForEdgeCaseRecords(authManager: AuthManager, currentTab: TabBarVCs, onActualLaunchCheck: Bool? = nil) {
        if authManager.authToken == nil, let _ = StorageService.shared.fetchAuthenticatedPatient() {
            // This means the user has manually logged out, but there are still remainning records - Scrub records
            StorageService.shared.deleteHealthRecordsForAuthenticatedUser()
            StorageService.shared.deleteAuthenticatedPatient()
            let values = ActionScenarioValues(currentTab: currentTab, affectedTabs: [.records])
            self.routerWorker?.routingAction(scenario: AppUserActionScenarios.InitialAppLaunch(values: values))
        } else if onActualLaunchCheck == true {
            // In the event that there is an auth token, then user us logged in and we have to reset stack accordingly
            self.routerWorker?.routingAction(scenario: .InitialAppLaunch(values: ActionScenarioValues(currentTab: TabBarVCs.init(rawValue: self.selectedIndex) ?? .home, affectedTabs: [.records], recordFlowDetails: nil, passesFlowDetails: nil)))
        }
    }

}

// MARK: Router worker
extension TabBarController: RouterWorkerDelegate {    
    func recordsActionScenario(viewControllerStack: [BaseViewController], goToTab: Bool, delayInSeconds: Double) {
        DispatchQueue.main.async {
            let goToRecordsTab = goToTab ? TabBarVCs.records : nil
            self.resetTab(tabBarVC: .records, viewControllerStack: viewControllerStack, goToTab: goToRecordsTab, delayInSeconds: delayInSeconds)
        }
    }
    
    func passesActionScenario(viewControllerStack: [BaseViewController], goToTab: Bool, delayInSeconds: Double) {
        DispatchQueue.main.async {
            let goToPassesTab = goToTab ? TabBarVCs.healthPass : nil
            self.resetTab(tabBarVC: .healthPass, viewControllerStack: viewControllerStack, goToTab: goToPassesTab, delayInSeconds: delayInSeconds)
        }
    }

}

// MARK: Router helper functions
extension TabBarController {
    private func resetTab(tabBarVC: TabBarVCs, viewControllerStack: [BaseViewController], goToTab: TabBarVCs?, delayInSeconds: Double) {
        guard viewControllerStack.count > 0 else { return }
        let vc = tabBarVC
        guard let properties = vc.properties else { return }
        let tabBarItem = UITabBarItem(title: properties.title, image: properties.unselectedTabBarImage, selectedImage: properties.selectedTabBarImage)
        tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansBoldWithSize(size: 10)], for: .normal)
        guard let rootViewController = viewControllerStack.first else { return }
        rootViewController.tabBarItem = tabBarItem
        rootViewController.title = properties.title

        DispatchQueue.main.async {
            if let nav = self.viewControllers?[tabBarVC.rawValue] as? CustomNavigationController {
                var vcStack: [BaseViewController] = []
                for vc in viewControllerStack {
                    // Not sure why, but I have to do this to get rid of the text - can look into removind navigationItem.title text from nav controll itself
                    vc.navigationItem.setBackItemTitle(with: "")
                    vcStack.append(vc)
                }
                
                nav.viewControllers = vcStack
    
                if delayInSeconds > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                        nav.viewControllers = vcStack
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if let goToTab = goToTab {
                            self.selectedIndex = goToTab.rawValue
                        }
                        AppDelegate.sharedInstance?.removeLoadingViewHack()
                    }
                    
                }
            }
        }
    }
}

// MARK: Router helper to construct current tabs in enum values
extension TabBarController {
    public func getCurrentRecordsAndPassesFlows() -> CurrentRecordsAndPassesStacks {
        let recordsStack = self.getCurrentRecordsFlow()
        let passesStack = self.getCurrentPassesFlow()
        return CurrentRecordsAndPassesStacks(recordsStack: recordsStack, passesStack: passesStack)
    }
    
    private func getCurrentRecordsFlow() -> [RecordsFlowVCs] {
        guard let vcs = (self.viewControllers?[TabBarVCs.records.rawValue] as? CustomNavigationController)?.viewControllers as? [BaseViewController] else { return [] }
        var flow: [RecordsFlowVCs] = []
        for vc in vcs {
            if let type = vc.getRecordFlowType {
                flow.append(type)
            }
        }
        return flow
    }
    
    private func getCurrentPassesFlow() -> [PassesFlowVCs] {
        guard let vcs = (self.viewControllers?[TabBarVCs.healthPass.rawValue] as? CustomNavigationController)?.viewControllers as? [BaseViewController] else { return [] }
        var flow: [PassesFlowVCs] = []
        for vc in vcs {
            if let type = vc.getPassesFlowType {
                flow.append(type)
            }
        }
        return flow
    }
}
