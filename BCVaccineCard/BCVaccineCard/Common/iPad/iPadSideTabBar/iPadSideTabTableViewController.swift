//
//  iPadSideTabTableViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-11-20.
//

import UIKit

class iPadSideTabTableViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: [AppTabs] = []
    
    private var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = AppColours.appBlue
        setupListeners()
        setupDataSource()
        tableViewSetup()
    }
    
    private func setupListeners() {
        AppStates.shared.listenToAuth { authenticated in
            self.setupDataSource()
            self.tableView.reloadData()
        }
//        NotificationCenter.default.addObserver(self, selector: #selector(tabChanged), name: .tabChanged, object: nil)
    }
    
    private func setupDataSource() {
        if AuthManager().isAuthenticated {
            dataSource = AppTabBarController.iPadAuthenticatedTabs
        } else {
            dataSource = AppTabBarController.iPadUnauthenticatedTabs
        }
    }
    
//    @objc private func tabChanged(_ notification: Notification) {
//        guard let userInfo = notification.userInfo as? [String: Int] else { return }
//        guard let index = userInfo["index"] else { return }
//        self.index = index
//        self.tableView.reloadData()
//    }

}

// MARK: Table View logic
extension iPadSideTabTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func tableViewSetup() {
        tableView.register(UINib.init(nibName: iPadSideTabTableViewCell.getName, bundle: .main), forCellReuseIdentifier: iPadSideTabTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tab = dataSource[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: iPadSideTabTableViewCell.getName, for: indexPath) as? iPadSideTabTableViewCell else {
            return iPadSideTabTableViewCell()
        }
        cell.configure(tab: tab, selected: indexPath.row == self.index)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.index = indexPath.row
        let userInfo: [String: Int] = ["index": self.index]
        NotificationCenter.default.post(name: .tabChangedFromiPad, object: nil, userInfo: userInfo as [AnyHashable : Any])
    }
    
    
    
    
}
