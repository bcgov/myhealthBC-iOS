//
//  DependentsHomeViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-13.
//

import UIKit


class DependentsHomeViewController: BaseViewController {
    
    class func constructDependentsHomeViewController(patient: Patient?) -> DependentsHomeViewController {
        if let vc = Storyboard.dependents.instantiateViewController(withIdentifier: String(describing: DependentsHomeViewController.self)) as? DependentsHomeViewController {
            vc.patient = patient
            vc.fetchDataWhenMainPatientIsStored()
            return vc
        }
        return DependentsHomeViewController()
    }
    
    private var patient: Patient? = nil
    private let tableLeadingContraint: CGFloat = 16
    private let emptyLogoTag = 23412
    private let authManager = AuthManager()
    private let storageService = StorageService()
    private let networkService = DependentService(network: AFNetwork(), authManager: AuthManager())
    
    @IBOutlet weak var tableStackLeadingContraint: NSLayoutConstraint!
    @IBOutlet weak var desciptionLabel: UILabel!
    @IBOutlet weak var loginWIthBCSCButton: UIButton!
    @IBOutlet weak var addDependentButton: UIButton!
    @IBOutlet weak var manageDependentsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var dependents: [Dependent] = [] {
        didSet {
            if dependents.isEmpty {
                styleWithoutDependents()
            } else {
                styleWithDependents()
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetup()
        style()
        setupTableView()
        fetchData(fromRemote: true)
        fetchDataWhenAuthenticated()
    }
    
   // private func fetchData() {
   ///     service.fetchDependents { completed in
            // If completed, then reload data/update screen UI - if not completed, show an error
     //   }
        // TODO: Allocate this appropriately once storage has been updated
      //  dependents = []
       // setState()
       // setHealthRecordServiceAndFetchDependentRecords()
   // }
    
   // private func setHealthRecordServiceAndFetchDependentRecords() {
    //    guard dependents.count > 0 else { return }
     //   for dependent in dependents {
            // If this is the way we decide to do it, then should do some thread handling here
       //     let dependentsRecordService = HealthRecordsService(network: AFNetwork(), authManager: AuthManager(), currentDependant: dependent)
        //    dependentsRecordService.fetchHealthRecords()
       // }
       
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData(fromRemote: false)
    }
    
    // MARK: Actions
    @IBAction func addDependent(_ sender: Any) {
        guard let patient = patient else {
            return
        }
        let addVC = AddDependentViewController.constructAddDependentViewController(patient: patient)
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    @IBAction func manageDependents(_ sender: Any) {
        guard let patient = patient else {
            showToast(message: "Please try re-launching this application")
            return
        }
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "This feature requires an internet connection")
            return
        }
        let vc = ManageDependentsViewController.constructManageDependentsViewController(patient: patient)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func LoginWithBCSC(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        authenticate(initialView: .Landing, fromTab: .dependant)
    }
    
    // MARK: Data
    private func fetchData(fromRemote: Bool) {
        guard let patient = patient, authManager.isAuthenticated else {
            dependents = []
            setState()
            tableView.reloadData()
            return
        }
        
        dependents = patient.dependentsArray.sorted(by: {
            $0.info?.birthday ?? Date() > $1.info?.birthday ?? Date()
        })
        setState()
        tableView.reloadData()
        guard fromRemote else {return}
        
        networkService.fetchDependents(for: patient) { [weak self] storedDependents in
            self?.dependents = storedDependents.sorted(by: {
                $0.info?.birthday ?? Date() > $1.info?.birthday ?? Date()
            })
            self?.setState()
            self?.tableView.reloadData()
        }
    }
    
    // MARK: Listeners
    private func fetchDataWhenAuthenticated() {
        AppStates.shared.listenToAuth { [weak self] authenticated in
            guard let `self` = self else {return}
            if self.patient != nil {
                self.fetchData(fromRemote: true)
            }
            /*
             Else, fetchDataWhenMainPatientIsStored
             should have been initialized during initialization
             of this viewcontroller
             */
            
        }
    }
    
    private func fetchDataWhenMainPatientIsStored() {
        AppStates.shared.listenToStorage { [weak self] event in
            guard let `self` = self else {return}
            
            if  event.event == .Save,
                event.entity == .Patient,
                let storedPatient = event.object as? Patient {
                
                if storedPatient.authenticated {
                    self.patient = storedPatient
                    self.fetchData(fromRemote: true)
                } else {
                    self.fetchData(fromRemote: false)
                }
            }
            
        }
    }
    
    // MARK: Style
    func style() {
        desciptionLabel.font = UIFont.bcSansRegularWithSize(size: 15)
        desciptionLabel.textColor = AppColours.greyText
        style(button: addDependentButton, filled: true)
        style(button: loginWIthBCSCButton, filled: true)
        style(button: manageDependentsButton, filled: false)
        navSetup()
    }
    
    private func createLogoImgView() -> UIImageView {
        removeEmptyLogo()
        let imgView = UIImageView(frame: tableView.bounds)
        imgView.tag = emptyLogoTag
        view.addSubview(imgView)
        let padding = self.view.bounds.width / 10
        imgView.addEqualSizeContraints(to: tableView, paddingVertical: padding, paddingHorizontal: padding)
        imgView.contentMode = .scaleAspectFit
        return imgView
    }
    
    private func removeEmptyLogo() {
        guard let imgView = view.viewWithTag(emptyLogoTag) else {
            return
        }
        imgView.removeFromSuperview()
    }
    func style(button: UIButton, filled: Bool) {
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.bcSansBoldWithSize(size: 18)
        if filled {
            button.backgroundColor = AppColours.appBlue
            button.setTitleColor(.white, for: .normal)
            button.tintColor = .white
            
        } else {
            button.setTitleColor(AppColours.appBlue, for: .normal)
            button.backgroundColor = .white
            button.layer.borderWidth = 2
            button.layer.borderColor = AppColours.appBlue.cgColor
            button.tintColor = AppColours.appBlue
        }
    }
    
    // MARK: Screen States
    func setState() {
        switch authManager.authStaus {
        case .Authenticated:
            if dependents.isEmpty {
                styleWithoutDependents()
            } else {
                styleWithDependents()
            }
        case .AuthenticationExpired:
            styleAuthenticationExpired()
        case .UnAuthenticated:
            styleUnauthenticated()
        }
    }
    
    func styleWithoutDependents() {
        let imageView = createLogoImgView()
        imageView.image = UIImage(named: "dependent-logo")
        manageDependentsButton.isHidden = true
        loginWIthBCSCButton.isHidden = true
        addDependentButton.isHidden = false
        desciptionLabel.isHidden = false
        tableStackLeadingContraint.constant = tableLeadingContraint
    }
    
    func styleAuthenticationExpired() {
        removeEmptyLogo()
        addDependentButton.isHidden = true
        manageDependentsButton.isHidden = true
        loginWIthBCSCButton.isHidden = true
        desciptionLabel.isHidden = true
        tableStackLeadingContraint.constant = 0
    }
    
    func styleUnauthenticated() {
        let imageView = createLogoImgView()
        imageView.image = UIImage(named: "dependent-logged-out")
        addDependentButton.isHidden = true
        manageDependentsButton.isHidden = true
        loginWIthBCSCButton.isHidden = false
        desciptionLabel.isHidden = false
        tableStackLeadingContraint.constant = tableLeadingContraint
    }
    
    private func styleWithDependents() {
        removeEmptyLogo()
        addDependentButton.isHidden = false
        manageDependentsButton.isHidden = false
        loginWIthBCSCButton.isHidden = true
        desciptionLabel.isHidden = false
        tableStackLeadingContraint.constant = tableLeadingContraint
    }
}

// MARK: Navigation setup
extension DependentsHomeViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .dependents,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}


// MARK: Tableview
extension DependentsHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.register(UINib.init(nibName: DependentListItemTableViewCell.getName, bundle: .main), forCellReuseIdentifier: DependentListItemTableViewCell.getName)
        tableView.register(UINib.init(nibName: HiddenRecordsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HiddenRecordsTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch authManager.authStaus {
        case .Authenticated:
            return dependents.count
        case .AuthenticationExpired:
            return 1
        case .UnAuthenticated:
            return 0
        }
    }
    
    private func dependentCell(indexPath: IndexPath) -> DependentListItemTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DependentListItemTableViewCell.getName, for: indexPath) as? DependentListItemTableViewCell else {
            return DependentListItemTableViewCell()
        }
        cell.configure(name: dependents[indexPath.row].info?.name ?? "")
        return cell
    }
    
    private func loginExpiredCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HiddenRecordsTableViewCell.getName, for: indexPath) as? HiddenRecordsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(forRecordType: .loginToAccessDependents) { [weak self] _ in
            self?.authenticate(initialView: .Auth, fromTab: .dependant)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch authManager.authStaus {
        case .Authenticated:
            return dependentCell(indexPath: indexPath)
        case .AuthenticationExpired:
            return loginExpiredCell(indexPath: indexPath)
        case .UnAuthenticated:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dependent = dependents[indexPath.row]
        // if not fetched this session, then call code below. else, fetch health records from storage
        guard let dependentPatient = dependent.info else {
            print("ERROR HERE")
            // TODO: Handle error here
            return
        }
        if AppDelegate.sharedInstance?.recordsFetchedForDependentsThisSession.contains(dependentPatient) == true {
            let records = StorageService.shared.getHealthRecords(forDependent: dependentPatient)
            let dependantDS = records.detailDataSource(patient: dependentPatient)
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: dependentPatient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true, dependantDS: dependantDS)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            StorageService.shared.deleteHealthRecordsForDependent(dependent: dependentPatient)
            HealthRecordsService(network: AFNetwork(), authManager: AuthManager()).fetchAndStoreHealthRecords(for: dependent) { [weak self] records in
                let dependantDS = records.detailDataSource(patient: dependentPatient)
                AppDelegate.sharedInstance?.recordsFetchedForDependentsThisSession.append(dependentPatient)
                let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: dependentPatient, authenticated: true, navStyle: .singleUser, hasUpdatedUnauthPendingTest: true, dependantDS: dependantDS)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
}

// MARK: Auth
extension DependentsHomeViewController {
    private func authenticate(initialView: AuthenticationViewController.InitialView, fromTab: TabBarVCs) {
        self.showLogin(initialView: initialView, sourceVC: .Dependents, presentingViewControllerReference: self) { _ in
        }
    }
}
