//
//  LearnMoreViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-03-06.
//

import UIKit

class LearnMoreViewController: BaseViewController {
    class func construct() -> LearnMoreViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: LearnMoreViewController.self)) as? LearnMoreViewController {
            return vc
        }
        return LearnMoreViewController()
    }
    
    struct DataSource {
        enum CellType {
            case text
            case link(text: String, urlString: String)
        }
        
        struct Section {
            var rows: [CellType]
        }
        
        var sections: [Section]
    }
    
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var dataSource: DataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        navSetup()
        constructDataSource()
        tableViewSetup()
    }
    
    private func constructDataSource() {
        let section1 = DataSource.Section(rows: [.text])
        let section2Data = [
            DataSource.CellType.link(text: "HealthLink BC", urlString: "https://www.healthlinkbc.ca/tests-treatments-medications/medical-tests"),
            DataSource.CellType.link(text: "Mayo Clinic Laboratories", urlString: "https://www.mayocliniclabs.com/"),
            DataSource.CellType.link(text: "For pathology tests (like a biopsy)", urlString: "https://www.mypathologyreport.ca/"),
            DataSource.CellType.link(text: "Get checked online", urlString: "https://getcheckedonline.com/Pages/default.aspx")
        ]
        let section2 = DataSource.Section(rows: section2Data)
        self.dataSource = DataSource(sections: [section1, section2])
    }

}

// MARK: Navigation setup
extension LearnMoreViewController {
    private func navSetup() {
        let leftButton = NavButton(image: UIImage(named: "close-icon"), action: #selector(self.dismissScreen), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.LearnMoreScreen.navLeftIconTitle, hint: AccessibilityLabels.LearnMoreScreen.navLeftIconHint))
        self.navDelegate?.setNavigationBarWith(title: "Understand lab test result",
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
    
    @objc private func dismissScreen() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: Table View setup
extension LearnMoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func tableViewSetup() {
        tableView.register(UINib.init(nibName: LearnMoreLinksTableViewCell.getName, bundle: .main), forCellReuseIdentifier: LearnMoreLinksTableViewCell.getName)
        tableView.register(UINib.init(nibName: LearnMoreTextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: LearnMoreTextTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.sections[section].rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = dataSource?.sections[indexPath.section].rows[indexPath.row] else { return UITableViewCell() }
        switch row {
        case .text:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LearnMoreTextTableViewCell.getName, for: indexPath) as? LearnMoreTextTableViewCell else {
                return UITableViewCell()
            }
            return cell
        case .link(text: let text, urlString: let urlString):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LearnMoreLinksTableViewCell.getName, for: indexPath) as? LearnMoreLinksTableViewCell else {
                return UITableViewCell()
            }
            cell.config(link: text, urlString: urlString)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            view.backgroundColor = .white
            let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: tableView.frame.width - 8, height: 24))
            titleLabel.font = UIFont.bcSansBoldWithSize(size: 17)
            titleLabel.textColor = AppColours.textBlack
            titleLabel.text = "Related Information"
            titleLabel.backgroundColor = .white
            view.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 8).isActive = true
            NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -8).isActive = true
            
            return view
        }
        return nil
    }
}
