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
    
    private var dataSource: [ResourceDataSourceSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Set Accessibility element to be the Navigation heading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.navigationController)
        }
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
extension ResourceViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .healthResources,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}

// MARK: Data Source Setup
extension ResourceViewController {
    private func setupDataSource() {
        // TODO: Get actual links for resources http://www.bccdc.ca/health-info/diseases-conditions/covid-19/testing/where-to-get-a-covid-19-test-in-bc
        self.dataSource = [
            
            ResourceDataSourceSection(sectionTitle: nil, section: [ResourceDataSource(type: .text(type: .plainText, font: UIFont.bcSansRegularWithSize(size: 17)), cellStringData: .resourceDescriptionText)]),
            ResourceDataSourceSection(sectionTitle: nil, section: [
                ResourceDataSource(type: .resource(type: Resource(image: UIImage(named: "get-health-advice-resource")!, text: "Get health advice", link: "https://www.healthlinkbc.ca/"))),
                ResourceDataSource(type: .resource(type: Resource(image: UIImage(named: "get-vaccinated-resource")!, text: .getVaccinatedResource, link: "https://www2.gov.bc.ca/gov/content/covid-19/vaccine/register"))),
                ResourceDataSource(type: .resource(type: Resource(image: UIImage(named: "get-tested-resource")!, text: .getTestedResource, link: "http://www.bccdc.ca/health-info/diseases-conditions/covid-19/testing/where-to-get-a-covid-19-test-in-bc"))),
                ResourceDataSource(type: .resource(type: Resource(image: UIImage(named: "symptom-checker-resource")!, text: .covid19SymptomCheckerResource, link: "https://bc.thrive.health/covid19/en")))
                //                ResourceDataSource(type: .resource(type: Resource(image: UIImage(named: "school-resource")!, text: .schoolRelatedResource, link: "https://www.k12dailycheck.gov.bc.ca/healthcheck?execution=e1s1")))
            ])
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = dataSource[indexPath.section].section[indexPath.row].type
        switch cellType {
        case .text(type: let type, font: let font):
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell, let text = dataSource[indexPath.section].section[indexPath.row].cellStringData {
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
        let type = dataSource[indexPath.section].section[indexPath.row].type
        switch type {
        case .text: return
        case .resource(type: let resource):
            AnalyticsService.shared.track(action: .ResoruceLinkSelected, text: resource.link)
            self.openURLInSafariVC(withURL: resource.link)
        }
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        guard let title = dataSource[section].sectionTitle else { return nil }
    //        let headerView = UIView()
    //        headerView.backgroundColor = .white
    //
    //        let sectionLabel = UILabel(frame: CGRect(x: 8, y: 28, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
    //        sectionLabel.font = UIFont.bcSansBoldWithSize(size: 15)
    //        sectionLabel.textColor = AppColours.textBlack
    //        sectionLabel.text = title
    //        sectionLabel.sizeToFit()
    //        headerView.addSubview(sectionLabel)
    //
    //        return headerView
    //    }
    //
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        guard dataSource[section].sectionTitle != nil else { return 0 }
    //        return 50
    //    }
    
}
