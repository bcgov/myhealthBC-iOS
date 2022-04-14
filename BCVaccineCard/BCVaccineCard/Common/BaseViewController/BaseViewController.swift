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
    func performAuthenticatedRecordsFetch(isManualFetch: Bool, showBanner: Bool = true, specificFetchTypes: [AuthenticationFetchType]? = nil, protectiveWord: String? = nil, sourceVC: LoginVCSource) {
        guard let authToken = AuthManager().authToken, let hdid = AuthManager().hdid, let tabVC = self.tabBarController as? TabBarController else {
            // TODO: Error handling here
            return
        }
        let authCreds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
        tabVC.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: showBanner, isManualFetch: isManualFetch, specificFetchTypes: specificFetchTypes, protectiveWord: protectiveWord, sourceVC: sourceVC)
    }
}

// MARK: This is used to let the settings screen know that it should reload table view (viewDidAppear not called when auth is complete from settings screen)
extension BaseViewController {
    func postAuthChangedSettingsReloadRequired() {
        NotificationCenter.default.post(name: .settingsTableViewReload, object: nil, userInfo: nil)
    }
}
