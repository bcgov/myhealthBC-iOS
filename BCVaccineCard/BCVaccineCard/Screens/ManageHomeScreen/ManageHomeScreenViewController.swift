//
//  ManageHomeScreenViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-26.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

class ManageHomeScreenViewController: BaseViewController {
    
    class func construct(viewModel: ViewModel) -> ManageHomeScreenViewController {
        if let vc = Storyboard.home.instantiateViewController(withIdentifier: String(describing: ManageHomeScreenViewController.self)) as? ManageHomeScreenViewController {
            vc.viewModel = viewModel 
            vc.initialDataSource = viewModel.dataSource
            return vc
        }
        return ManageHomeScreenViewController()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: ViewModel?
    var initialDataSource: [DataSource]?

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
        
        let rightNavButton: NavButton? = didDataSourceChange() ? navButton : nil
        
        self.navDelegate?.setNavigationBarWith(title: "Manage",
                                               leftNavButton: nil,
                                               rightNavButton: rightNavButton,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    @objc private func saveButtonTapped() {
        savePreferences()
    }
    
    private func didDataSourceChange() -> Bool {
        guard Constants.deviceType == .iPad else { return true }
        return viewModel?.dataSource != initialDataSource
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
        tableView.showsVerticalScrollIndicator = false
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
            cell.configure(quickLink: data, delegateOwner: self, indexPath: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard viewModel?.dataSource[section].getSectionTitle != nil else {
            return 0
        }
        return 32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = viewModel?.dataSource[section].getSectionTitle else { return nil }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 32))
        view.backgroundColor = .white
        let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: tableView.frame.width - 8, height: 24))
        titleLabel.font = UIFont.bcSansBoldWithSize(size: 15)
        titleLabel.textColor = AppColours.appBlue
        titleLabel.text = title
        titleLabel.backgroundColor = .white
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 8).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -8).isActive = true
        
        return view
    }
}

extension ManageHomeScreenViewController: ManageQuickLinkTableViewCellDelegate {
    func checkboxTapped(enabled: Bool, indexPath: IndexPath) {
        updateDataSource(at: indexPath, enabled: enabled)
        navSetup()
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
    
    private func dismissWithGeneralError() {
        self.alert(title: "Error", message: "Unable to update quick links") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func savePreferences() {
        let phn = StorageService.shared.fetchAuthenticatedPatient()?.phn ?? ""
        self.view.startLoadingIndicator()
        viewModel?.convertDataSourceToPreferencesAndSave(for: phn, completion: {
            self.view.endLoadingIndicator()
            self.alert(title: "Success", message: "Preferences updated") {
                NotificationCenter.default.post(name: .refetchQuickLinksFromCoreData, object: nil, userInfo: nil)
                guard !UIDevice.current.orientation.isLandscape else {
                    self.initialDataSource = self.viewModel?.dataSource
                    self.navSetup()
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
}
