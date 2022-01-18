//
//  SettingsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
// 

import UIKit

class SettingsViewController: BaseViewController {
    
    enum SettingType: Int, CaseIterable {
        case analytics = 0
        case privacy
        case deleteAllRecords
    }
    
    class func constructSettingsViewController() -> SettingsViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
            return vc
        }
        return SettingsViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
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
extension SettingsViewController {
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
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
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
        return SettingType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = SettingType.init(rawValue: indexPath.row) else {return UITableViewCell()}
        switch type {
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
                    Defaults.rememberGatewayDetails = nil
                } onCancel: {}
            }
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


