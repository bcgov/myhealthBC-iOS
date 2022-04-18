//
//  TabBarController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-20.
//

import UIKit

enum TabBarVCs: Int {
    case home = 0, records, healthPass, resource
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
            return Properties(title: .passes, selectedTabBarImage: #imageLiteral(resourceName: "passes-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "passes-tab-unselected"), baseViewController: HealthPassViewController.constructHealthPassViewController())
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
    
    private func addHealthRecords(hasHealthRecords: Bool) -> TabBarVCs.Properties {
        return TabBarVCs.Properties(title: .records, selectedTabBarImage: #imageLiteral(resourceName: "records-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "records-tab-unselected"), baseViewController: FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true, hasHealthRecords: hasHealthRecords, completion: {}))
    }
    
    private var previousSelectedIndex: Int?
    private var updateRecordsScreenState = false
    private var authenticationStatus: AuthenticationViewController.AuthenticationStatus?
    var authWorker: AuthenticatedHealthRecordsAPIWorker?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.authWorker = AuthenticatedHealthRecordsAPIWorker(delegateOwner: self)
        setup(selectedIndex: 0)
        showLoginPromptIfNecessary()
    }
    
    private func showLoginPromptIfNecessary() {
        guard let authStatus = self.authenticationStatus else { return }
        if authStatus == .Completed {
            AuthenticationViewController.checkIfUserCanLoginAndFetchRecords(authWorker: self.authWorker, sourceVC: .AfterOnboarding) { allowed in
                if allowed {
                    self.showSuccessfulLoginAlert()
                }
            }
        }
    }

    private func setup(selectedIndex: Int) {
        self.tabBar.tintColor = AppColours.appBlue
        self.tabBar.barTintColor = .white
        self.delegate = self
        self.viewControllers = setViewControllers(withVCs: [.home, .records, .healthPass, .resource])
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
            }
    }
    
    private func setViewControllers(withVCs vcs: [TabBarVCs]) -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        vcs.forEach { vc in
            guard let properties = (vc == .records && StorageService.shared.getHeathRecords().isEmpty) ? addHealthRecords(hasHealthRecords: false) : vc.properties  else { return }
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
        Notification.Name.storageChangeEvent.onPost(object: nil, queue: .main) {[weak self] notification in
            guard let `self` = self, let event = notification.object as? StorageService.StorageEvent<Any> else {return}
            // Note: Not sure we need this anymore with health records tab logic
            switch event.entity {
            case .VaccineCard, .CovidLabTestResult, .Patient, .Medication, .LaboratoryOrder:
                if event.event == .Delete, StorageService.shared.getHeathRecords().isEmpty {
                    // If data was deleted and now health records are empty
                    self.resetHealthRecordsTab()
                }
                if event.event == .Save, StorageService.shared.getHeathRecords().count == 1 {
                    self.updateRecordsScreenState = true
                }
            default:
                break
            }
        }
    }
    
    // This function is called within the tab bar 1.) (when records are deleted and go to zero, called in the listener above), and called when the 2.) health records tab is selected, to appropriately show the correct VC, and is called 3.) on the FetchHealthRecordsViewController in the routing section to apporiately reset the health records tab's vc stack and route to the details screen
    func resetHealthRecordsTab(viewControllersToInclude vcs: [UIViewController]? = nil, goToRecordsForPatient patient: Patient? = nil) {
        let vc: TabBarVCs = .records
        guard let properties = (vc == .records && StorageService.shared.getHeathRecords().isEmpty) ? addHealthRecords(hasHealthRecords: false) : vc.properties  else { return }
        let tabBarItem = UITabBarItem(title: properties.title, image: properties.unselectedTabBarImage, selectedImage: properties.selectedTabBarImage)
        tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansBoldWithSize(size: 10)], for: .normal)
        let viewController = properties.baseViewController
        viewController.tabBarItem = tabBarItem
        viewController.title = properties.title
        let navController = CustomNavigationController.init(rootViewController: viewController)
        let isOnRecordsTab = self.selectedIndex == TabBarVCs.records.rawValue
        viewControllers?.remove(at: TabBarVCs.records.rawValue)
        viewControllers?.insert(navController, at: TabBarVCs.records.rawValue)
        if isOnRecordsTab {
            selectedIndex = TabBarVCs.records.rawValue
            // This portion is used to handle the re-setting of the health records VC stack for proper routing - in order to maintain the correct Navigation UI, we must push the VC's onto the stack (and not set the VC's with .setViewControllers() as this causes issues) - the loading view on the app delegate window is to hide the consecutive pushes to make a smoother UI transition - tested and works
            if let vcs = vcs {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    for vc in vcs {
                        if vc.isKind(of: UsersListOfRecordsViewController.self) && navController.viewControllers.contains(where: { $0.isKind(of: UsersListOfRecordsViewController.self) }) {
                            // Don't add duplicate here
                        } else {
                            navController.pushViewController(vc, animated: false)
                        }
                    }
                    AppDelegate.sharedInstance?.removeLoadingViewHack()
                }
            }
        }
        // TODO: Should probably find a cleaner way to do this - but the necessity of the function above will likely change with new design updates
        if let patient = patient {
            selectedIndex = TabBarVCs.records.rawValue
            if let vc = navController.viewControllers.first as? HealthRecordsViewController {
                vc.setPatientToShow(patient: patient)
            }
        }
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
            showError(error: error, title: title)
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
        self.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: false, isManualFetch: false, sourceVC: .BackgroundFetch)
    }
    
    private func showSuccessfulLoginAlert() {
        self.alert(title: .loginSuccess, message: .recordsWillBeAutomaticallyAdded)
        guard let authToken = AuthManager().authToken, let hdid = AuthManager().hdid else { return }
        let authCreds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
        let protectiveWord = AuthManager().protectiveWord
        self.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: true, isManualFetch: true, protectiveWord: protectiveWord, sourceVC: .AfterOnboarding)
        
    }
    
    private func showError(error: String, title: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.alert(title: title, message: error)
        }
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
        // First we are checking if the health records screen state needs to be updated when a user taps on records tab - this is to handle the case where a user adds a vaccine pass via health pass flow, and we need to reflect the state change in the records tab. This boolean property is being set in a listener above
        if self.selectedIndex == TabBarVCs.records.rawValue && updateRecordsScreenState {
            updateRecordsScreenState = false
            self.resetHealthRecordsTab()
        } else if self.selectedIndex == TabBarVCs.records.rawValue && self.previousSelectedIndex == TabBarVCs.records.rawValue {
            // This is called here to rest the records tab appropriately, when the tab is tapped
            self.resetHealthRecordsTab()
        }
    }
}

// MARK: Auth Fetch delegates
extension TabBarController: AuthenticatedHealthRecordsAPIWorkerDelegate {
    func showPatientDetailsError(error: String, showBanner: Bool) {
        guard showBanner else { return }
        self.showBanner(message: error, style: .Bottom)
    }
    
    func showFetchStartedBanner(showBanner: Bool) {
        guard showBanner else { return }
        self.showBanner(message: "Retrieving records", style: .Bottom)
    }
    
    func showFetchCompletedBanner(recordsSuccessful: Int, recordsAttempted: Int, errors: [AuthenticationFetchType : String]?, showBanner: Bool) {
        guard showBanner else { return }
        // TODO: Connor - handle error case
        self.resetHealthRecordsTab()
//        let message = (recordsSuccessful > 0 || errors?.count == 0) ? "Records retrieved" : "No records fetched"
        self.showBanner(message: "Records retrieved", style: .Bottom)
        NotificationCenter.default.post(name: .authFetchComplete, object: nil, userInfo: nil)
        var loginProcessStatus = Defaults.loginProcessStatus ?? LoginProcessStatus(hasStartedLoginProcess: true, hasCompletedLoginProcess: true, hasFinishedFetchingRecords: false, loggedInUserAuthManagerDisplayName: AuthManager().displayName)
        loginProcessStatus.hasFinishedFetchingRecords = true
        Defaults.loginProcessStatus = loginProcessStatus
    }
    func showAlertForLoginAttemptDueToValidation(error: ResultError?) {
        print(error)
        self.alert(title: "Login Error", message: "We're sorry, there was an error logging in. Please try again later.")
    }
    
    func showAlertForUserUnder(ageInYears age: Int) {
        self.alert(title: "Age Restriction", message: "You must be \(age) year's of age or older to user Health Gateway.")
    }
    
    func showAlertForUserProfile(error: ResultError?) {
        self.alert(title: "Error", message: error?.resultMessage ?? "Unexpected error")
    }
}

// MARK: To go to specific user records tab
extension TabBarController {
    func goToUserRecordsScreenForPatient(_ patient: Patient) {
        resetHealthRecordsTab(goToRecordsForPatient: patient)
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
