//
//  profileAndSettingsViewController.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-01-11.
//

import UIKit

class profileAndSettingsViewController: BaseViewController {
    
    enum TableRow: Int, CaseIterable {
        case profile
        case securityAndData
        case privacyStatement
    }
    
    class func constructProfileAndSettingsViewController() -> profileAndSettingsViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: profileAndSettingsViewController.self)) as? profileAndSettingsViewController {
            return vc
        }
        return profileAndSettingsViewController()
    }
    
    // MARK: Variables
    let authManager: AuthManager = AuthManager()
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: Class funcs
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTableView()
        navSetup()
    }
    
    // MARK: Routing
    func showProfile() {
        alert(title: "Not implemented", message: "Can't view profile yet")
    }
    
    func showLogin() {
        showLogin(completion: {success in})
    }
    
    func showSecurityAndData() {
        let vc = SecurityAndDataViewController.constructSecurityAndDataViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showPrivacyStatement() {
        openPrivacyPolicy()
    }
}

extension profileAndSettingsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .profileAndSettings,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}

extension profileAndSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
                tableView.register(UINib.init(nibName: SettingsRowTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SettingsRowTableViewCell.getName)
                tableView.register(UINib.init(nibName: SettingsProfileTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SettingsProfileTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableRow.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = TableRow.init(rawValue: indexPath.row) else {return UITableViewCell()}
        switch row {
        case .profile:
            if authManager.isAuthenticated {
                return profileCell(for: indexPath) {[weak self] in
                    guard let `self` = self else {return}
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
            let icon = UIImage(named: "privacy-icon")
            return rowCell(for: indexPath, title: title, icon: icon) {[weak self] in
                guard let `self` = self else {return}
                self.showSecurityAndData()
            }
        case .privacyStatement:
            let title: String = .privacyStatement
            let icon = UIImage(named: "security-icon")
            return rowCell(for: indexPath, title: title, icon: icon) {[weak self] in
                guard let `self` = self else {return}
                self.showPrivacyStatement()
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
        cell.setup(onTap: onTap)
        return cell
    }
    
    func rowCell(for indexPath: IndexPath, title: String, icon: UIImage?, onTap: @escaping() -> Void) -> SettingsRowTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsRowTableViewCell.getName, for: indexPath) as? SettingsRowTableViewCell else {
            return SettingsRowTableViewCell()
        }
        cell.setup(title: title, icon: icon, onTap: onTap)
        return cell
    }
    
    
}
