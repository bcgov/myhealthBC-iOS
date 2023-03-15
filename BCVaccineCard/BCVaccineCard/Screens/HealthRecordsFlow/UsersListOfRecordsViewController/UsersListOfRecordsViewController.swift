//
//  UsersListOfRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This will be a table view controller with editable cells (for deleting) - nav bar will have same edit/done functionality that covid 19 view controller has

import UIKit

class UsersListOfRecordsViewController: BaseViewController {
    
    // patient.dependencyInfo != nil == dependent
    // TODO: Replace params with Patient after storage refactor
    class func construct(viewModel: ViewModel) -> UsersListOfRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: UsersListOfRecordsViewController.self)) as? UsersListOfRecordsViewController {
            vc.viewModel = viewModel
            return vc
        }
        return UsersListOfRecordsViewController()
    }
    
    @IBOutlet weak private var noRecordsFoundView: UIView!
    @IBOutlet weak private var noRecordsFoundTitle: UILabel!
    @IBOutlet weak private var noRecordsFoundSubTitle: UILabel!
    
    @IBOutlet weak private var clearFiltersButton: UIButton!
    @IBOutlet weak private var filterStack: UIStackView!
    @IBOutlet weak private var filterContainer: UIView!
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var parentContainerStackView: UIStackView!
    
    private var refreshDebounceTimer: Timer? = nil
    
    private var viewModel: ViewModel?
    
    private var dataSource: [HealthRecordsDetailDataSource] = []
    private var hiddenRecords: [HealthRecordsDetailDataSource] = []
    private var hiddenCellType: HiddenRecordType? {
        didSet {
            print(hiddenCellType)
        }
    }
    
    private var protectiveWord: String?
    private var patientRecordsTemp: [HealthRecordsDetailDataSource]? // Note: This is used to temporarily store patient records when authenticating with local protective word
    private var selectedCellIndexPath: IndexPath?
    
    private var isDependent: Bool {
        return viewModel?.patient?.isDependent() ?? false
    }
    
    private var currentFilter: RecordsFilter? = nil {
        didSet {
            if let current = currentFilter, current.exists {
                showSelectedFilters()
                if let patient = viewModel?.patient, let patientName = patient.name {
                    UserFilters.save(filter: current, for: patientName)
                }
            } else {
                hideSelectedFilters()
                if let patient = viewModel?.patient, let patientName = patient.name {
                    UserFilters.removeFilterFor(name: patientName)
                }
            }
        }
    }
    
    private var inEditMode = false {
        didSet {
            self.tableView.setEditing(inEditMode, animated: false)
            self.tableView.reloadData()
            navSetup(style: viewModel?.navStyle ?? .singleUser, authenticated: viewModel?.authenticated ?? false)
            self.tableView.layoutSubviews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setObservables()
        if let patient = viewModel?.patient, let patientName = patient.name, let existingFilter = UserFilters.filterFor(name: patientName) {
            currentFilter = existingFilter
        }
        // When authentication is expired, reset filters
        Notification.Name.refreshTokenExpired.onPost(object: nil, queue: .main) {[weak self] _ in
            guard let `self` = self else {return}
            self.currentFilter = nil
            self.hideSelectedFilters()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setObservables() {
        NotificationCenter.default.addObserver(self, selector: #selector(protectedWordProvided), name: .protectedWordProvided, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(patientAPIFetched), name: .patientAPIFetched, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authFetchComplete), name: .authFetchComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(protectedWordFailedPromptAgain), name: .protectedWordFailedPromptAgain, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storageChangeEvent), name: .storageChangeEvent, object: nil)
        
        NotificationManager.listenToLoginDataClearedOnLoginRejection(observer: self, selector: #selector(reloadFromForcedLogout))
    }
    
    private func setup() {
//        self.getTabBarController?.scrapeDBForEdgeCaseRecords(authManager: AuthManager(), currentTab: .records)
        self.parentContainerStackView.endLoadingIndicator()
        let showLoadingTitle = (viewModel?.patient == nil && viewModel?.authenticated == true)
        updatePatientIfNecessary()
        navSetup(style: viewModel?.navStyle ?? .singleUser, authenticated: viewModel?.authenticated ?? false)
        showSelectedFilters()
        noRecordsFoundSubTitle.font = UIFont.bcSansRegularWithSize(size: 13)
        noRecordsFoundTitle.font = UIFont.bcSansBoldWithSize(size: 20)
        noRecordsFoundTitle.textColor = AppColours.appBlue
        noRecordsFoundSubTitle.textColor = AppColours.textGray
        noRecordsFoundView.isHidden = true
        fetchDataSource()
    }
    
    private func updatePatientIfNecessary() {
        if viewModel?.patient == nil {
            viewModel?.patient = StorageService.shared.fetchAuthenticatedPatient()
        }
    }
    
    @IBAction func removeFilters(_ sender: Any) {
        currentFilter = nil
        hideSelectedFilters()
        let patientRecords = fetchPatientRecords()
        show(records: patientRecords)
    }
}

// MARK: For reloading data on logout hack
extension UsersListOfRecordsViewController {
    @objc private func reloadFromForcedLogout(_ notification: Notification) {
        setup()
    }
}

// MARK: Navigation setup
extension UsersListOfRecordsViewController {
    private func navSetup(style: NavStyle, authenticated: Bool, defaultFirstNameIfFailure: String? = nil, defaultFullNameIfFailure: String? = nil) {
        var buttons: [NavButton] = []
        if authenticated {
            let filterButton = NavButton(title: nil,
                                         image: UIImage(named: "filter"), action: #selector(self.showFilters),
                                         accessibility: Accessibility(traits: .button, label: "", hint: "")) // TODO:
            buttons.append(filterButton)
        } else {
            var editModeNavButton: NavButton
            if inEditMode {
                editModeNavButton = NavButton(title: .done,
                                              image: nil, action: #selector(self.doneButton),
                                              accessibility: Accessibility(traits: .button, label: AccessibilityLabels.ListOfHealthRecordsScreen.navRightDoneIconTitle, hint: AccessibilityLabels.ListOfHealthRecordsScreen.navRightDoneIconHint))
            } else {
                editModeNavButton = NavButton(title: nil,
                                              image: UIImage(named: "edit-icon"), action: #selector(self.editButton),
                                              accessibility: Accessibility(traits: .button, label: AccessibilityLabels.ListOfHealthRecordsScreen.navRightEditIconTitle, hint: AccessibilityLabels.ListOfHealthRecordsScreen.navRightEditIconHint))
            }
            buttons.append(editModeNavButton)
        }
        
        if style == .singleUser && viewModel?.patient?.dependencyInfo == nil {
            self.navigationItem.setHidesBackButton(true, animated: false)
            let settingsButton = NavButton(title: nil,
                                           image: UIImage(named: "nav-settings"), action: #selector(self.showSettings),
                                           accessibility: Accessibility(traits: .button, label: "", hint: "")) // TODO:
            buttons.append(settingsButton)
        } else {
            self.navigationItem.setHidesBackButton(false, animated: false)
            
            let dependentSettingButton = NavButton(image: UIImage(named: "profile-icon"), action: #selector(self.dependentSetting), accessibility: Accessibility(traits: .button, label: "", hint: ""))
            buttons.append(dependentSettingButton)
        }
        
        
        var name = viewModel?.patient?.name?.nameCase() ?? defaultFullNameIfFailure?.nameCase() ?? ""
        if name.count >= 20 {
            name = viewModel?.patient?.name?.firstName?.nameCase() ?? defaultFirstNameIfFailure?.nameCase() ?? ""
            if name.count >= 20 {
                name = String(name.prefix(20))
            }
        }
        let showLoadingTitle = (viewModel?.patient == nil && viewModel?.authenticated == true)
        if showLoadingTitle {
            name = "Fetching User"
        }
        self.navDelegate?.setNavigationBarWith(title: name,
                                               leftNavButton: nil,
                                               rightNavButtons: buttons,
                                               navStyle: .small,
                                               navTitleSmallAlignment: style == .singleUser && viewModel?.patient?.dependencyInfo == nil ? .Left : .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    @objc func showSettings() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        goToSettingsScreen()
    }
    
    private func goToSettingsScreen() {
        show(route: .Settings, withNavigation: true)
    }
    
    @objc func dependentSetting() {
        guard let dependent = viewModel?.patient?.dependencyInfo else {
            return
        }
        let vm = DependentInfoViewController.ViewModel(dependent: dependent)
        show(route: .DependentInfo, withNavigation: true, viewModel: vm)
    }
    
    @objc private func doneButton() {
        inEditMode = false
    }
    
    @objc private func editButton() {
        tableView.isEditing = false
        inEditMode = true
    }
}

// MARK: Filters
extension UsersListOfRecordsViewController: FilterRecordsViewDelegate {
    
    @objc func showFilters() {
        let fv: FilterRecordsView = UIView.fromNib()
        let allFilters = RecordsFilter.RecordType.avaiableFilters
        let dependentFilters: [RecordsFilter.RecordType] = RecordsFilter.RecordType.dependentFilters
        fv.showModally(on: view.findTopMostVC()?.view ?? view,
                       availableFilters: isDependent ? dependentFilters : allFilters,
                       filter: currentFilter)
        fv.delegate = self
    }
    
    func selected(filter: RecordsFilter) {
        let patientRecords = fetchPatientRecords()
        currentFilter = filter
        show(records: patientRecords, filter:filter)
    }
    
    func showSelectedFilters() {
        clearFiltersButton.setImage(UIImage(named: "close-circle"), for: .normal)
        guard let current = currentFilter, current.exists else {
            hideSelectedFilters()
            return
        }
        
        let chipsView: ChipsView = UIView.fromNib()
        filterContainer.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        filterStack.isHidden = false
        filterContainer.addSubview(chipsView)
        chipsView.addEqualSizeContraints(to: filterContainer)
        var selectedFilters: [String] = []
        
        
        var fromDateText = ""
        if let startDate = current.fromDate {
            fromDateText = startDate.issuedOnDate
        }
        
        var toDateText = ""
        if let endDate = current.toDate {
            toDateText = endDate.issuedOnDate
        }
        
        var dateFilter = ""
        if current.fromDate != nil || current.toDate != nil {
            if current.fromDate != nil && current.toDate != nil {
                dateFilter = "\(fromDateText) - \(toDateText)"
            } else if current.fromDate == nil && current.toDate != nil {
                dateFilter = "\(toDateText) and before"
            } else if current.fromDate != nil && current.toDate == nil {
                dateFilter = "\(fromDateText) and after"
            }
            
            selectedFilters.append(dateFilter)
        }
        
        selectedFilters += current.recordTypes.map({$0.rawValue})
        
        chipsView.setup(options: selectedFilters, selected: [], direction: .horizontal, selectable: false)
    }
    
    func hideSelectedFilters() {
        filterContainer.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        filterStack.isHidden = true
    }
}

// MARK: Data Source Setup
extension UsersListOfRecordsViewController {
    
    private func fetchDataSource(initialProtectedMedFetch: Bool = false) {
        guard self.dataSource.count == 0 else {
            show(records: self.dataSource, filter: currentFilter, initialProtectedMedFetch: initialProtectedMedFetch)
            return
        }
        let patientRecords = fetchPatientRecords()
        show(records: patientRecords, filter: currentFilter, initialProtectedMedFetch: initialProtectedMedFetch)
    }
    
    private func fetchPatientRecords() -> [HealthRecordsDetailDataSource] {
        guard let patient = viewModel?.patient else {return []}
        let records = StorageService.shared.getRecords(for: patient)
        let patientRecords = records.detailDataSource(patient: patient)
        return patientRecords
    }
    
    private func show(records: [HealthRecordsDetailDataSource], filter: RecordsFilter? = nil, initialProtectedMedFetch: Bool = false) {
        var patientRecords: [HealthRecordsDetailDataSource] = records
        if let filter = filter {
            patientRecords = patientRecords.filter({ item in
                var showItem = true
                // Filter by type
                if !filter.recordTypes.isEmpty {
                    switch item.type {
                    case .covidImmunizationRecord:
                        showItem = filter.recordTypes.contains(.Immunizations)
                    case .covidTestResultRecord:
                        showItem = filter.recordTypes.contains(.Covid)
                    case .medication:
                        showItem = filter.recordTypes.contains(.Medication)
                    case .laboratoryOrder:
                        showItem = filter.recordTypes.contains(.LabTests)
                    case .immunization:
                        showItem = filter.recordTypes.contains(.Immunizations)
                    case .healthVisit:
                        showItem = filter.recordTypes.contains(.HeathVisits)
                    case .specialAuthorityDrug:
                        showItem = filter.recordTypes.contains(.SpecialAuthorityDrugs)
                    case .hospitalVisit:
                        showItem = filter.recordTypes.contains(.HospitalVisits)
                    case .clinicalDocument:
                        showItem = filter.recordTypes.contains(.ClinicalDocuments)
                    }
                }
                // Filter by date
                if let dateString = item.mainRecord?.date,
                   let recordDate = Date.Formatter.monthDayYearDate.date(from: dateString),
                   let timeNeutralDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: recordDate)
                {
                    if let fromDate = filter.fromDate, timeNeutralDate < fromDate {
                        showItem = false
                    }
                    if let toDate = filter.toDate, timeNeutralDate > toDate {
                        showItem = false
                    }
                    
                }
                
                return showItem
            })
            tableView.reloadData()
        }
        
        if AuthManager().isAuthenticated {
            handleAuthenticatedMedicalRecords(patientRecords: patientRecords, initialProtectedMedFetch: initialProtectedMedFetch)
        } else {
            let unauthenticatedRecords = patientRecords.filter({!$0.isAuthenticated})
            let authenticatedRecords = patientRecords.filter({$0.isAuthenticated})
            self.dataSource = unauthenticatedRecords
            self.hiddenRecords = authenticatedRecords
            self.hiddenCellType = .loginToAccesshealthRecords(hiddenRecords: hiddenRecords.count)
        }
        self.setupTableView()
        self.navSetup(style: viewModel?.navStyle ?? .singleUser, authenticated: viewModel?.authenticated ?? false)
        
        // Note: Reloading data here as the table view doesn't seem to reload properly after deleting a record from the detail screen
        self.tableView.reloadData()
        //        self.checkForTestResultsToUpdate(ds: self.dataSource)
        
        if patientRecords.isEmpty {
            noRecordsFoundView.isHidden = false
            tableView.isHidden = true
        } else {
            noRecordsFoundView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    private func handleAuthenticatedMedicalRecords(patientRecords: [HealthRecordsDetailDataSource], initialProtectedMedFetch: Bool) {
        // Note: Assumption is, if protective word is not stored in keychain at this point, then user does not have protective word enabled
        self.patientRecordsTemp = patientRecords
        guard !initialProtectedMedFetch else {
            showAllRecords(patientRecords: patientRecords, medFetchRequired: false)
            return
        }
        guard let protectiveWord = AuthManager().protectiveWord,
              !SessionStorage.protectiveWordEnteredThisSession
        else {
            showAllRecords(patientRecords: patientRecords, medFetchRequired: AuthManager().medicalFetchRequired && !isDependent)
            return
        }
        self.protectiveWord = protectiveWord
        let visibleRecords = patientRecords.filter({!$0.containsProtectedWord})
        self.dataSource = visibleRecords
        if !isDependent {
            let hiddenRecords = patientRecords.filter({$0.containsProtectedWord})
            self.hiddenRecords = hiddenRecords
            
            if hiddenRecords.count > 0 {
                self.hiddenCellType = .medicalRecords
            }
        }
        
    }
    
    private func showAllRecords(patientRecords: [HealthRecordsDetailDataSource], medFetchRequired: Bool) {
        self.dataSource = patientRecords
        self.hiddenRecords.removeAll()
        self.hiddenCellType = medFetchRequired ? .medicalRecords : nil
        self.patientRecordsTemp = nil
        tableView.reloadData()
    }
    
    private func promptProtectiveVC(medFetchRequired: Bool) {
        let value = medFetchRequired ? ProtectiveWordPurpose.initialFetch.rawValue : ProtectiveWordPurpose.viewingRecords.rawValue
        let userInfo: [String: String] = [
            ProtectiveWordPurpose.purposeKey: value,
        ]
        NotificationCenter.default.post(name: .protectedWordRequired, object: nil, userInfo: userInfo)
    }
    
    // NOTE: No special routing required here on login, as the user should remain on the same screen
    private func performBCSCLogin() {
        // TODO: ROUTE REFACTOR - CHECK
        showLogin(initialView: .Auth) { _ in }
        
//        let vm = AuthenticationViewController.ViewModel(initialView: .Auth)
//        self.showLogin(viewModel: vm) { [weak self] authenticationStatus in
//            guard let `self` = self, authenticationStatus == .Completed else {return}
//            print("sync?")
//        }
        
//        self.throttleAPIWorker?.throttleHGMobileConfigEndpoint(completion: { response in
//            guard response == .Online else {return}
//            self.showLogin(initialView: .Auth, sourceVC: .UserListOfRecordsVC) { [weak self] authenticationStatus in
//                guard let `self` = self, authenticationStatus == .Completed else {return}
//                print("sync?")
                // TODO: Check this
//                if let authStatus = Defaults.loginProcessStatus,
//                   authStatus.hasCompletedLoginProcess == true,
//                   let storedName = authStatus.loggedInUserAuthManagerDisplayName,
//                   let currentAuthPatient = StorageService.shared.fetchAuthenticatedPatient(),
//                   let currentName = currentAuthPatient.authManagerDisplayName,
//                   storedName != currentName {
//                    StorageService.shared.deleteHealthRecordsForAuthenticatedUser()
//                    StorageService.shared.deleteAuthenticatedPatient(with: storedName)
//                    AuthManager().clearMedFetchProtectiveWordDetails()
//                    //                self.patient = nil
//                    if self.navStyle == .multiUser {
//                        //                    self.navSetup(style: self.navStyle, authenticated: self.authenticated, showLoadingTitle: true)
//                        //                    self.tableView.startLoadingIndicator()
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                } else {
//                    self.fetchDataSource()
//                }
//            }
//        })
    }
    
    @objc private func patientAPIFetched(_ notification: Notification) {
        let userInfo = notification.userInfo as? [String: String]
        let firstName = userInfo?["firstName"]
        let fullName = userInfo?["fullName"]
        guard viewModel?.patient == nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.viewModel?.patient = StorageService.shared.fetchAuthenticatedPatient()
            self?.navSetup(style: self?.viewModel?.navStyle ?? .singleUser, authenticated: self?.viewModel?.authenticated ??  false, defaultFirstNameIfFailure: firstName, defaultFullNameIfFailure: fullName)
        }
    }
}

// MARK: TableView setup
extension UsersListOfRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: UserRecordListTableViewCell.getName, bundle: .main), forCellReuseIdentifier: UserRecordListTableViewCell.getName)
        tableView.register(UINib.init(nibName: HiddenRecordsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HiddenRecordsTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.hiddenCellType == .medicalRecords || !hiddenRecords.isEmpty) ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!hiddenRecords.isEmpty || self.hiddenCellType == .medicalRecords) && section == 0 {
            return 1
        }
        return dataSource.count
    }
    
    private func recordCell(indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: UserRecordListTableViewCell.getName, for: indexPath) as? UserRecordListTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(record: dataSource[indexPath.row])
        return cell
    }
    
    private func hiddenRecordsCell(indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: HiddenRecordsTableViewCell.getName, for: indexPath) as? HiddenRecordsTableViewCell else {
            return UITableViewCell()
        }
        // TODO: Configure fetch type elsewhere (when data source is being sorted) and pass in here
        guard let hiddenType = self.hiddenCellType else { return cell }
        cell.configure(forRecordType: hiddenType) { [weak self] hiddenType in
            guard let `self` = self else { return }
            guard let type = hiddenType else { return }
            switch type {
            case .loginToAccesshealthRecords:
                self.performBCSCLogin()
            case .medicalRecords:
                if AuthManager().medicalFetchRequired {
                    self.selectedCellIndexPath = indexPath
                }
                self.promptProtectiveVC(medFetchRequired: AuthManager().medicalFetchRequired)
            case .authenticate:
                break
            case .loginToAccessDependents:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!hiddenRecords.isEmpty || self.hiddenCellType == .medicalRecords) && indexPath.section == 0 {
            return hiddenRecordsCell(indexPath: indexPath)
        } else {
            return recordCell(indexPath: indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !hiddenRecords.isEmpty && indexPath.section == 0 { return }
        if self.hiddenCellType == .medicalRecords && indexPath.section == 0 { return }
        guard dataSource.count > indexPath.row else {return}
        let ds = dataSource[indexPath.row]
        let vm = HealthRecordDetailViewController.ViewModel(dataSource: ds,
                                                            authenticatedRecord: ds.isAuthenticated,
                                                            userNumberHealthRecords: dataSource.count,
                                                            patient: viewModel?.patient)
        show(route: .HealthRecordDetail, withNavigation: true, viewModel: vm)
    }
    
}

// MARK: Protected word retry
extension UsersListOfRecordsViewController {
    @objc private func protectedWordFailedPromptAgain(_ notification: Notification) {
        SessionStorage.attemptingProtectiveWord = false
        alert(title: .error, message: .protectedWordAlertError, buttonOneTitle: .yes, buttonOneCompletion: {
            self.promptProtectiveVC(medFetchRequired: AuthManager().medicalFetchRequired)
            self.adjustLoadingIndicator(show: false, tryingAgain: true)
        }, buttonTwoTitle: .no) {
            // Do nothing
            self.adjustLoadingIndicator(show: false, tryingAgain: false)
        }
    }
    
    @objc private func protectedWordProvided(_ notification: Notification) {
        guard let protectiveWordEntered = notification.userInfo?[Constants.AuthenticatedMedicationStatementParameters.protectiveWord] as? String else { return }
        guard let purposeRaw = notification.userInfo?[ProtectiveWordPurpose.purposeKey] as? String, let purpose = ProtectiveWordPurpose(rawValue: purposeRaw) else { return }
        if purpose == .viewingRecords {
            viewProtectedRecords(protectiveWord: protectiveWordEntered)
        } else if purpose == .initialFetch {
            fetchProtectedRecords(protectiveWord: protectiveWordEntered)
        }
    }
    
    private func viewProtectedRecords(protectiveWord: String) {
        if let proWord = self.protectiveWord,
           protectiveWord == proWord
        {
            let records = self.patientRecordsTemp ?? []
            SessionStorage.protectiveWordEnteredThisSession = true
            self.showAllRecords(patientRecords: records, medFetchRequired: false)
            self.tableView.reloadData()
        } else {
            alert(title: .error, message: .protectedWordAlertError, buttonOneTitle: .yes, buttonOneCompletion: {
                self.promptProtectiveVC(medFetchRequired: false)
            }, buttonTwoTitle: .no) {
                // Do nothing
            }
        }
    }
    
    private func fetchProtectedRecords(protectiveWord: String) {
        guard let patient = viewModel?.patient else {return}
        MedicationService(network: AFNetwork(), authManager: AuthManager(), configService: MobileConfigService(network: AFNetwork())).fetchAndStore(for: patient, protectiveWord: protectiveWord) { records in
            print(records.count)
        }
//        self.throttleAPIWorker?.throttleHGMobileConfigEndpoint(completion: { [weak self] response in
//            guard response == .Online, let patient = self?.patient else {return}
//            self.adjustLoadingIndicator(show: true)
//            SessionStorage.attemptingProtectiveWord = true
//            self.performAuthenticatedRecordsFetch(isManualFetch: false, showBanner: true, specificFetchTypes: [.MedicationStatement, .Comments], protectiveWord: protectiveWord, sourceVC: .UserListOfRecordsVC, initialProtectedMedFetch: true)
           
//        })
    }
}

// MARK: Handling hidden records loading indicator
extension UsersListOfRecordsViewController {
    private func adjustLoadingIndicator(show: Bool, tryingAgain: Bool? = nil) {
        if let indexPath = self.selectedCellIndexPath, let cell = self.tableView.cellForRow(at: indexPath) as? HiddenRecordsTableViewCell {
            if show {
                cell.startLoadingIndicator(backgroundColor: .clear)
            } else {
                cell.endLoadingIndicator()
                if let tryingAgain = tryingAgain, tryingAgain == true {
                    // Don't remove selectedCellIndexPath here
                } else {
                    self.selectedCellIndexPath = nil
                }
            }
        }
    }
}

// MARK: Sync completed, reload data
extension UsersListOfRecordsViewController {
    @objc private func authFetchComplete(_ notification: Notification) {
        adjustLoadingIndicator(show: false)
        self.fetchDataSource(initialProtectedMedFetch: true)
        self.fetchDataSource(initialProtectedMedFetch: true)
    }
    
    @objc private func storageChangeEvent(_ notification: Notification) {
        guard let event = notification.object as? StorageService.StorageEvent<Any> else {return}
        guard event.event == .Save else {return}
        refreshDebounceTimer?.invalidate()
        refreshDebounceTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(refreshOnStorageUpdate), userInfo: nil, repeats: false)
    }
    
    @objc private func refreshOnStorageUpdate() {
        let patientRecords = fetchPatientRecords()
        show(records: patientRecords, filter: currentFilter)
    }
}
