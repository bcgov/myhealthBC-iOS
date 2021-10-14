//
//  SettingsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
// 

import UIKit

class SettingsViewController: BaseViewController {
    
    class func constructSettingsViewController() -> SettingsViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
            return vc
        }
        return SettingsViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: [Setting] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navSetup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        setupDataSource()
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
                                               targetVC: self)
    }
}

// MARK: Data Source Setup
extension SettingsViewController {
    private func setupDataSource() {
        self.dataSource = [
//            Setting(cell: .text(text: .settingsOpeningText), isClickable: false),
            Setting(cell: .setting(text: .privacyStatement, image: #imageLiteral(resourceName: "lock-icon")), isClickable: true)
            // TODO: Unhide this cell once we have some details surrounding the help option
//            Setting(cell: .setting(text: Constants.Strings.Settings.help, image: #imageLiteral(resourceName: "question-icon")), isClickable: true)
        ]
    }
}

// MARK: TableView setup
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: SettingsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SettingsTableViewCell.getName)
        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = dataSource[indexPath.row].cell
        switch cellType {
        case .text(text: let text):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell {
                cell.configure(forType: .plainText, text: text, withFont: UIFont.bcSansRegularWithSize(size: 14), labelSpacingAdjustment: 36)
                return cell
            }
        case .setting(text: let text, image: let image):
            if let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.getName, for: indexPath) as? SettingsTableViewCell {
                cell.configure(text: text, image: image)
                cell.isAccessibilityElement = true
                cell.accessibilityLabel = "Privacy Statement Link"
                cell.accessibilityHint = "Action Available: Tapping the privacy statement link will take you to the privacy statement web page"
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = dataSource[indexPath.row]
        guard type.isClickable else { return }
        // FIXME: Once other features are added, will need a way to distinguish which cell is tapped and where it's going.
        self.openPrivacyPolicy()
    }
    
}


