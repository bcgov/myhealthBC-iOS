//
//  SecurityAndDataViewController.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-11.
//

import UIKit

class SecurityAndDataViewController: BaseViewController {
    
    enum TableRow {
        case analytics
        case deleteAllRecords
        case auth
        case localAuth
    }
    
    fileprivate enum TableSection: Int, CaseIterable {
        case Login = 0
        case Data
        
        var rows: [TableRow] {
            switch self {
            case .Login:
                return [.auth, .localAuth]
            case .Data:
                return [.analytics, .deleteAllRecords]
            }
        }
    }
    
    class func constructSecurityAndDataViewController() -> SecurityAndDataViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: SecurityAndDataViewController.self)) as? SecurityAndDataViewController {
            return vc
        }
        return SecurityAndDataViewController()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let authManager = AuthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navSetup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        setupTableView()
    }
    
    // MARK: Login
    func logout() {
        self.alertConfirmation(title: .logoutTitle, message: .logoutDescription, confirmTitle: .logOut, confirmStyle: .destructive) {[weak self] in
            guard let `self` = self else {return}
            self.deleteRecordsForAuthenticatedUserAndLogout()
        } onCancel: {[weak self] in
            guard let `self` = self else {return}
            self.tableView.reloadData()
        }
    }
    
    func login() {
        AuthenticationViewController.displayFullScreen()
    }
    
    // MARK: Local Auth
    func enableLocalAuth() {
        
    }
    
    func disableLocalAuth() {
        
    }
    
    // MARK: Data
    func deleteAllData() {
        self.alertConfirmation(title: .deleteData, message: .confirmDeleteAllRecordsAndSaveData, confirmTitle: .delete, confirmStyle: .destructive) {[weak self] in
            guard let `self` = self else {return}
            self.deleteRecordsForAuthenticatedUserAndLogout()
        } onCancel: {}
    }
    
    // MARK: Analytics
    func enableAnalytics() {
        AnalyticsService.shared.enable()
    }
    
    func disableAnalytics() {
        AnalyticsService.shared.disable()
    }
    
    // MARK: Helpers
    private func deleteRecordsForAuthenticatedUserAndLogout() {
        StorageService.shared.deleteHealthRecordsForAuthenticatedUser()
        self.performLogout()
    }
    
    private func performLogout() {
        authManager.signout(in: self, completion: { [weak self] success in
            guard let `self` = self else {return}
            // Regardless of the result of the async logout, clear tokens.
            // because user may be offline
            self.authManager.clearData()
            self.tableView.reloadData()
        })
    }
    
}

// MARK: Navigation setup
extension SecurityAndDataViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .securityAndData,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: .profileAndSettings)
    }
}

// MARK: TableView setup
extension SecurityAndDataViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: SettingsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SettingsTableViewCell.getName)
        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
        tableView.register(UINib.init(nibName: ToggleSettingsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ToggleSettingsTableViewCell.getName)
        tableView.register(SettingsTextTableViewCell.self, forCellReuseIdentifier: SettingsTextTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = TableSection.init(rawValue: section) else {
            return nil
        }
        
        let titleString: String
        switch section {
        case .Login:
            titleString = "Login"
        case .Data:
            titleString = "Data"
        }
        let headerView: SettingsSectionHeaderView = SettingsSectionHeaderView.fromNib()
        headerView.frame = .zero
        headerView.setup(title: titleString)
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TableSection.init(rawValue: section) else {return 0}
        return section.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableSection(rawValue: indexPath.section),
              section.rows.count > indexPath.row else {
                  return UITableViewCell()
              }
        let row = section.rows[indexPath.row]
        
        switch row {
        case .analytics:
            let isOn = AnalyticsService.shared.isEnabled
            let cell = toggleCell(for: indexPath, onTitle: .disableAnalytics, offTitle: .enableAnalytics, subTitle: .analytyticsUsageDescription, isOn: isOn) {[weak self] isOn in
                guard let `self` = self else {return}
                if isOn {
                    self.enableAnalytics()
                } else {
                    self.disableAnalytics()
                }
            }
            
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = AccessibilityLabels.Settings.privacyStatementLink
            cell.accessibilityHint = AccessibilityLabels.Settings.privacyStatementHint
            return cell
            
        case .deleteAllRecords:
            let cell = textCell(for: indexPath,
                                   title: .deleteAllRecordsAndSavedData,
                                   titleColour: .Red,
                                   subTitle: .deleteAllRecordsAndSavedDataDescription
            ) {[weak self] in
                guard let `self` = self else {return}
                self.deleteAllData()
            }
            return cell
        case .auth:
            let cell = toggleCell(for: indexPath,
                                     onTitle: .bcscLogin,
                                     offTitle: .bcscLogin,
                                     subTitle: .loginDescription,
                                     isOn: authManager.isAuthenticated,
                                     onToggle: {
                [weak self] enable in
                guard let `self` = self else {return}
                switch enable {
                case true:
                    self.login()
                case false:
                    self.logout()
                }
            })
            return cell
            
        case .localAuth:
            let cell = toggleCell(for: indexPath, onTitle: .touchId, offTitle: .touchId, subTitle: .localAuthDescription, isOn: false, onToggle: {[weak self] enable in
                guard let `self` = self else {return}
                // TODO: LOCAL AUTH
                switch enable {
                case true:
                    self.enableLocalAuth()
                case false:
                    self.disableLocalAuth()
                }
            })
            return cell
        }
    }
    
    func textCell(for indexPath: IndexPath, title: String, titleColour: LabelColour, subTitle: String, onTap: @escaping() -> Void) -> SettingsTextTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTextTableViewCell.getName, for: indexPath) as? SettingsTextTableViewCell else {
            return SettingsTextTableViewCell()
        }
        cell.configure(title: title, titleColour: titleColour, subTitle: subTitle, onTap: onTap)
        return cell
    }
    
    func toggleCell(for indexPath: IndexPath, onTitle: String, offTitle: String, subTitle: String, isOn: Bool, onToggle: @escaping(_ result: Bool) -> Void) -> ToggleSettingsTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToggleSettingsTableViewCell.getName, for: indexPath) as? ToggleSettingsTableViewCell else {
            return ToggleSettingsTableViewCell()
        }
        cell.configure(onTitle: onTitle, offTitle: offTitle, subTitle: subTitle, isOn: isOn, onToggle: onToggle)
        return cell
    }
    
}
