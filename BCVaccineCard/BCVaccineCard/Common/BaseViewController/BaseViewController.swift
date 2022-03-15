//
//  BaseViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

protocol NavigationSetupProtocol: AnyObject {
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, targetVC vc: UIViewController, backButtonHintString: String?)
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButtons right: [NavButton], navStyle: NavStyle, targetVC vc: UIViewController, backButtonHintString: String?)
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
            showLocalAuth()
        }
    }
    
}

// MARK: Navigation setup
extension BaseViewController {
    private func navigationSetup() {
        self.navDelegate = self
    }
    
    
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButton right: NavButton?, navStyle: NavStyle, targetVC vc: UIViewController, backButtonHintString: String?) {
        var rightButtons: [NavButton] = []
        if let rightButton = right {
            rightButtons.append(rightButton)
        }
        setNavigationBarWith(title: title, leftNavButton: left, rightNavButtons: rightButtons, navStyle: navStyle, targetVC: vc, backButtonHintString: backButtonHintString)
    }
    
    func setNavigationBarWith(title: String, leftNavButton left: NavButton?, rightNavButtons right: [NavButton], navStyle: NavStyle, targetVC vc: UIViewController, backButtonHintString: String?) {
        navigationItem.title = title
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
    func performAuthenticatedBackgroundFetch() {
        guard let authToken = AuthManager().authToken, let hdid = AuthManager().hdid, let tabVC = self.tabBarController as? TabBarController else {
            // TODO: Error handling here
            return
        }
        let authCreds = AuthenticationRequestObject(authToken: authToken, hdid: hdid)
        tabVC.authWorker?.getAuthenticatedPatientDetails(authCredentials: authCreds, showBanner: true)
    }
}

// MARK: This is used to let the settings screen know that it should reload table view (viewDidAppear not called when auth is complete from settings screen)
extension BaseViewController {
    func postAuthChangedSettingsReloadRequired() {
        NotificationCenter.default.post(name: .settingsTableViewReload, object: nil, userInfo: nil)
    }
}
