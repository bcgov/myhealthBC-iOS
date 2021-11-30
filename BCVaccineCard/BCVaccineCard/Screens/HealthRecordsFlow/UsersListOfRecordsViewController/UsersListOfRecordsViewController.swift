//
//  UsersListOfRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This will be a table view controller with editable cells (for deleting) - nav bar will have same edit/done functionality that covid 19 view controller has

import UIKit

class UsersListOfRecordsViewController: BaseViewController {
    
    class func constructUsersListOfRecordsViewController(name: String) -> UsersListOfRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: UsersListOfRecordsViewController.self)) as? UsersListOfRecordsViewController {
            vc.name = name
            return vc
        }
        return UsersListOfRecordsViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!

    private var name: String!
    private var dataSource: [UserRecordListView.RecordType] = []
    
    private var inEditMode = false {
        didSet {
//            tableViewLeadingConstraint.constant = inEditMode ? 0.0 : 8.0
//            tableViewTrailingConstraint.constant = inEditMode ? 0.0 : 8.0
            self.tableView.setEditing(inEditMode, animated: false)
            self.tableView.reloadData()
            navSetup()
            self.tableView.layoutSubviews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        fetchDataSource()
        
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
        setupLabel()
        setupTableView()
    }

}

// MARK: Navigation setup
extension UsersListOfRecordsViewController {
    private func navSetup() {
        let hasRecords = !self.dataSource.isEmpty
        let editModeNavButton = inEditMode ? NavButton(title: .done,
                                                       image: nil, action: #selector(self.doneButton),
                                                       accessibility: Accessibility(traits: .button, label: AccessibilityLabels.ListOfHealthRecordsScreen.navRightDoneIconTitle, hint: AccessibilityLabels.ListOfHealthRecordsScreen.navRightDoneIconHint)) :
        NavButton(title: .edit,
                  image: nil, action: #selector(self.editButton),
                  accessibility: Accessibility(traits: .button, label: AccessibilityLabels.ListOfHealthRecordsScreen.navRightEditIconTitle, hint: AccessibilityLabels.ListOfHealthRecordsScreen.navRightEditIconHint))
        let rightNavButton = hasRecords ? editModeNavButton : nil
        self.navDelegate?.setNavigationBarWith(title: self.name + " " + .recordText.capitalized,
                                               leftNavButton: nil,
                                               rightNavButton: rightNavButton,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }

    @objc private func doneButton() {
        inEditMode = false
    }
    
    @objc private func editButton() {
        tableView.isEditing = false
        inEditMode = true
    }
}

// MARK: Data Source Setup
extension UsersListOfRecordsViewController {
    private func fetchDataSource() {
        dataSource = StorageService.shared.getListOfHealthRecordsForName(name: self.name)
    }
}
