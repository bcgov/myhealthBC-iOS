//
//  HealthRecordDetailViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This view controller will be a table view with "Delete" in the navigation bar, and will be customizable depending on what the record is, etc. Will likely use an enum here for imm record, or test result

import UIKit

class HealthRecordDetailViewController: BaseViewController {
    
    class func constructHealthRecordDetailViewController(dataSource: HealthRecordsDetailDataSource) -> HealthRecordDetailViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: HealthRecordDetailViewController.self)) as? HealthRecordDetailViewController {
            vc.dataSource = dataSource
            return vc
        }
        return HealthRecordDetailViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!

    private var dataSource: HealthRecordsDetailDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        setupTableView()
    }

}

// MARK: Navigation setup
extension HealthRecordDetailViewController {
    private func navSetup() {
        let rightNavButton = NavButton(title: .delete,
                                                       image: nil, action: #selector(self.deleteButton),
                                                       accessibility: Accessibility(traits: .button, label: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconTitle, hint: AccessibilityLabels.HealthRecordsDetailScreen.navRightIconHint))
        self.navDelegate?.setNavigationBarWith(title: self.dataSource.type.getDetailNavTitle,
                                               leftNavButton: nil,
                                               rightNavButton: rightNavButton,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }

    @objc private func deleteButton() {
        switch dataSource.type {
        case .covidImmunizationRecord(model: let model, immunizations: let immunizations):
            alert(title: "Delete Record", message: "The Health Pass that is linked to this record will be removed. You will be required to enter your health information again to access the record.", buttonOneTitle: "Cancel", buttonOneCompletion: {
                // Do Nothing
            }, buttonTwoTitle: "Delete") {
                //TODO: Delete card and pop view controller
            }
        case .covidTestResult(model: let model):
            alert(title: "Delete Test Result", message: "Do you want to delete this test result?", buttonOneTitle: "Cancel", buttonOneCompletion: {
                // Do Nothing
            }, buttonTwoTitle: "Delete") {
                //TODO: Delete test result and pop view controller
            }
        }
    }
}

// MARK: TableView setup
extension HealthRecordDetailViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: BannerViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: BannerViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: TextListViewTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextListViewTableViewCell.getName)
        tableView.register(UINib.init(nibName: StaticPositiveTestTableViewCell.getName, bundle: .main), forCellReuseIdentifier: StaticPositiveTestTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    // TODO: Should refactor data source to be more safe
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataSource.type {
        case .covidImmunizationRecord(model: let model, immunizations: let immunizations):
            return immunizations.count + 1
        case .covidTestResult(model: let model):
            if model.status == .positive {
                return 3
            } else {
                return 2
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: BannerViewTableViewCell.getName, for: indexPath) as? BannerViewTableViewCell {
                cell.configure(type: dataSource.type)
                return cell
            }
            return UITableViewCell()
        } else {
            switch dataSource.type {
            case .covidImmunizationRecord:
                return returnTextListCellWithIndexPathOffset(offset: 1, indexPath: indexPath, tableView: tableView)
            case .covidTestResult(model: let model):
                if model.status == .positive {
                    // Show static cell first
                    if indexPath.row == 1 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: StaticPositiveTestTableViewCell.getName, for: indexPath) as? StaticPositiveTestTableViewCell {
                            return cell
                        }
                        return UITableViewCell()
                    } else {
                        return returnTextListCellWithIndexPathOffset(offset: 2, indexPath: indexPath, tableView: tableView)
                    }
                    
                } else {
                    return returnTextListCellWithIndexPathOffset(offset: 1, indexPath: indexPath, tableView: tableView)
                }
            }
        }
    }
    
    private func returnTextListCellWithIndexPathOffset(offset: Int, indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: TextListViewTableViewCell.getName, for: indexPath) as? TextListViewTableViewCell {
            let data = dataSource.getTextSets[indexPath.row - offset]
            cell.configure(data: data)
            return cell
        }
        return UITableViewCell()
    }
}
