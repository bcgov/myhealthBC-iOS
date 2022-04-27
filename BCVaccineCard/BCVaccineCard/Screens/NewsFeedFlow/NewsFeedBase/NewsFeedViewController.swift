//
//  NewsFeedViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
// https://news.gov.bc.ca/news-subscribe/covid-19/feed

import UIKit
import AlamofireRSSParser
import Alamofire

// TODO: Refactor so that this screen uses networking layer instead of separate implementation
// Leaving commented code for now as we may be using that later, once refactoring begins

class NewsFeedViewController: BaseViewController {

    class func constructNewsFeedViewController() -> NewsFeedViewController {
        if let vc = Storyboard.newsFeed.instantiateViewController(withIdentifier: String(describing: NewsFeedViewController.self)) as? NewsFeedViewController {
            return vc
        }
        return NewsFeedViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
//    private var dataSource: NewsFeedData?
    private var dataSource: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observerSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navSetup()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Set Accessibility element to be the Navigation heading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.navigationController)
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func observerSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNewsFeed), name: .reloadNewsFeed, object: nil)
    }
    
    private func setup() {
        fetchDataSource()
        setupTableView()
    }

}

// MARK: Reload news feed and table view on tab changed
extension NewsFeedViewController {
    @objc private func reloadNewsFeed() {
        self.setup()
    }
}

// MARK: Navigation setup
extension NewsFeedViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .newsFeed,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}

// MARK: Data Source Setup
// TODO: This is where we will fetch from the xml rss feed
extension NewsFeedViewController {
    private func fetchDataSource() {
        guard let url = URL(string: "https://news.gov.bc.ca/news-subscribe/covid-19/feed") else { return }
        self.tableView.startLoadingIndicator(backgroundColor: .clear)
        AF.request(url).responseRSS() { (response) -> Void in
            if let feed: RSSFeed = response.value {
                self.dataSource = feed.items.map { Item(link: $0.link, title: $0.title, itemDescription: $0.itemDescription, pubDate: $0.pubDate) }
                self.tableView.reloadData()
                self.tableView.endLoadingIndicator()
            }
        }
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
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NewsFeedTableViewCell.getName, for: indexPath) as? NewsFeedTableViewCell {
            cell.configure(item: dataSource[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let link = dataSource[indexPath.row].link else { return }
        AnalyticsService.shared.track(action: .NewsLinkSelected, text: link)
        self.openURLInSafariVC(withURL: link)
    }
    
}
