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
        case privacy
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
    
    
    class func constructSettingsViewController() -> SecurityAndDataViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: SecurityAndDataViewController.self)) as? SecurityAndDataViewController {
            return vc
        }
        return SecurityAndDataViewController()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
}

// MARK: Navigation setup
extension SecurityAndDataViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .settings,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: .healthPasses)
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
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableSection(rawValue: indexPath.section),
              section.rows.count > indexPath.row else {
                  return UITableViewCell()
              }
        let row = section.rows[indexPath.row]
        
        switch row {
        case .privacy:
            let cell = textCell(for: indexPath, title: .privacyStatement, textColor: AppColours.appBlue) { [weak self] in
                guard let `self` = self else {return}
                self.openPrivacyPolicy()
            }
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = AccessibilityLabels.Settings.privacyStatementLink
            cell.accessibilityHint = AccessibilityLabels.Settings.privacyStatementHint
            return cell
        case .analytics:
            let isOn = AnalyticsService.shared.isEnabled
            let cell = toggleCell(for: indexPath, onTitle: .disableAnalytics, offTitle: .enableAnalytics, subTitle: .analytyticsUsageDescription, isOn: isOn) { isOn in
                if isOn {
                    AnalyticsService.shared.enable()
                } else {
                    AnalyticsService.shared.disable()
                }
            }
            
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = AccessibilityLabels.Settings.privacyStatementLink
            cell.accessibilityHint = AccessibilityLabels.Settings.privacyStatementHint
            return cell
            
        case .deleteAllRecords:
            let cell = textCell(for: indexPath, title: .deleteAllRecordsAndSavedData, textColor: AppColours.appRed) {[weak self] in
                guard let `self` = self else {return}
                self.alertConfirmation(title: .deleteData, message: .confirmDeleteAllRecordsAndSaveData, confirmTitle: .delete, confirmStyle: .destructive) {
                    StorageService.shared.deleteAllStoredData()
                } onCancel: {}
            }
            return cell
        case .auth:
            
            let cell = toggleCell(for: indexPath, onTitle: "Log in with BC Services Card", offTitle: "Log in with BC Services Card", subTitle: "When logged in, recrods will be automatically added and updated", isOn: AuthManager().isAuthenticated, onToggle: {[weak self] enable in
                guard let `self` = self else {return}
                switch enable {
                case true:
                    AuthenticationViewController.displayFullScreen()
                case false:
                    self.alertConfirmation(title: "sign out?", message: "out out?", confirmTitle: .delete, confirmStyle: .destructive) {
                        AuthManager().signout(in: self, completion: { _ in
                            tableView.reloadData()
                        })
                        
                    } onCancel: {}
                }
            })
            return cell
        case .localAuth:
            let cell = toggleCell(for: indexPath, onTitle: "Touch ID", offTitle: "Touch ID", subTitle: "When enabled, you can unlock the app with touch touch ID instead of passcode", isOn: false, onToggle: {[weak self] enable in
                guard let `self` = self else {return}
                // TODO: LOCAL AUTH
            })
            return cell
        }
    }
    
    func textCell(for indexPath: IndexPath, title: String, font: UIFont? = .bcSansRegularWithSize(size: 16), textColor: UIColor, onTap: @escaping() -> Void) -> SettingsTextTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTextTableViewCell.getName, for: indexPath) as? SettingsTextTableViewCell else {
            return SettingsTextTableViewCell()
        }
        cell.configure(text: title, font: font ?? UIFont.bcSansRegularWithSize(size: 16), colour: textColor, onTap: onTap)
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
