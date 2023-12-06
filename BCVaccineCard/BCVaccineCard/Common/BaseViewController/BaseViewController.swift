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
    var tabDelegate: TabDelegate?
    
//    var routerWorker: RouterWorker? {
//        return (self.tabBarController as? TabBarController)?.routerWorker
//    }
//
//    var getCurrentStacks: CurrentRecordsAndPassesStacks {
//        return (self.tabBarController as? TabBarController)?.getCurrentRecordsAndPassesFlows() ?? CurrentRecordsAndPassesStacks(recordsStack: [], passesStack: [])
//    }
    
//    var getCurrentTab: AppTabs {
//        return TabBarVCs.init(rawValue: (self.tabBarController as? AppTabBarController)?.selectedIndex ?? 0) ?? .home
//    }
    
//    var getRecordFlowType: RecordsFlowVCs? {
//        return nil
//    }
//    var getPassesFlowType: PassesFlowVCs? {
//        return nil
//    }
    
    var getReusableSplitViewController: ReusableSplitViewController? {
        if let nav = self.navigationController as? CustomNavigationController {
            if let split = nav.parent as? ReusableSplitViewController {
                return split
            }
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetup()
        performLocalAuthIfNeeded()
        listenToLocalAuthNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showOrHideTabBar()
    }
    
    func showOrHideTabBar() {
        var hideTab = true
        for vcType in Constants.UI.TabBar.viewControllersWithTabBar {
            if self.isKind(of: vcType) {
                hideTab = false
            }
        }
     
        if hideTab {
            self.parent?.tabBarController?.tabBar.isHidden = true
        } else {
            self.parent?.tabBarController?.tabBar.isHidden = Constants.deviceType == .iPad
        }
    }
    
    func listenToLocalAuthNotification() {
        Notification.Name.shouldPerformLocalAuth.onPost(object: nil, queue: .main) {[weak self] _ in
            guard let `self` = self, UIApplication.topViewController() == self else {return}
//            guard Constants.deviceType != .iPad else { return }
            self.performLocalAuthIfNeeded()
        }
    }
    
    func performLocalAuthIfNeeded() {
//        guard Constants.deviceType != .iPad else { return }
        if LocalAuthManager.shouldAuthenticate {
            // Dont show local auth if onboading should be shown
            let unseen = Defaults.unseenOnBoardingScreens()
            guard unseen.isEmpty else {return}
            
            showLocalAuth(onSuccess: { [weak self] in
                guard let `self` = self else {return}
                self.localAuthPerformed()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if !Defaults.hasSeenFirstLogin {
                        Defaults.hasSeenFirstLogin = true
                        self.showLogin(initialView: .Landing, showTabOnSuccess: .Home)
                    }
                }
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
        if UIDevice.current.orientation.isLandscape {
            let vcTest = ProfileAndSettingsViewController()
            if let split = self.getReusableSplitViewController, !split.isVCAlreadyShown(viewController: vcTest) {
                let vc = ProfileAndSettingsViewController.construct()
                split.adjustFarRightVC(viewController: vc)
            }
        } else {
            show(route: .Settings, withNavigation: true)
        }
        
    }
}

// MARK: This is used to let the settings screen know that it should reload table view (viewDidAppear not called when auth is complete from settings screen)
extension BaseViewController {
    func postAuthChangedSettingsReloadRequired() {
        NotificationCenter.default.post(name: .settingsTableViewReload, object: nil, userInfo: nil)
    }
}

// MARK: This is to detect when a view controller rotates
extension BaseViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard Constants.deviceType == .iPad else { return }
        NotificationCenter.default.post(name: .deviceDidRotate, object: nil)
    }
}
