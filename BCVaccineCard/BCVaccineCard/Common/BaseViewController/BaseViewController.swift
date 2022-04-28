//
//  BaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//


import UIKit

enum NavTitleSmallAlignment {
    case Center
    case Left
}

protocol NavigationSetupProtocol: AnyObject {
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, navTitleSmallAlignment: NavTitleSmallAlignment, targetVC vc: UIViewController, backButtonHintString: String?, largeTitlesFontSize: CGFloat)
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, navTitleSmallAlignment: NavTitleSmallAlignment, targetVC vc: UIViewController, backButtonHintString: String?)
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButtons right: [NavButton], navStyle: NavStyle, navTitleSmallAlignment: NavTitleSmallAlignment, targetVC vc: UIViewController, backButtonHintString: String?)
    func adjustNavStyleForPDF(targetVC vc: UIViewController)
}

class BaseViewController: UIViewController, NavigationSetupProtocol, Theme {
   
    weak var navDelegate: NavigationSetupProtocol?
    
    var routerWorker: RouterWorker? {
        return (self.tabBarController as? TabBarController)?.routerWorker
    }
    
    var getCurrentStacks: CurrentRecordsAndPassesStacks {
        return (self.tabBarController as? TabBarController)?.getCurrentRecordsAndPassesFlows() ?? CurrentRecordsAndPassesStacks(recordsStack: [], passesStack: [])
    }
    
    var getCurrentTab: TabBarVCs {
        return TabBarVCs.init(rawValue: (self.tabBarController as? TabBarController)?.selectedIndex ?? 0) ?? .home
    }
    
    var getRecordFlowType: RecordsFlowVCs? {
        return nil
    }
    var getPassesFlowType: PassesFlowVCs? {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetup()
        performLocalAuthIfNeeded()
        listenToLocalAuthNotification()
    }
    
    func listenToLocalAuthNotification() {
        Notification.Name.shouldPerformLocalAuth.onPost(object: nil, queue: .main) {[weak self] _ in
            guard let `self` = self, UIApplication.topViewController() == self else {return}
            self.performLocalAuthIfNeeded()
        }
    }
    
    func performLocalAuthIfNeeded() {
        if LocalAuthManager.shouldAuthenticate {
            showLocalAuth(onSuccess: { [weak self] in
                guard let `self` = self else {return}
                self.localAuthPerformed()
            })
        }
    }
    
    /// Override this function to perform changes after local authentication
    func localAuthPerformed() {}
    
}

// MARK: Navigation setup
extension BaseViewController {
    private func navigationSetup() {
        self.navDelegate = self
    }
    
    private func setNavHeaderLocation(navStyle: NavStyle, navTitleSmallAlignment: NavTitleSmallAlignment, vc: UIViewController, title: String) {
        if navStyle == .small && navTitleSmallAlignment == .Left {
            navigationItem.title = nil
            let label = UILabel()
            label.textColor = AppColours.appBlue
            label.font = UIFont.bcSansBoldWithSize(size: 17)
            label.text = title
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
            vc.navigationItem.leftItemsSupplementBackButton = true
        } else {
            navigationItem.title = title
        }
    }
    
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, navTitleSmallAlignment: NavTitleSmallAlignment, targetVC vc: UIViewController, backButtonHintString: String?, largeTitlesFontSize: CGFloat) {
        var rightButtons: [NavButton] = []
        if let rightButton = right {
            rightButtons.append(rightButton)
        }
        setNavHeaderLocation(navStyle: navStyle, navTitleSmallAlignment: navTitleSmallAlignment, vc: vc, title: title)
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
       
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        nav.setupNavigation(leftNavButton: left, rightNavButtons: rightButtons, navStyle: navStyle, targetVC: vc, backButtonHintString: backButtonHintString, largeTitleFontSize: largeTitlesFontSize)
    }
    
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, navTitleSmallAlignment: NavTitleSmallAlignment, targetVC vc: UIViewController, backButtonHintString: String?) {
        var rightButtons: [NavButton] = []
        if let rightButton = right {
            rightButtons.append(rightButton)
        }
        setNavigationBarWith(title: title, leftNavButton: left, rightNavButtons: rightButtons, navStyle: navStyle, navTitleSmallAlignment: navTitleSmallAlignment, targetVC: vc, backButtonHintString: backButtonHintString)
    }
    
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButtons right: [NavButton], navStyle: NavStyle, navTitleSmallAlignment: NavTitleSmallAlignment, targetVC vc: UIViewController, backButtonHintString: String?) {
        setNavHeaderLocation(navStyle: navStyle, navTitleSmallAlignment: navTitleSmallAlignment, vc: vc, title: title)
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
       
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        nav.setupNavigation(leftNavButton: left, rightNavButtons: right, navStyle: navStyle, targetVC: vc, backButtonHintString: backButtonHintString)
    }
    
    func adjustNavStyleForPDF(targetVC vc: UIViewController) {
        guard let nav = self.navigationController as? CustomNavigationController else { return }
        nav.adjustNavStyleForPDF(targetVC: vc)
    }
}

// MARK: For Settings Navigation
extension BaseViewController {
    @objc func settingsButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        goToSettingsScreen()
    }
    
    private func goToSettingsScreen() {
        let vc = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: For Authenticated Fetch
extension BaseViewController {
    func performAuthenticatedRecordsFetch(isManualFetch: Bool, showBanner: Bool = true, specificFetchTypes: [AuthenticationFetchType]? = nil, protectiveWord: String? = nil, sourceVC: LoginVCSource, initialProtectedMedFetch: Bool = false) {
        guard let authToken = AuthManager().authToken, let hdid = AuthManager().hdid, let tabVC = self.tabBarController as? TabBarController else {
            // TODO: Error handling here
            return
        }
        let authCreds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
        tabVC.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: showBanner, isManualFetch: isManualFetch, specificFetchTypes: specificFetchTypes, protectiveWord: protectiveWord, sourceVC: sourceVC, initialProtectedMedFetch: initialProtectedMedFetch)
    }
}

// MARK: This is used to let the settings screen know that it should reload table view (viewDidAppear not called when auth is complete from settings screen)
extension BaseViewController {
    func postAuthChangedSettingsReloadRequired() {
        NotificationCenter.default.post(name: .settingsTableViewReload, object: nil, userInfo: nil)
    }
}

// MARK: GoTo Health Gateway Logic from passes flow
extension BaseViewController {
    //FIXME: CONNOR: - Ready To Test: Move this function to base view controller and then user router worker within this function
        func goToHealthGateway(fetchType: GatewayFormViewControllerFetchType, source: GatewayFormSource, owner: UIViewController, navDelegate: NavigationSetupProtocol?) {
            var rememberDetails = RememberedGatewayDetails(storageArray: nil)
            if let details = Defaults.rememberGatewayDetails {
                rememberDetails = details
            }
            
            let vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: fetchType)
            if fetchType.isFedPassOnly {
                vc.completionHandler = { [weak self] details in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                        if let fedPass = details.fedPassId {
                            // Added record set to nil means that the records tab will either show UserRecordsVC or HealthRecordsVC, depending on number of users - if we want to display the detail screen, then we need to provide the addedRecord - this function is only being called from HealthPassVC and CovidVaccineCardsVC as of now though
                            let fedPassAddedFromHealthPassVC = source == .healthPassHomeScreen ? true : false
                            DispatchQueue.main.async {
//                                self.routerWorker?.routingAction(scenario: .ManualFetch(actioningPatient: details.patient, addedRecord: nil, recentlyAddedCardId: details.id, fedPassStringToOpen: fedPass, fedPassAddedFromHealthPassVC: fedPassAddedFromHealthPassVC))
//                                
                                let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack, actioningPatient: details.patient, addedRecord: nil)
                                let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack, recentlyAddedCardId: details.id, fedPassStringToOpen: fedPass, fedPassAddedFromHealthPassVC: fedPassAddedFromHealthPassVC)
                                let values = ActionScenarioValues(currentTab: self.getCurrentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
                                self.routerWorker?.routingAction(scenario: .ManualFetch(values: values))
                            }
//                            if source == .healthPassHomeScreen {
//                                self.popBack(toControllerType: HealthPassViewController.self)
//                                self.postOpenPDFFromAddingFedPassOnlyNotification(pass: fedPass, source: .healthPassHomeScreen)
//                            } else if source == .vaccineCardsScreen {
//                                self.popBack(toControllerType: CovidVaccineCardsViewController.self)
//                                self.postOpenPDFFromAddingFedPassOnlyNotification(pass: fedPass, source: .vaccineCardsScreen)
//                            }
//                            completion?(details.id)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
}
