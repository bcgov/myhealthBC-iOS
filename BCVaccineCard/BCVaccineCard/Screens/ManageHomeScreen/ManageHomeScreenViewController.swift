//
//  ManageHomeScreenViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-26.
//

import UIKit

class ManageHomeScreenViewController: BaseViewController {
    
    class func construct(viewModel: ViewModel) -> ManageHomeScreenViewController {
        if let vc = Storyboard.home.instantiateViewController(withIdentifier: String(describing: ManageHomeScreenViewController.self)) as? ManageHomeScreenViewController {
            vc.viewModel = viewModel 
            return vc
        }
        return ManageHomeScreenViewController()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: ViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navSetup()
        setupTableView()
    }

}

// MARK: Nav setup
extension ManageHomeScreenViewController {
    private func navSetup() {
        let navButton = NavButton(image: UIImage(named: "quick_checkmark"), action: #selector(self.saveButtonTapped), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint))
        
        self.navDelegate?.setNavigationBarWith(title: "Manage",
                                               leftNavButton: nil,
                                               rightNavButton: navButton,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    @objc private func saveButtonTapped() {
        savePreferences()
    }
    
}

// MARK: Table view logic
extension ManageHomeScreenViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: ManageQuickLinkTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ManageQuickLinkTableViewCell.getName)
        tableView.register(UINib.init(nibName: ManageLinksTextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ManageLinksTextTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.dataSource.count ?? 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dsSection = viewModel?.dataSource[section] else { return 0 }
        switch dsSection {
        case .introText: return 1
        case .healthRecord(types: let types): return types.count
        case .service(types: let types): return types.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = viewModel?.dataSource[indexPath.section] else { return UITableViewCell() }
        switch section {
        case .introText:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ManageLinksTextTableViewCell.getName, for: indexPath) as? ManageLinksTextTableViewCell else {
                return ManageLinksTextTableViewCell()
            }
            return cell
        case .healthRecord(types: let types), .service(types: let types):
            let data = types[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ManageQuickLinkTableViewCell.getName, for: indexPath) as? ManageQuickLinkTableViewCell else {
                return ManageQuickLinkTableViewCell()
            }
            cell.configure(quickLink: data.type, enabled: data.enabled, delegateOwner: self, indexPath: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.dataSource[section].getSectionTitle
    }
    
    // TODO: Implement this
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        <#code#>
//    }
    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        if let title = viewModel?.dataSource[section].getSectionTitle {
//            let header = view as? UITableViewHeaderFooterView
//            header?.textLabel?.textColor = AppColours.appBlue
//            header?.textLabel?.font = UIFont.bcSansBoldWithSize(size: 15)
//            header?.textLabel?.text = title
//        }
//    }
}

extension ManageHomeScreenViewController: ManageQuickLinkTableViewCellDelegate {
    func checkboxTapped(enabled: Bool, indexPath: IndexPath) {
        updateDataSource(at: indexPath, enabled: enabled)
    }
    
    private func updateDataSource(at indexPath: IndexPath, enabled: Bool) {
        guard let type = viewModel?.dataSource[indexPath.section] else { return }
        if let newData = type.constructNewTypesOnEnabled(enabled: enabled, indexPath: indexPath) {
            switch type {
            case .introText: break
            case .healthRecord:
                viewModel?.dataSource[indexPath.section] = DataSource.healthRecord(types: newData)
            case .service:
                viewModel?.dataSource[indexPath.section] = DataSource.service(types: newData)
            }
        }
        
    }
}

// MARK: Save logic
extension ManageHomeScreenViewController {
    private func savePreferences() {
        // TODO: Convert data source into preferences string - note, will need to check if organ donor status changes, as the request for that is different
        // 1: Convert into preferences string
        // 2: Call API with new put request
        // 3: Check if organ donor preference changed
        // 4: If it did, then hit put request with organ donor specific change
        // 5: After conclusion of all requests, hit fetch and store again
        // 6: At conclusion of fetch and store, pop back to home screen where we will refetch data (evaluate best way to do this)
    }
}
