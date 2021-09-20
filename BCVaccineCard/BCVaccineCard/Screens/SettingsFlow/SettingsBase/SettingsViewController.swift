//
//  SettingsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-16.
// 

import UIKit

class SettingsViewController: BaseViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: [Setting] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navSetup()
        setupDataSource()
        setupTableView()
    }

}

// MARK: Navigation setup
extension SettingsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: Constants.Strings.Settings.navHeader, andImage: nil, action: nil)
    }
}

// MARK: Data Source Setup
extension SettingsViewController {
    private func setupDataSource() {
        self.dataSource = [
            Setting(cell: .text(text: Constants.Strings.Settings.openingText), isClickable: false),
            Setting(cell: .setting(text: Constants.Strings.Settings.privacyStatement, image: #imageLiteral(resourceName: "lock-icon")), isClickable: true),
            Setting(cell: .setting(text: Constants.Strings.Settings.help, image: #imageLiteral(resourceName: "question-icon")), isClickable: true)
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
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = dataSource[indexPath.row]
        guard type.isClickable else { return }
        // TODO: Show alert here to show that this feature has not yet been implemented
    }
    
}


