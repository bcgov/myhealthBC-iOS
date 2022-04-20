//
//  UsersListOfRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This will be a table view controller with editable cells (for deleting) - nav bar will have same edit/done functionality that covid 19 view controller has

import UIKit
import SwipeCellKit

class UsersListOfRecordsViewController: BaseViewController {
    
    enum NavStyle {
        case singleUser
        case multiUser
    }
    
    // TODO: Replace params with Patient after storage refactor
    class func constructUsersListOfRecordsViewController(patient: Patient, authenticated: Bool, navStyle: NavStyle, hasUpdatedUnauthPendingTest: Bool) -> UsersListOfRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: UsersListOfRecordsViewController.self)) as? UsersListOfRecordsViewController {
            vc.patient = patient
            vc.authenticated = authenticated
            vc.navStyle = navStyle
            vc.hasUpdatedUnauthPendingTest = hasUpdatedUnauthPendingTest
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
    
    private var patient: Patient?
    private var authenticated: Bool = true
    private var navStyle: NavStyle = .multiUser
    private var hasUpdatedUnauthPendingTest = true
    
    private var backgroundWorker: BackgroundTestResultUpdateAPIWorker?
    
    private var dataSource: [HealthRecordsDetailDataSource] = []
    private var hiddenRecords: [HealthRecordsDetailDataSource] = []
    private var hiddenCellType: HiddenRecordType?
    
    fileprivate let authManager = AuthManager()
    private var protectiveWord: String?
    private var patientRecordsTemp: [HealthRecordsDetailDataSource]? // Note: This is used to temporarily store patient records when authenticating with local protective word
    private var selectedCellIndexPath: IndexPath?
    
    private var currentFilter: RecordsFilter? = nil {
        didSet {
            if let current = currentFilter, current.exists {
                showSelectedFilters()
            } else {
                hideSelectedFilters()
            }
        }
    }
    
    private var inEditMode = false {
        didSet {
            self.tableView.setEditing(inEditMode, animated: false)
            self.tableView.reloadData()
            navSetup(style: navStyle, authenticated: self.authenticated)
            self.tableView.layoutSubviews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservables()
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setObservables() {
        NotificationCenter.default.addObserver(self, selector: #selector(protectedWordProvided), name: .protectedWordProvided, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(patientAPIFetched), name: .patientAPIFetched, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authFetchComplete), name: .authFetchComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(protectedWordFailedPromptAgain), name: .protectedWordFailedPromptAgain, object: nil)
        NotificationManager.listenToLoginDataClearedOnLoginRejection(observer: self, selector: #selector(reloadFromForcedLogout))
    }
    
    private func setup() {
        navSetup(style: navStyle, authenticated: self.authenticated)
        self.backgroundWorker = BackgroundTestResultUpdateAPIWorker(delegateOwner: self)
        fetchDataSource()
        showSelectedFilters()
        noRecordsFoundSubTitle.font = UIFont.bcSansRegularWithSize(size: 13)
        noRecordsFoundTitle.font = UIFont.bcSansBoldWithSize(size: 20)
        noRecordsFoundTitle.textColor = AppColours.appBlue
        noRecordsFoundSubTitle.textColor = AppColours.textGray
        noRecordsFoundView.isHidden = true
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
    private func navSetup(style: NavStyle, authenticated: Bool, showLoadingTitle: Bool = false, defaultFirstNameIfFailure: String? = nil, defaultFullNameIfFailure: String? = nil) {
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
        
        if style == .singleUser {
            self.navigationItem.setHidesBackButton(true, animated: false)
            let addButton = NavButton(title: nil,
                      image: UIImage(named: "add-circle-btn"), action: #selector(self.showAddRecord),
                                      accessibility: Accessibility(traits: .button, label: "", hint: "")) // TODO:
            buttons.append(addButton)
            let settingsButton = NavButton(title: nil,
                      image: UIImage(named: "nav-settings"), action: #selector(self.showSettings),
                                           accessibility: Accessibility(traits: .button, label: "", hint: "")) // TODO:
            buttons.append(settingsButton)
        } else {
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
        var name = self.patient?.name?.nameCase() ?? defaultFullNameIfFailure?.nameCase() ?? ""
        if name.count >= 20 {
            name = self.patient?.name?.firstName?.nameCase() ?? defaultFirstNameIfFailure?.nameCase() ?? ""
        }
        if showLoadingTitle {
            name = "Fetching User"
        }
        self.navDelegate?.setNavigationBarWith(title: name,
                                               leftNavButton: nil,
                                               rightNavButtons: buttons,
                                               navStyle: .small,
                                               navTitleSmallAlignment: style == .singleUser ? .Left : .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    // This screen has to have health records by rule (with the exception being a screen state issue, but that is a separate bug)
    @objc func showAddRecord() {
        let vc = FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: false, showSettingsIcon: false, hasHealthRecords: true, completion: {[weak self] in
            // Note: Not sure what the purpose of this is?? - was only causing an issue with routing
//            self?.navigationController?.popToRootViewController(animated: true)
        })
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showSettings() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        goToSettingsScreen()
    }
    
    private func goToSettingsScreen() {
        let vc = ProfileAndSettingsViewController.constructProfileAndSettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
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
        fv.showModally(on: view.findTopMostVC()?.view ?? view, filter: currentFilter)
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
        let patientRecords = fetchPatientRecords()
        show(records: patientRecords, filter: currentFilter, initialProtectedMedFetch: initialProtectedMedFetch)
        if !authenticated && hasUpdatedUnauthPendingTest {
            // Don't check for test result to update again here, as this was causing an infinite loop
            // TODO: We should really refactor the way screens are being updated due to storage updates, as it will cause issues in the future with edge cases, causing us to create numerous hot-fixes such as this, resulting in messy and hard to maintain code
        } else {
            self.checkForTestResultsToUpdate(ds: self.dataSource)
        }
    }
    
    private func fetchPatientRecords() -> [HealthRecordsDetailDataSource] {
        guard let patient = self.patient else {return []}
        let records = StorageService.shared.getHeathRecords()
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
                        showItem = filter.recordTypes.contains(.CovidImmunization)
                    case .covidTestResultRecord:
                        showItem = filter.recordTypes.contains(.Covid)
                    case .medication:
                        showItem = filter.recordTypes.contains(.Medication)
                    case .laboratoryOrder:
                        showItem = filter.recordTypes.contains(.LabTests)
                    }
                }
                // Filter by date
                if let dateString = item.mainRecord?.date,
                   let recordDate = Date.Formatter.monthDayYearDate.date(from: dateString)
                {
                    if let fromDate = filter.fromDate, recordDate < fromDate {
                        showItem = false
                    }
                    if let toDate = filter.toDate, recordDate > toDate {
                        showItem = false
                    }
                    
                }
                
                return showItem
            })
        }
        
        self.view.startLoadingIndicator(backgroundColor: .clear)
        
        if AuthManager().isAuthenticated {
            handleAuthenticatedMedicalRecords(patientRecords: patientRecords, initialProtectedMedFetch: initialProtectedMedFetch)
        } else {
            let unauthenticatedRecords = patientRecords.filter({!$0.isAuthenticated})
            let authenticatedRecords = patientRecords.filter({$0.isAuthenticated})
            self.dataSource = unauthenticatedRecords
            self.hiddenRecords = authenticatedRecords
            self.hiddenCellType = .loginToAccess(hiddenRecords: hiddenRecords.count)
        }
        self.setupTableView()
        self.navSetup(style: navStyle, authenticated: self.authenticated)
        
        self.view.endLoadingIndicator()
        
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
        guard let protectiveWord = authManager.protectiveWord, AppDelegate.sharedInstance?.protectiveWordEnteredThisSession == false else {
            showAllRecords(patientRecords: patientRecords, medFetchRequired: authManager.medicalFetchRequired)
            return
        }
        self.protectiveWord = protectiveWord
        let visibleRecords = patientRecords.filter({!$0.containsProtectedWord})
        let hiddenRecords = patientRecords.filter({$0.containsProtectedWord})
        self.dataSource = visibleRecords
        self.hiddenRecords = hiddenRecords
        if hiddenRecords.count > 0 {
            self.hiddenCellType = .medicalRecords
        }
    }
    
    private func showAllRecords(patientRecords: [HealthRecordsDetailDataSource], medFetchRequired: Bool) {
        self.dataSource = patientRecords
        self.hiddenRecords.removeAll()
        self.hiddenCellType = medFetchRequired ? .medicalRecords : nil
        self.patientRecordsTemp = nil
    }
    
    private func promptProtectiveVC(medFetchRequired: Bool) {
        let value = medFetchRequired ? ProtectiveWordPurpose.initialFetch.rawValue : ProtectiveWordPurpose.viewingRecords.rawValue
        let userInfo: [String: String] = [
            ProtectiveWordPurpose.purposeKey: value,
        ]
        NotificationCenter.default.post(name: .protectedWordRequired, object: nil, userInfo: userInfo)
    }
    
    private func checkForTestResultsToUpdate(ds: [HealthRecordsDetailDataSource]) {
        for (indexPathRow, record) in ds.enumerated() {
            switch record.type {
            case .covidTestResultRecord(model: let model):
                let listOfStatuses = record.records.map { ($0.status, $0.date) }
                for (index, data) in listOfStatuses.enumerated() {
                    if data.0 == CovidTestResult.pending.rawValue {
                        
                        guard
                            let patient = model.patient,
                            let dateOfBirth = patient.birthday?.yearMonthDayString,
                            let phn = patient.phn,
                            let collectionDatePresentableFormat = listOfStatuses[index].1,
                            let collectionDate = Date.Formatter.monthDayYearDate.date(from: collectionDatePresentableFormat)?.yearMonthDayString, model.authenticated == false
                        else { return }
                        
                        let model = GatewayTestResultRequest(phn: phn, dateOfBirth: dateOfBirth, collectionDate: collectionDate)
                        tableView.cellForRow(at: IndexPath(row: indexPathRow, section: 0))?.startLoadingIndicator(backgroundColor: .clear, containerSize: 20, size: 8)
                        backgroundWorker?.getTestResult(model: model, executingVC: self, row: indexPathRow)
                    }
                }
            default: print("")
            }
        }
    }
    
    private func performBCSCLogin() {
        self.showLogin(initialView: .Auth, sourceVC: .UserListOfRecordsVC) { [weak self] authenticated in
            guard let `self` = self, authenticated else {return}
            if let authStatus = Defaults.loginProcessStatus,
               authStatus.hasCompletedLoginProcess == true,
               let storedName = authStatus.loggedInUserAuthManagerDisplayName,
               let currentAuthPatient = StorageService.shared.fetchAuthenticatedPatient(),
               let currentName = currentAuthPatient.authManagerDisplayName,
               storedName != currentName {
                StorageService.shared.deleteHealthRecordsForAuthenticatedUser()
                StorageService.shared.deleteAuthenticatedPatient(with: storedName)
                self.authManager.clearMedFetchProtectiveWordDetails()
                //                self.patient = nil
                if self.navStyle == .multiUser {
                    //                    self.navSetup(style: self.navStyle, authenticated: self.authenticated, showLoadingTitle: true)
                    //                    self.tableView.startLoadingIndicator()
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.fetchDataSource()
            }
        }
    }
    
//    @objc private func patientAPIFetched(_ notification: Notification) {
//        let userInfo = notification.userInfo as? [String: String]
//        let firstName = userInfo?["firstName"]
//        let fullName = userInfo?["fullName"]
//        self.patient = StorageService.shared.fetchAuthenticatedPatient()
//        self.navSetup(style: self.navStyle, authenticated: self.authenticated, defaultFirstNameIfFailure: firstName, defaultFullNameIfFailure: fullName)
//    }
}

// MARK: TableView setup
extension UsersListOfRecordsViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
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
        cell.delegate = self
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
            case .loginToAccess:
                self.performBCSCLogin()
            case .medicalRecords:
                if self.authManager.medicalFetchRequired {
                    self.selectedCellIndexPath = indexPath
                }
                self.promptProtectiveVC(medFetchRequired: self.authManager.medicalFetchRequired)
            case .authenticate:
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
        guard dataSource.count > indexPath.row else {return}
        let ds = dataSource[indexPath.row]
        let vc = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: ds, authenticated: ds.isAuthenticated, userNumberHealthRecords: dataSource.count)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard !dataSource.isEmpty || !inEditMode else { return .none }
        if ableToDeleteRecord(at: indexPath.row) {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteRecord(at: indexPath.row, reInitEditMode: true, manuallyAdded: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right, ableToDeleteRecord(at: indexPath.row) else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            guard let `self` = self else {return}
            self.deleteRecord(at: indexPath.row, reInitEditMode: false, manuallyAdded: true)
        }
        deleteAction.hidesWhenSelected = true
        deleteAction.image = UIImage(named: "unlink")
        deleteAction.backgroundColor = .white
        deleteAction.textColor = Constants.UI.Theme.primaryColor
        deleteAction.isAccessibilityElement = true
        deleteAction.accessibilityLabel = AccessibilityLabels.UnlinkFunctionality.unlinkCard
        deleteAction.accessibilityTraits = .button
        return [deleteAction]
    }
    
    private func ableToDeleteRecord(at index: Int) -> Bool {
        guard dataSource.indices.contains(index) else { return false }
        let record = dataSource[index]
        return !record.isAuthenticated
    }
    
    private func deleteRecord(at index: Int, reInitEditMode: Bool, manuallyAdded: Bool) {
        guard dataSource.indices.contains(index) else {return}
        let record = dataSource[index]
        self.delete(record: record, manuallyAdded: manuallyAdded, completion: { [weak self] deleted in
            guard let `self` = self else {return}
            if deleted {
                self.dataSource.remove(at: index)
                if self.dataSource.isEmpty {
                    self.inEditMode = false
                    self.popBack(toControllerType: HealthRecordsViewController.self)
                } else {
                    self.tableView.reloadData()
                }
            } else {
                if reInitEditMode {
                    self.tableView.setEditing(false, animated: true)
                    self.tableView.setEditing(true, animated: true)
                }
            }
        })
    }
    
    private func delete(record: HealthRecordsDetailDataSource, manuallyAdded: Bool, completion: @escaping(_ deleted: Bool)-> Void) {
        switch record.type {
        case .covidImmunizationRecord(model: let model, immunizations: _):
            alertConfirmation(title: .deleteRecord, message: .deleteCovidHealthRecord, confirmTitle: .delete, confirmStyle: .destructive) {
                StorageService.shared.deleteVaccineCard(vaccineQR: model.code, manuallyAdded: manuallyAdded)
                completion(true)
            } onCancel: {
                completion(false)
            }
            
        case .covidTestResultRecord:
            guard let recordId = record.id else {return}
            alertConfirmation(title: .deleteTestResult, message: .deleteTestResultMessage, confirmTitle: .delete, confirmStyle: .destructive) {
                StorageService.shared.deleteCovidTestResult(id: recordId, sendDeleteEvent: true)
                completion(true)
            } onCancel: {
                completion(false)
            }
        case .medication:
            return
        case .laboratoryOrder:
            return
        }
    }
    
}

extension UsersListOfRecordsViewController: BackgroundTestResultUpdateAPIWorkerDelegate {
    func handleTestResult(result: GatewayTestResultResponse, row: Int) {
        print("BACKGROUND FETCH INFO: Response: ", result, "Row to update: ", row)
        StorageService.shared.updateCovidTestResult(gateWayResponse: result, manuallyAdded: false) { [weak self] covidLabTestResult in
            guard let `self` = self else {return}
            
            guard let covidLabTestResult = covidLabTestResult else { return }
            guard let healthRecordDetailDS = HealthRecord(type: .CovidTest(covidLabTestResult)).detailDataSource() else { return }
            guard self.dataSource.count > row else { return }
            self.dataSource[row] = healthRecordDetailDS
            let indexPath = IndexPath(row: row, section: 0)
            guard self.tableView.numberOfRows(inSection: 0) > indexPath.row else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.tableView.cellForRow(at: indexPath)?.endLoadingIndicator()
        }
    }
    
    func handleError(title: String, error: ResultError, row: Int) {
        print("BACKGROUND FETCH INFO: Error: ", title, error, "For Row: ", row)
        let indexPath = IndexPath(row: row, section: 0)
        guard self.tableView.numberOfRows(inSection: 0) > indexPath.row else { return }
        self.tableView.cellForRow(at: indexPath)?.endLoadingIndicator()
    }
}

// MARK: Protected word retry
extension UsersListOfRecordsViewController {
    @objc private func protectedWordFailedPromptAgain(_ notification: Notification) {
        alert(title: .error, message: .protectedWordAlertError, buttonOneTitle: .yes, buttonOneCompletion: {
            self.promptProtectiveVC(medFetchRequired: self.authManager.medicalFetchRequired)
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
            if let proWord = self.protectiveWord, protectiveWordEntered == proWord {
                let records = self.patientRecordsTemp ?? []
                AppDelegate.sharedInstance?.protectiveWordEnteredThisSession = true
                showAllRecords(patientRecords: records, medFetchRequired: false)
                self.tableView.reloadData()
            } else {
                alert(title: .error, message: .protectedWordAlertError, buttonOneTitle: .yes, buttonOneCompletion: {
                    self.promptProtectiveVC(medFetchRequired: false)
                }, buttonTwoTitle: .no) {
                    // Do nothing
                }
            }
        } else if purpose == .initialFetch {
            adjustLoadingIndicator(show: true)
            self.performAuthenticatedRecordsFetch(isManualFetch: false, showBanner: true, specificFetchTypes: [.MedicationStatement], protectiveWord: protectiveWordEntered, sourceVC: .UserListOfRecordsVC)
        }
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

// MARK: Auth fetch completed, reload data
extension UsersListOfRecordsViewController {
    @objc private func authFetchComplete(_ notification: Notification) {
        adjustLoadingIndicator(show: false)
//        self.tableView.endLoadingIndicator()
        self.fetchDataSource(initialProtectedMedFetch: true)
    }
}
