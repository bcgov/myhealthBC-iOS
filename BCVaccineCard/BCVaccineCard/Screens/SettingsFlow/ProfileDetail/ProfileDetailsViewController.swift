//
//  ProfileDetailsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-01-27.
//

import UIKit

class ProfileDetailsViewController: BaseDependentViewController {
    
    enum TableRow {
        case headerView
        case firstName
        case lastName
        case phn
        case physicalAddress
        case mailingAddress
        case communicationPreferences
        case dateOfBirth
        case dependentDelegateCount(count: Int)
        case removeDependentButton
        
        var getProfileDetailsScreenType: ProfileDetailsTableViewCell.ViewType? {
            switch self {
            case .headerView: return nil
            case .firstName: return .firstName
            case .lastName: return .lastName
            case .phn: return .phn
            case .physicalAddress: return .physicalAddress
            case .mailingAddress: return .mailingAddress
            case .communicationPreferences: return nil
            case .dateOfBirth: return .dob
            case .dependentDelegateCount: return nil
            case .removeDependentButton: return nil
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
            case .firstName, .lastName, .phn, .physicalAddress, .mailingAddress, .dateOfBirth:
                guard let type = self.getProfileDetailsScreenType, let cell = tableView.dequeueReusableCell(withIdentifier: ProfileDetailsTableViewCell.getName, for: indexPath) as? ProfileDetailsTableViewCell else {
                    return ProfileDetailsTableViewCell()
                }
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                cell.configure(data: data, type: type, delegateOwner: delegateOwner)
                return cell
            case .communicationPreferences:
                guard let patient = StorageService.shared.fetchAuthenticatedPatient(), let cell = tableView.dequeueReusableCell(withIdentifier: CommunicationPreferencesTableViewCell.getName, for: indexPath) as? CommunicationPreferencesTableViewCell else {
                    return CommunicationPreferencesTableViewCell()
                }
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                cell.configure(patient: patient)
                return cell
            case .dependentDelegateCount(let count):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DependentDelegateCountTableViewCell.getName, for: indexPath) as? DependentDelegateCountTableViewCell else { return DependentDelegateCountTableViewCell() }
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                cell.configure(delegateCount: count)
                return cell
            case .removeDependentButton:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RemoveDependentTableViewCell.getName, for: indexPath) as? RemoveDependentTableViewCell else { return RemoveDependentTableViewCell() }
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                cell.configure(delegateOwner: delegateOwner)
                return cell
            }
        }
    }
    
    class func construct(viewModel: ViewModel) -> ProfileDetailsViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: ProfileDetailsViewController.self)) as? ProfileDetailsViewController {
            vc.firstName = viewModel.firstName
            vc.lastName = viewModel.lastName
            vc.phn = viewModel.phn
            vc.physicalAddress = viewModel.physicalAddress
            vc.mailingAddress = viewModel.mailingAddress
            vc.dob = viewModel.dob
            vc.delegateCount = viewModel.delegateCount
            vc.patient = viewModel.patient
            vc.dependent = viewModel.dependent
            vc.type = viewModel.type
            return vc
        }
        return ProfileDetailsViewController()
    }
    
    struct DataSource {
        let type: TableRow
        let text: String?
    }
    
    // MARK: Variables
    private var patient: Patient?
    private var dependent: Dependent?
    private var firstName: String?
    private var lastName: String?
    private var phn: String?
    private var physicalAddress: String?
    private var mailingAddress: String?
    private var dob: String?
    private var delegateCount: Int?
    private var type: ViewModel.ScreenType!
    
    private var dataSource: [DataSource] = []
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    var profileService: PatientService?

    
    // MARK: Class funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        profileService = PatientService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork()))
        initializeDataSource(for: self.type)
        navSetup()
        setupTableView()
        guard let type = self.type else { return }
        switch type {
        case .PatientProfile:
            if AppDelegate.sharedInstance?.cachedCommunicationPreferences == nil {
                self.fetchPatientCommunicationDetails()
            }
        default: return
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.apiClient = nil
    }
    
    private func initializeDataSource(for type: ViewModel.ScreenType) {
        let headerName = (firstName ?? "FirstName") + " " + (lastName ?? "LastName") //Note: Not formatting as per designs yet - consistency question
        dataSource.append(DataSource(type: .headerView, text: headerName))
        dataSource.append(DataSource(type: .firstName, text: firstName))
        dataSource.append(DataSource(type: .lastName, text: lastName))
        dataSource.append(DataSource(type: .phn, text: phn))
        switch type {
        case .PatientProfile:
            dataSource.append(DataSource(type: .physicalAddress, text: physicalAddress))
            dataSource.append(DataSource(type: .mailingAddress, text: mailingAddress))
            dataSource.append(DataSource(type: .communicationPreferences, text: nil))
        case .DependentProfile:
            dataSource.append(DataSource(type: .dateOfBirth, text: dob))
            let count = Int(self.dependent?.totalDelegateCount ?? 0)
            dataSource.append(DataSource(type: .dependentDelegateCount(count: count), text: nil))
            dataSource.append(DataSource(type: .removeDependentButton, text: nil))

        }
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
        tableView.register(UINib.init(nibName: CommunicationPreferencesTableViewCell.getName, bundle: .main), forCellReuseIdentifier: CommunicationPreferencesTableViewCell.getName)
        tableView.register(UINib.init(nibName: DependentDelegateCountTableViewCell.getName, bundle: .main), forCellReuseIdentifier: DependentDelegateCountTableViewCell.getName)
        tableView.register(UINib.init(nibName: RemoveDependentTableViewCell.getName, bundle: .main), forCellReuseIdentifier: RemoveDependentTableViewCell.getName)
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

// MARK: Remove dependent logic here
extension ProfileDetailsViewController: RemoveDependentTableViewCellDelegate {
    func removeDependentButtonTapped() {
        guard let dependent = self.dependent else {return}
        self.delete(dependent: dependent) { [weak self] confirmed in
            guard confirmed else {return}
            self?.popBack(toControllerType: DependentsHomeViewController.self)
        }
    }

}



// MARK: Address help button delegate
extension ProfileDetailsViewController: ProfileDetailsTableViewCellDelegate {
    func addressHelpButtonTapped() {
//        let urlString = "https://www.addresschange.gov.bc.ca/"
//        let vc = UpdateAddressViewController.constructUpdateAddressViewController(delegateOwner: self, urlString: urlString)
//        self.navigationController?.pushViewController(vc, animated: true)
        if let url = URL(string: "https://www.addresschange.gov.bc.ca/"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: For address change callback - Not using currently
extension ProfileDetailsViewController: UpdateAddressViewControllerDelegate {
    func webViewClosed() {
        self.fetchPatientDetails()
    }
}

// MARK: Fetch Patient Details after address has been updated
extension ProfileDetailsViewController {
    private func fetchPatientDetails() {
        profileService?.fetchAndStoreDetails { patient in
            self.physicalAddress = AuthenticatedPatientDetailsResponseObject.Address(streetLines: patient?.physicalAddress?.streetLines, city: patient?.physicalAddress?.city, state: patient?.physicalAddress?.state, postalCode: patient?.physicalAddress?.postalCode, country: patient?.physicalAddress?.country).getAddressString
            self.mailingAddress = AuthenticatedPatientDetailsResponseObject.Address(streetLines: patient?.postalAddress?.streetLines, city: patient?.postalAddress?.city, state: patient?.postalAddress?.state, postalCode: patient?.postalAddress?.postalCode, country: patient?.postalAddress?.country).getAddressString
            self.dataSource = []
            self.initializeDataSource(for: self.type)
            self.tableView.reloadData()
            self.tableView.endLoadingIndicator()
        }
    }
}


    
//    private func initializePatientDetails(authCredentials: AuthenticationRequestObject,
//                                          result: Result<AuthenticatedPatientDetailsResponseObject, ResultError>) {
//        switch result {
//        case .success(let patientDetails):
//            self.storePatient(patientDetails: patientDetails)
//        case .failure(let error):
//            Logger.log(string: error.localizedDescription, type: .Network)
//            self.tableView.endLoadingIndicator()
//        }
//    }
//
//    private func storePatient(patientDetails: AuthenticatedPatientDetailsResponseObject) {
//        let phyiscalAddress = StorageService.shared.createAndReturnAddress(addressDetails: patientDetails.resourcePayload?.physicalAddress)
//        let mailingAddress = StorageService.shared.createAndReturnAddress(addressDetails: patientDetails.resourcePayload?.postalAddress)
//        let patient = StorageService.shared.storePatient(name: patientDetails.getFullName,
//                                                         firstName: patientDetails.resourcePayload?.firstname,
//                                                         lastName: patientDetails.resourcePayload?.lastname,
//                                                         gender: patientDetails.resourcePayload?.gender,
//                                                         birthday: patientDetails.getBdayDate,
//                                                         phn: patientDetails.resourcePayload?.personalhealthnumber,
//                                                         physicalAddress: phyiscalAddress,
//                                                         mailingAddress: mailingAddress,
//                                                         hdid: AuthManager().hdid,
//                                                         authenticated: true)
//        self.physicalAddress = AuthenticatedPatientDetailsResponseObject.Address(streetLines: patient?.physicalAddress?.streetLines, city: patient?.physicalAddress?.city, state: patient?.physicalAddress?.state, postalCode: patient?.physicalAddress?.postalCode, country: patient?.physicalAddress?.country).getAddressString
//        self.mailingAddress = AuthenticatedPatientDetailsResponseObject.Address(streetLines: patient?.postalAddress?.streetLines, city: patient?.postalAddress?.city, state: patient?.postalAddress?.state, postalCode: patient?.postalAddress?.postalCode, country: patient?.postalAddress?.country).getAddressString
//        self.dataSource = []
//        initializeDataSource()
//        self.tableView.reloadData()
//        self.tableView.endLoadingIndicator()
//    }

// MARK: Fetch email and phone details for patient, then cache the values
extension ProfileDetailsViewController {
    private func fetchPatientCommunicationDetails() {
        self.tableView.startLoadingIndicator()
        profileService?.fetchProfile(completion: { result in
            self.tableView.endLoadingIndicator()
            self.updatePatientDetails(result: result)
        })
    }
    
    
    private func updatePatientDetails(result: AuthenticatedUserProfileResponseObject?) {
        if let result = result {
            self.updatePatient(result: result)
        } else {
            self.alert(title: "Error", message: "Sorry, there was an error fetching your communication preferences. Please try again later")
        }
    }
    
    private func updatePatient(result: AuthenticatedUserProfileResponseObject) {
        guard let existingPatient = StorageService.shared.fetchAuthenticatedPatient(), let phn = existingPatient.phn, let name = existingPatient.name, let birthday = existingPatient.birthday else {
            self.tableView.endLoadingIndicator()
            self.alert(title: "Error", message: "Sorry, there was an error fetching your communication preferences. Please try again later")
            return
        }
        let email = result.resourcePayload?.email
        let emailVerified = result.resourcePayload?.isEmailVerified ?? false
        let phone = result.resourcePayload?.smsNumber
        let phoneVerified = result.resourcePayload?.isSMSNumberVerified ?? false
        let patient = StorageService.shared.updatePatient(phn: phn,
                                                          name: name,
                                                          firstName: existingPatient.firstName,
                                                          lastName: existingPatient.lastName,
                                                          gender: existingPatient.gender,
                                                          birthday: birthday,
                                                          physicalAddress: existingPatient.physicalAddress,
                                                          mailingAddress: existingPatient.postalAddress,
                                                          email: email,
                                                          phone: phone,
                                                          emailVerified: emailVerified,
                                                          phoneVerified: phoneVerified,
                                                          hdid: AuthManager().hdid,
                                                          authenticated: true)
        AppDelegate.sharedInstance?.cachedCommunicationPreferences = CommunicationPreferences(email: email, emailVerified: emailVerified, phone: phone, phoneVerified: phoneVerified)
        
        self.dataSource = []
        initializeDataSource(for: self.type)
        self.tableView.reloadData()
        self.tableView.endLoadingIndicator()
    }
}

struct CommunicationPreferences {
    let email: String?
    let emailVerified: Bool
    let phone: String?
    let phoneVerified: Bool
}
