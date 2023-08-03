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
    
    enum ResultOptions {
        case justNormal(success: Bool)
        case justOrgan(success: Bool)
        case bothAttempted(normalSuccess: Bool, organSuccess: Bool)
        case neitherAttempted
        
        struct Message {
            let title: String
            let message: String
        }
        
        var finalMessageToShow: Message {
            switch self {
            case .justNormal(let success), .justOrgan(let success):
                return success ? Message(title: "Success", message: "Your home screen preferences were updated successfully") : Message(title: "Error", message: "There was an issue updating your preferences, please try again later.")
            case .bothAttempted(let normalSuccess, let organSuccess):
                if normalSuccess && organSuccess {
                    return Message(title: "Success", message: "Your home screen preferences were updated successfully")
                } else if (!normalSuccess || !organSuccess) && !(normalSuccess && organSuccess) {
                    return Message(title: "Partial Success", message: "There was an issue updating some of your preferences")
                } else {
                    return Message(title: "Error", message: "There was an issue updating your preferences, please try again later.")
                }
            case .neitherAttempted:
                return Message(title: "", message: "")
            }
        }
        
        var shouldRefetchPreferences: Bool {
            switch self {
            case .justNormal(success: let success), .justOrgan(success: let success): return success
            case .bothAttempted(let normalSuccess, let organSuccess):
                return !(!normalSuccess && !organSuccess)
            case .neitherAttempted: return false
            }
        }
        
        var alertAvailable: Bool {
            switch self {
            case .neitherAttempted: return false
            default: return true
            }
        }
    }

    
    private func dismissWithGeneralError() {
        self.alert(title: "Error", message: "Unable to update quick links") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func dismissWithAlert(message: ResultOptions) {
        guard message.alertAvailable else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let details = message.finalMessageToShow
        self.alert(title: details.title, message: details.message) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func generateResultOption(normalStatus: Bool?, organStatus: Bool?) -> ResultOptions {
        var resultOption: ResultOptions
        if organStatus == nil, let normalStatus = normalStatus {
            resultOption = .justNormal(success: normalStatus)
        } else if normalStatus == nil, let organStatus = organStatus {
            resultOption = .justOrgan(success: organStatus)
        } else if let normalStatus = normalStatus, let organStatus = organStatus {
            resultOption = .bothAttempted(normalSuccess: normalStatus, organSuccess: organStatus)
        } else if normalStatus == nil && organStatus == nil {
            resultOption = .neitherAttempted
        } else {
            resultOption = .neitherAttempted
        }
        return resultOption
    }
    
    private func savePreferences() {
        // TODO: Optimize top section
        
        let normalVersion = StorageService.shared.fetchQuickLinksVersion(forOrganDonor: false)
        let organVersion = StorageService.shared.fetchQuickLinksVersion(forOrganDonor: true)
        var updateOrgan: Bool
        var organValue: String = ""
        var updateHealthRecordsLinks: Bool
        

        guard let quickLinks = viewModel?.constructAPIQuickLinksModelFromDataSource() else {
            dismissWithGeneralError()
            return
        }
        // Check if we need to hit health records links endpoint
        let newRecordsLinks = viewModel?.getHealthRecordQuickLinksOnly(quickLinks: quickLinks) ?? []
        let newRecordsString = ManageHomeScreenViewController.ViewModel.constructJsonStringForAPIPreferences(quickLinks: newRecordsLinks)
        updateHealthRecordsLinks = newRecordsString != viewModel?.originalHealthRecordString && viewModel?.originalHealthRecordString != nil
        
        // Check if we need to hit organ donor endpoint
        let containsOrgan = viewModel?.checkForOrganDonorLink(quickLinks: quickLinks) ?? false
        updateOrgan = containsOrgan != viewModel?.organDonorLinkEnabledInitially
        if updateOrgan {
            // This is the value we pass up to hide organ donor quick link... yeah, I know
            organValue = containsOrgan ? "false" : "true"
        }
        
        guard let preferenceString = ManageHomeScreenViewController.ViewModel.constructJsonStringForAPIPreferences(quickLinks: quickLinks) else {
            dismissWithGeneralError()
            return
        }
        
        var normalStatus: Bool?
        var organStatus: Bool?
        // TODO: Clean this up - just not putting in the effort until we know if the API will get updated from current poor structure
        
        if updateHealthRecordsLinks {
            self.viewModel?.patientService.updateQuickLinkPreferences(preferenceString: preferenceString, preferenceType: .NormalQuickLinks, version: normalVersion, completion: { result, showAlert in
                if let result = result {
                    // Track here
                    normalStatus = true
                } else if showAlert {
                    // Track here
                    normalStatus = false
                }
                if updateOrgan {
                    self.viewModel?.patientService.updateQuickLinkPreferences(preferenceString: organValue, preferenceType: .OrganDonor, version: organVersion, completion: { organResult, organShowAlert in
                        if let organResult = organResult {
                            // Track here
                            organStatus = true
                        } else if organShowAlert {
                            // Track here
                            organStatus = false
                        }
                        let status = self.generateResultOption(normalStatus: normalStatus, organStatus: organStatus)
                        if status.shouldRefetchPreferences {
                            guard let patient = StorageService.shared.fetchAuthenticatedPatient() else { return }
                            self.viewModel?.patientService.fetchAndStoreQuickLinksPreferences(for: patient, useLoader: true, completion: { preferences in
                                print(preferences)
                                NotificationCenter.default.post(name: .refetchQuickLinksFromCoreData, object: nil, userInfo: nil)
                                self.dismissWithAlert(message: status)
                            })
                        } else {
                            self.dismissWithAlert(message: status)
                        }
                    })
                } else {
                    let status = self.generateResultOption(normalStatus: normalStatus, organStatus: organStatus)
                    if status.shouldRefetchPreferences {
                        guard let patient = StorageService.shared.fetchAuthenticatedPatient() else { return }
                        self.viewModel?.patientService.fetchAndStoreQuickLinksPreferences(for: patient, useLoader: true, completion: { preferences in
                            print(preferences)
                            NotificationCenter.default.post(name: .refetchQuickLinksFromCoreData, object: nil, userInfo: nil)
                            self.dismissWithAlert(message: status)
                        })
                    } else {
                        self.dismissWithAlert(message: status)
                    }
                }
                // Check condition here to refetch or not
                
            })
        } else if updateOrgan {
            self.viewModel?.patientService.updateQuickLinkPreferences(preferenceString: organValue, preferenceType: .OrganDonor, version: organVersion, completion: { organResult, organShowAlert in
                if let organResult = organResult {
                    // Track here
                    organStatus = true
                } else if organShowAlert {
                    // Track here
                    organStatus = false
                }
                let status = self.generateResultOption(normalStatus: normalStatus, organStatus: organStatus)
                if status.shouldRefetchPreferences {
                    guard let patient = StorageService.shared.fetchAuthenticatedPatient() else { return }
                    self.viewModel?.patientService.fetchAndStoreQuickLinksPreferences(for: patient, useLoader: true, completion: { preferences in
                        print(preferences)
                        NotificationCenter.default.post(name: .refetchQuickLinksFromCoreData, object: nil, userInfo: nil)
                        self.dismissWithAlert(message: status)
                    })
                } else {
                    self.dismissWithAlert(message: status)
                }
            })
        } else {
            self.dismissWithAlert(message: .neitherAttempted)
        }
        
        
        
        
        
        // TODO: Convert data source into preferences string - note, will need to check if organ donor status changes, as the request for that is different
        // 1: Convert into preferences string
        // 2: Call API with new put request
        // 3: Check if organ donor preference changed
        // 4: If it did, then hit put request with organ donor specific change
        // 5: After conclusion of all requests, hit fetch and store again
        // 6: At conclusion of fetch and store, pop back to home screen where we will refetch data (evaluate best way to do this)
    }
}
