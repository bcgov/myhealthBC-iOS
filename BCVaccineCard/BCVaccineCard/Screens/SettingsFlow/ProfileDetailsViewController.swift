//
//  ProfileDetailsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-01-27.
//

import UIKit

class ProfileDetailsViewController: BaseViewController {
    
    enum TableRow: Int, CaseIterable {
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
                cell.configureForProfileDetailsScreen(name: name)
                return cell
            case .firstName, .lastName, .phn, .physicalAddress, .mailingAddress:
                guard let type = self.getProfileDetailsScreenType, let cell = tableView.dequeueReusableCell(withIdentifier: ProfileDetailsTableViewCell.getName, for: indexPath) as? ProfileDetailsTableViewCell else {
                    return ProfileDetailsTableViewCell()
                }
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
    
    // MARK: Variables
    private var firstName: String?
    private var lastName: String?
    private var phn: String?
    private var physicalAddress: String?
    private var mailingAddress: String?
    
    private var dataSource: [String?] = []
    
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
        
        setupTableView()
        navSetup()
        setupListener()
        self.throttleAPIWorker = LoginThrottleAPIWorker(delegateOwner: self)
    }
    
    private func initializeDataSource() {
        dataSource.append(firstName)
        dataSource.append(lastName)
        dataSource.append(phn)
        dataSource.append(physicalAddress)
        dataSource.append(mailingAddress)
    }
}
