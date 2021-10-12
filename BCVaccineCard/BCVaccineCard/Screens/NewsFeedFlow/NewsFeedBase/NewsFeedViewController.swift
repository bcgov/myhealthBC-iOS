//
//  NewsFeedViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit

class NewsFeedViewController: BaseViewController {

    class func constructNewsFeedViewController() -> NewsFeedViewController {
        if let vc = Storyboard.newsFeed.instantiateViewController(withIdentifier: String(describing: NewsFeedViewController.self)) as? NewsFeedViewController {
            return vc
        }
        return NewsFeedViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: NewsFeedData?
    
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
        return .lightContent
    }
    
    private func setup() {
        fetchDataSource()
        setupTableView()
    }

}

// MARK: Navigation setup
extension NewsFeedViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .newsFeed,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .large,
                                               targetVC: self)
    }
}

// MARK: Data Source Setup
// TODO: This is where we will fetch from the xml rss feed
extension NewsFeedViewController {
    private func fetchDataSource() {
        // Fetch Here
    }
}

// MARK: TableView setup
extension NewsFeedViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: NewsFeedTableViewCell.getName, bundle: .main), forCellReuseIdentifier: NewsFeedTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.channel.item.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = self.dataSource, dataSource.channel.item.count > 0 else { return UITableViewCell() }
        if let cell = tableView.dequeueReusableCell(withIdentifier: NewsFeedTableViewCell.getName, for: indexPath) as? NewsFeedTableViewCell {
            cell.configure(item: dataSource.channel.item[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = self.dataSource else { return }
        let link = dataSource.channel.item[indexPath.row].link
        self.openURLInSafariVC(withURL: link)
    }
    
}
