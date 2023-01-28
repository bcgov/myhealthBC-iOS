//
//  profileAndSettingsViewController.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-11.
//

import UIKit

class ProfileAndSettingsViewController: BaseViewController {
    
    enum TableRow: Int, CaseIterable {
        case profile
        case securityAndData
        case privacyStatement
        case logout
    }
    
    class func constructProfileAndSettingsViewController() -> ProfileAndSettingsViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: ProfileAndSettingsViewController.self)) as? ProfileAndSettingsViewController {
            return vc
        }
        return ProfileAndSettingsViewController()
    }
    
    // MARK: Variables
    let authManager: AuthManager = AuthManager()
    private var throttleAPIWorker: LoginThrottleAPIWorker?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    private var displayName: String?
    
    override var getPassesFlowType: PassesFlowVCs? {
        return .ProfileAndSettingsViewController
    }
    
    override var getRecordFlowType: RecordsFlowVCs? {
        return .ProfileAndSettingsViewController
    }
    
    // MARK: Class funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        navSetup()
        setupListener()
        self.throttleAPIWorker = LoginThrottleAPIWorker(delegateOwner: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.throttleAPIWorker = nil
    }
    
    // MARK: Routing
    func showProfile() {
        alert(title: "Not implemented", message: "Can't view profile yet")
    }
    
    func showLogin() {
        // Note: This nav bar hack is to prevent the user from navigating back to the root vc, which was causing issues as the routing functionality wasn't working in time, so the records weren't showing
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        showLogin(initialView: .Landing, sourceVC: .ProfileAndSettingsVC, completion: { authenticationStatus in
            guard authenticationStatus != .Cancelled || authenticationStatus != .Failed else {
                self.navigationController?.navigationBar.isUserInteractionEnabled = false
                return
            }
            let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack)
            let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack)
            let currentTab = self.getCurrentTab
            let scenario = AppUserActionScenarios.LoginSpecialRouting(values: ActionScenarioValues(currentTab: currentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails, loginSourceVC: .ProfileAndSettingsVC, authenticationStatus: authenticationStatus))
            self.routerWorker?.routingAction(scenario: scenario, delayInSeconds: 0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
            }
        })
    }
    
    func showSecurityAndData() {
        let vc = SecurityAndDataViewController.constructSecurityAndDataViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showPrivacyStatement() {
        openPrivacyPolicy()
    }
}

extension ProfileAndSettingsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .profileAndSettings,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}

extension ProfileAndSettingsViewController {
    private func setupListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(settingsTableViewReload), name: .settingsTableViewReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(patientAPIFetched), name: .patientAPIFetched, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authStatusChanged), name: .authStatusChanged, object: nil)
        NotificationManager.listenToLoginDataClearedOnLoginRejection(observer: self, selector: #selector(reloadFromForcedLogout))
    }
    
    @objc private func settingsTableViewReload() {
        self.tableView.reloadData()
    }
    
    @objc private func patientAPIFetched(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String?] else { return }
        guard let fullName = userInfo["fullName"] else { return }
        self.displayName = fullName
        self.tableView.reloadData()
    }
    
    @objc private func authStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Bool] else { return }
        guard let authenticated = userInfo[Constants.AuthStatusKey.key] else { return }
        if !authenticated {
            self.displayName = nil
        }
        self.tableView.reloadData()
    }
    
    @objc private func reloadFromForcedLogout(_ notification: Notification) {
        self.tableView.reloadData()
    }
}

extension ProfileAndSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.register(UINib.init(nibName: SettingsRowTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SettingsRowTableViewCell.getName)
        tableView.register(UINib.init(nibName: SettingsProfileTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SettingsProfileTableViewCell.getName)
        tableView.register(UINib.init(nibName: SettingsAuthenticateTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SettingsAuthenticateTableViewCell.getName)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = TableRow.allCases.count
        return authManager.isAuthenticated ? count : count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = TableRow.init(rawValue: indexPath.row) else {return UITableViewCell()}
        switch row {
        case .profile:
            if authManager.isAuthenticated {
                return profileCell(for: indexPath) {[weak self] in
                    guard let `self` = self else {return}
                    // Not using this right now
                    self.showProfile()
                }
            } else {
                return loginCell(for: indexPath) {[weak self] in
                    guard let `self` = self else {return}
                    self.showLogin()
                }
            }
        case .securityAndData:
            let title: String = .securityAndData
            let icon = UIImage(named: "security-icon")
            return rowCell(for: indexPath, title: title, icon: icon) {[weak self] in
                guard let `self` = self else {return}
                self.showSecurityAndData()
            }
        case .privacyStatement:
            let title: String = .privacyStatement
            let icon = UIImage(named: "privacy-icon")
            return rowCell(for: indexPath, title: title, icon: icon) {[weak self] in
                guard let `self` = self else {return}
                self.showPrivacyStatement()
            }
        case .logout:
            let title: String = .logOut
            let icon = UIImage(named: "logout-icon")
            return rowCell(for: indexPath, title: title, icon: icon, labelColor: .Red) {[weak self] in
                guard let `self` = self else {return}
                self.logout()
            }
        }
        
    }
    
    func loginCell(for indexPath: IndexPath, onTap: @escaping() -> Void) -> SettingsAuthenticateTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsAuthenticateTableViewCell.getName, for: indexPath) as? SettingsAuthenticateTableViewCell else {
            return SettingsAuthenticateTableViewCell()
        }
        cell.setup(onTap: onTap)
        return cell
    }
    
    func profileCell(for indexPath: IndexPath, onTap: @escaping() -> Void) -> SettingsProfileTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsProfileTableViewCell.getName, for: indexPath) as? SettingsProfileTableViewCell else {
            return SettingsProfileTableViewCell()
        }
        cell.setup(displayName: self.displayName, onTap: onTap)
        return cell
    }
    
    func rowCell(for indexPath: IndexPath, title: String, icon: UIImage?, labelColor: LabelColour = .Black, onTap: @escaping() -> Void) -> SettingsRowTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsRowTableViewCell.getName, for: indexPath) as? SettingsRowTableViewCell else {
            return SettingsRowTableViewCell()
        }
        cell.setup(title: title, icon: icon, labelColor: labelColor, onTap: onTap)
        return cell
    }
    
    // MARK: Logout
    private func logout() {
        self.alertConfirmation(title: .logoutTitle, message: .logoutDescription, confirmTitle: .logOut, confirmStyle: .destructive) {[weak self] in
            guard let `self` = self else {return}
            self.deleteRecordsForAuthenticatedUserAndLogout()
        } onCancel: {[weak self] in
            guard let `self` = self else {return}
            self.tableView.reloadData()
        }
    }
    
    // MARK: Helpers
    private func deleteRecordsForAuthenticatedUserAndLogout() {
        LocalAuthManager.block = true
        performLogout(completion: {success in
            guard success else { return }
//            NotificationCenter.default.post(name: .resetHealthRecordsScreenOnLogout, object: nil, userInfo: nil)
            DispatchQueue.main.async {
                let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack)
                let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack)
                let values = ActionScenarioValues(currentTab: self.getCurrentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
                self.routerWorker?.routingAction(scenario: .Logout(values: values))
                
            }
        })
    }
    
    private func performLogout(completion: @escaping(_ success: Bool)-> Void) {
        self.throttleAPIWorker?.throttleHGMobileConfigEndpoint(completion: { response in
            if response != .NoInternet {
                self.authManager.signout(in: self, completion: { [weak self] success in
                    guard let `self` = self else {return}
                    // Regardless of the result of the async logout, clear tokens.
                    // because user may be offline
                    self.tableView.reloadData()
                    completion(success)
                })
            }
        })
    }
}
