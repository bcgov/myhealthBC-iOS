//
//  DependentsHomeViewController.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-13.
//

import UIKit


class DependentsHomeViewController: BaseDependentViewController {
    
    // TODO: Move to new file
    struct ViewModel {
        let patient: Patient?
    }
    
    class func construct(viewModel: ViewModel) -> DependentsHomeViewController {
        if let vc = Storyboard.dependents.instantiateViewController(withIdentifier: String(describing: DependentsHomeViewController.self)) as? DependentsHomeViewController {
            vc.patient = viewModel.patient
            vc.viewModel = viewModel
            return vc
        }
        return DependentsHomeViewController()
    }
    
    private var viewModel: ViewModel? = nil
    private var patient: Patient? = nil
    private let emptyLogoTag = 23412
    private let authManager = AuthManager()
    private let storageService = StorageService.shared
    
    private var blockDependentSelection: Bool = false
    fileprivate var lastKnowContentOfsset: CGFloat = 0
    fileprivate var hideTitleAfterScroll: Bool = false
    
    @IBOutlet weak var descStack: UIStackView!
    @IBOutlet weak var tableStackLeadingContraint: NSLayoutConstraint!
    @IBOutlet weak var desciptionLabel: UILabel!
    @IBOutlet weak var loginWIthBCSCButton: UIButton!
    @IBOutlet weak var addDependentButton: UIButton!
    @IBOutlet weak var manageDependentsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var dependents: [Dependent] = [] {
        didSet {
            DispatchQueue.main.async {
                if self.dependents.isEmpty {
                    self.styleWithoutDependents()
                } else {
                    self.styleWithDependents()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetup()
        style()
        setupTableView()
        fetchData(fromRemote: false)
        fetchDataWhenAuthenticated()
        fetchDataWhenMainPatientIsStored()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData(fromRemote: false)
    }
    
    // MARK: Actions
    @IBAction func addDependent(_ sender: Any) {
        guard let patient = viewModel?.patient else {
            return
        }
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "This feature requires an internet connection")
            return
        }
        let vm = AddDependentViewController.ViewModel(patient: patient)
        show(route: .AddDependent, withNavigation: true, viewModel: vm)
    }
    
    @IBAction func manageDependents(_ sender: Any) {
        guard let patient = viewModel?.patient else {
            showToast(message: "Please try re-launching this application")
            return
        }
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: "This feature requires an internet connection")
            return
        }
        let vm = ManageDependentsViewController.ViewModel(patient: patient)
        show(route: .ManageDependents, withNavigation: true, viewModel: vm)
    }
    
    @IBAction func LoginWithBCSC(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        authenticate(initialView: .Landing)
    }
    
    // MARK: Data
    private func fetchData(fromRemote: Bool) {
        guard tableView != nil else {return}
        guard let patient = patient, authManager.isAuthenticated else {
            dependents = []
            setState()
            tableView.reloadData()
            return
        }
        
        dependents = patient.dependentsArray
        setState()
        tableView.reloadData()
        guard fromRemote else {return}
        
        networkService.fetchDependents(for: patient) { [weak self] storedDependents in
            guard let storedDependents = storedDependents else {
                self?.setState()
                self?.tableView.reloadData()
                return
            }
            self?.dependents = storedDependents
            self?.setState()
            self?.tableView.reloadData()
        }
    }
    
    // MARK: Listeners
    private func fetchDataWhenAuthenticated() {
        AppStates.shared.listenToAuth { [weak self] authenticated in
            guard let `self` = self else {return}
            if self.patient != nil {
                self.fetchData(fromRemote: false)
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
            if event.event == .Save {
                if event.entity == .Dependent {
                    self.fetchData(fromRemote: false)
                } else if event.entity == .Patient,
                          let storedPatient = event.object as? Patient,
                          storedPatient.authenticated {
                    self.patient = storedPatient
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
    
    private func createLogoImgView(completion: @escaping(UIImageView?)->Void) {
        removeEmptyLogo() { [weak self] in
            guard let self = self else {return completion(nil)}
            let bounds = self.tableView != nil ? self.tableView.bounds : self.view.bounds
            let imgView = UIImageView(frame: bounds)
            imgView.tag = self.emptyLogoTag
            self.view.addSubview(imgView)
            let padding = self.view.bounds.width / 5
            imgView.addEqualSizeContraints(to: self.tableView != nil ? self.tableView : self.view, paddingVertical: padding, paddingHorizontal: padding)
            imgView.contentMode = .scaleAspectFit
            return completion(imgView)
        }
    }
    
    private func removeEmptyLogo(completion: @escaping()->Void) {
        DispatchQueue.main.async {
            guard let imgView = self.view.viewWithTag(self.emptyLogoTag) else {
                return completion()
            }
            imgView.removeFromSuperview()
            return completion()
        }
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
        DispatchQueue.main.async {
            switch self.authManager.authStaus {
            case .Authenticated:
                if self.dependents.isEmpty {
                    self.styleWithoutDependents()
                } else {
                    self.styleWithDependents()
                }
            case .AuthenticationExpired:
                self.styleAuthenticationExpired()
            case .UnAuthenticated:
                self.styleUnauthenticated()
            }
        }
    }
    
    func styleWithoutDependents() {
        createLogoImgView() { imageView in
            guard let imageView = imageView else {return}
            imageView.image = UIImage(named: "dependent-logo")
        }
        
        manageDependentsButton.isHidden = true
        loginWIthBCSCButton.isHidden = true
        addDependentButton.isHidden = false
        desciptionLabel.isHidden = false
    }
    
    func styleAuthenticationExpired() {
        removeEmptyLogo() {}
        addDependentButton.isHidden = true
        manageDependentsButton.isHidden = true
        loginWIthBCSCButton.isHidden = true
        desciptionLabel.isHidden = true
        desciptionLabel.isHidden = true
        desciptionLabel.isHidden = true
        tableStackLeadingContraint.constant = 0
    }
    
    func styleUnauthenticated() {
        createLogoImgView() { imageView in
            guard let imageView = imageView else {return}
            imageView.image = UIImage(named: "dependent-logged-out")
        }
        
        addDependentButton.isHidden = true
        manageDependentsButton.isHidden = true
        loginWIthBCSCButton.isHidden = false
        desciptionLabel.isHidden = false
    }
    
    private func styleWithDependents() {
        removeEmptyLogo() {}
        addDependentButton.isHidden = false
        manageDependentsButton.isHidden = false
        loginWIthBCSCButton.isHidden = true
        desciptionLabel.isHidden = false
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
        tableView.register(UINib.init(nibName: InaccessibleDependentTableViewCell.getName, bundle: .main), forCellReuseIdentifier: InaccessibleDependentTableViewCell.getName)
        tableView.registerEmptyCell()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch authManager.authStaus {
        case .Authenticated:
            return 2 // over 12 years of age and regular
        case .AuthenticationExpired:
            return 1
        case .UnAuthenticated:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch authManager.authStaus {
        case .Authenticated:
            
            switch section {
            case 0:
                return dependents.over12.count
            case 1:
                return dependents.under12.count
            default:
                return 0
            }
            
        case .AuthenticationExpired:
            return 1
        case .UnAuthenticated:
            return 0
        }
    }
    
    private func dependentCell(indexPath: IndexPath) -> UITableViewCell {
        guard dependents.under12.indices.contains(indexPath.row) else {
            return tableView.getEmptyCell(indexPath: indexPath)
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DependentListItemTableViewCell.getName, for: indexPath) as? DependentListItemTableViewCell else {
            return DependentListItemTableViewCell()
        }
        cell.configure(name: dependents.under12[indexPath.row].info?.name ?? "")
        cell.selectionStyle = .none
        return cell
    }
    
    private func inaccessibleDependentCell(indexPath: IndexPath) -> UITableViewCell {
        guard dependents.over12.indices.contains(indexPath.row) else {
            return tableView.getEmptyCell(indexPath: indexPath)
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InaccessibleDependentTableViewCell.getName, for: indexPath) as? InaccessibleDependentTableViewCell else {
            return InaccessibleDependentTableViewCell()
        }
        cell.configure(dependent: dependents.over12[indexPath.row], delegate: self)
        cell.selectionStyle = .none
        return cell
    }
    
    private func loginExpiredCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HiddenRecordsTableViewCell.getName, for: indexPath) as? HiddenRecordsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(forRecordType: .loginToAccessDependents) { [weak self] _ in
            self?.authenticate(initialView: .Auth)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch authManager.authStaus {
        case .Authenticated:
            switch indexPath.section {
            case 0:
                return inaccessibleDependentCell(indexPath: indexPath)
            case 1:
                return dependentCell(indexPath: indexPath)
            default:
                return UITableViewCell()
            }
            
        case .AuthenticationExpired:
            return loginExpiredCell(indexPath: indexPath)
        case .UnAuthenticated:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {return}
        guard dependents.under12.indices.contains(indexPath.row) else {
            return
        }
        let dependent = dependents.under12[indexPath.row]
        guard let dependentPatient = dependent.info, !blockDependentSelection else {
            return
        }
        
        if SessionStorage.dependentRecordsFetched.contains(dependentPatient) {
            showDetails(for: dependentPatient)
            blockDependentSelection = false
        } else {
            selected(dependent: dependent, dependentPatient: dependentPatient)
        }
    }
    
    private func selected(dependent: Dependent, dependentPatient: Patient) {
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: .noInternetConnection, style: .Warn)
            return
        }
        
        HealthRecordsService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork())).fetchAndStore(for: dependent) { [weak self] records, hadFails in
            let message: String = !hadFails ? "Records retrieved" : "Not all records were fetched successfully"
            self?.showToast(message: message)
            SessionStorage.dependentRecordsFetched.append(dependentPatient)
            self?.showDetails(for: dependentPatient)
            self?.blockDependentSelection = false
        }
    }
    
    private func showDetails(for dependent: Patient) {
        let vm = UsersListOfRecordsViewController.ViewModel(patient: dependent, authenticated: dependent.authenticated)
        show(route: .UsersListOfRecords, withNavigation: true, viewModel: vm)
    }
}

extension DependentsHomeViewController: UIScrollViewDelegate {
    func showTitle() {
        
        UIView.animate(withDuration: 0.3) {
            self.descStack.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func hideTitle() {
        UIView.animate(withDuration: 0.3) {
            self.descStack.isHidden = true
            self.view.layoutIfNeeded()
        }
        
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            let contentOffset = scrollView.contentOffset.y
            
            let change = lastKnowContentOfsset - contentOffset
            if contentOffset == 0 {
                hideTitleAfterScroll = false
            } else if change > 0.0 {
                hideTitleAfterScroll = false
            } else if change < 0.0 {
                hideTitleAfterScroll = true
            }
            lastKnowContentOfsset = contentOffset
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        showTitle()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if hideTitleAfterScroll {
            hideTitle()
        } else {
            showTitle()
        }
    }
}
extension DependentsHomeViewController: InaccessibleDependentDelegate {
    func delete(dependent: Dependent) {
        delete(dependent: dependent) { [weak self] confirmed in
            if confirmed {
                self?.fetchData(fromRemote: false)
            }
        }
    }
}

// MARK: Auth
extension DependentsHomeViewController {
    private func authenticate(initialView: AuthenticationViewController.InitialView) {
        showLogin(initialView: initialView, showTabOnSuccess: .Dependents) { [weak self] status in
            self?.setState()
        }
    }
}
