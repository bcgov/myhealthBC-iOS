//
//  ProfileDetailsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-01-27.
//

import UIKit

class ProfileDetailsViewController: BaseViewController {
    
    enum TableRow {
        case headerView
        case firstName
        case lastName
        case phn
        case physicalAddress
        case mailingAddress
        
        var getProfileDetailsScreenType: ProfileDetailsTableViewCell.ViewType? {
            switch self {
            case .headerView: return nil
            case .firstName: return .firstName
            case .lastName: return .lastName
            case .phn: return .phn
            case .physicalAddress: return .physicalAddress
            case .mailingAddress: return .mailingAddress
            }
        }
        
        func getTableViewCell(data: String?, tableView: UITableView, indexPath: IndexPath, delegateOwner: UIViewController) -> UITableViewCell {
            switch self {
            case .headerView:
                guard let name = data, let cell = tableView.dequeueReusableCell(withIdentifier: SettingsProfileTableViewCell.getName, for: indexPath) as? SettingsProfileTableViewCell else {
                    return SettingsProfileTableViewCell()
                }
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                cell.configureForProfileDetailsScreen(name: name)
                return cell
            case .firstName, .lastName, .phn, .physicalAddress, .mailingAddress:
                guard let type = self.getProfileDetailsScreenType, let cell = tableView.dequeueReusableCell(withIdentifier: ProfileDetailsTableViewCell.getName, for: indexPath) as? ProfileDetailsTableViewCell else {
                    return ProfileDetailsTableViewCell()
                }
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                cell.configure(data: data, type: type, delegateOwner: delegateOwner)
                return cell
            }
        }
    }
    
    class func constructProfileDetailsViewController(firstName: String?,
                                                     lastName: String?,
                                                     phn: String?,
                                                     physicalAddress: String?,
                                                     mailingAddress: String?) -> ProfileDetailsViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: ProfileDetailsViewController.self)) as? ProfileDetailsViewController {
            vc.firstName = firstName
            vc.lastName = lastName
            vc.phn = phn
            vc.physicalAddress = physicalAddress
            vc.mailingAddress = mailingAddress
            return vc
        }
        return ProfileDetailsViewController()
    }
    
    struct DataSource {
        let type: TableRow
        let text: String?
    }
    
    // MARK: Variables
    private var firstName: String?
    private var lastName: String?
    private var phn: String?
    private var physicalAddress: String?
    private var mailingAddress: String?
    
    private var dataSource: [DataSource] = []
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    override var getPassesFlowType: PassesFlowVCs? {
        return .ProfileAndSettingsViewController
    }
    
    override var getRecordFlowType: RecordsFlowVCs? {
        return .ProfileAndSettingsViewController
    }
    
    // MARK: Class funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDataSource()
        navSetup()
        setupTableView()
    }
    
    private func initializeDataSource() {
        let headerName = (firstName ?? "FirstName") + " " + (lastName ?? "LastName") //Note: Not formatting as per designs yet - consistency question
        dataSource.append(DataSource(type: .headerView, text: headerName))
        dataSource.append(DataSource(type: .firstName, text: firstName))
        dataSource.append(DataSource(type: .lastName, text: lastName))
        dataSource.append(DataSource(type: .phn, text: phn))
        dataSource.append(DataSource(type: .physicalAddress, text: physicalAddress))
        dataSource.append(DataSource(type: .mailingAddress, text: mailingAddress))
    }
}

// MARK: Nav setup
extension ProfileDetailsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .profile,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .small,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}

// MARK: Table View Setup
extension ProfileDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: SettingsProfileTableViewCell.getName, bundle: .main), forCellReuseIdentifier: SettingsProfileTableViewCell.getName)
        tableView.register(UINib.init(nibName: ProfileDetailsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: ProfileDetailsTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row]
        return data.type.getTableViewCell(data: data.text, tableView: tableView, indexPath: indexPath, delegateOwner: self)
    }
}


// MARK: Address help button delegate
extension ProfileDetailsViewController: ProfileDetailsTableViewCellDelegate {
    func addressHelpButtonTapped() {
        // TODO: Go to website here (using in app web browser)
        self.alert(title: "Not Done Yet", message: "In Progress")
        // Note: May have to refetch patient details when returning to this screen
    }
}
