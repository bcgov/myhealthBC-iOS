//
//  ResourceViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-11.
//

import UIKit

class ResourceViewController: BaseViewController {
    
    class func constructResourceViewController() -> ResourceViewController {
        if let vc = Storyboard.resource.instantiateViewController(withIdentifier: String(describing: ResourceViewController.self)) as? ResourceViewController {
            return vc
        }
        return ResourceViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: [ResourceDataSource] = []

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
        setupDataSource()
        setupTableView()
    }

}

// MARK: Navigation setup
extension ResourceViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .resource,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .large,
                                               targetVC: self)
    }
}

// MARK: Data Source Setup
extension ResourceViewController {
    private func setupDataSource() {
        // TODO: Get actual links for resources
        self.dataSource = [
            ResourceDataSource(type: .text(type: .plainText, font: UIFont.bcSansRegularWithSize(size: 17)), cellStringData: .resourceDescriptionText),
            ResourceDataSource(type: .resource(type: Resource(image: UIImage(named: "covid-testing-location")!, text: .covidTestLocationText, link: "http://www.bccdc.ca/health-info/diseases-conditions/covid-19/testing/where-to-get-a-covid-19-test-in-bc"))),
            ResourceDataSource(type: .resource(type: Resource(image: UIImage(named: "covid-testing-kit")!, text: .covidTestKitText, link: "https://www.google.com")))
        ]
    }
}

// MARK: TableView setup
extension ResourceViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: ResourceTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ResourceTableViewCell.getName)
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
        let cellType = dataSource[indexPath.row].type
        switch cellType {
        case .text(type: let type, font: let font):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell, let text = dataSource[indexPath.row].cellStringData {
                cell.configure(forType: type, text: text, withFont: font, labelSpacingAdjustment: 0)
                return cell
            }
        case .resource(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: ResourceTableViewCell.getName, for: indexPath) as? ResourceTableViewCell {
                cell.configure(resource: type)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = dataSource[indexPath.row].type
        switch type {
        case .text: return
        case .resource(type: let resource):
            self.openURLInSafariVC(withURL: resource.link)
        }
    }
    
}
