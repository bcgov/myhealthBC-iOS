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

        // Do any additional setup after loading the view.
        
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
        // TODO: Delete record - show alert first
        // TODO: Pop view controller (make sure that previous VC loads data source in view will appear
    }
}
