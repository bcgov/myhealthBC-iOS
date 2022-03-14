//
//  UsersListOfRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This will be a table view controller with editable cells (for deleting) - nav bar will have same edit/done functionality that covid 19 view controller has

import UIKit
import SwipeCellKit

class UsersListOfRecordsViewController: BaseViewController {
    
    // TODO: Replace params with Patient after storage refactor
    class func constructUsersListOfRecordsViewController(patient: Patient) -> UsersListOfRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: UsersListOfRecordsViewController.self)) as? UsersListOfRecordsViewController {
            vc.patient = patient
            return vc
        }
        return UsersListOfRecordsViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var patient: Patient?
    
    private var backgroundWorker: BackgroundTestResultUpdateAPIWorker?
    
    private var dataSource: [HealthRecordsDetailDataSource] = []
    private var hiddenRecords: [HealthRecordsDetailDataSource] = []
    private var hiddenCellType: HiddenRecordType?
    
    fileprivate let authManager = AuthManager()
    private var protectiveWord: String?
    private var patientRecordsTemp: [HealthRecordsDetailDataSource]? // Note: This is used to temporarily store patient records when authenticating with local protective word
//    private var promptUser = true // Note: This is used because we fetch ds on view will appear, but protective word should be checked on view did load
    
    private var currentFilter: RecordsFilter? = nil
    
    private var inEditMode = false {
        didSet {
            self.tableView.setEditing(inEditMode, animated: false)
            self.tableView.reloadData()
            navSetup()
            self.tableView.layoutSubviews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
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
    }
    
    private func setup() {
        self.backgroundWorker = BackgroundTestResultUpdateAPIWorker(delegateOwner: self)
        fetchDataSource()
    }
    
}

// MARK: Navigation setup
extension UsersListOfRecordsViewController {
    private func navSetup() {
        let filterButton = NavButton(title: "Filter" ,
                  image: nil, action: #selector(self.showFilters),
                  accessibility: Accessibility(traits: .button, label: AccessibilityLabels.ListOfHealthRecordsScreen.navRightEditIconTitle, hint: AccessibilityLabels.ListOfHealthRecordsScreen.navRightEditIconHint))
        
        self.navDelegate?.setNavigationBarWith(title: self.patient?.name ?? "" + " " + .recordText.capitalized,
                                               leftNavButton: nil,
                                               rightNavButton: filterButton,
                                               navStyle: .large,
                                               targetVC: self,
                                               backButtonHintString: nil)
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
}

// MARK: Data Source Setup
extension UsersListOfRecordsViewController {
    
    private func fetchDataSource() {
        let patientRecords = fetchPatientRecords()
        show(records: patientRecords, filter: nil)
        self.checkForTestResultsToUpdate(ds: self.dataSource)
        
    }
    
    private func fetchPatientRecords() -> [HealthRecordsDetailDataSource] {
        guard let patient = self.patient else {return []}
        let records = StorageService.shared.getHeathRecords()
        let patientRecords = records.detailDataSource(patient: patient)
        return patientRecords
    }
    
    private func show(records: [HealthRecordsDetailDataSource], filter: RecordsFilter? = nil) {
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
            handleAuthenticatedMedicalRecords(patientRecords: patientRecords)
        } else {
            let unauthenticatedRecords = patientRecords.filter({!$0.isAuthenticated})
            let authenticatedRecords = patientRecords.filter({$0.isAuthenticated})
            self.dataSource = unauthenticatedRecords
            self.hiddenRecords = authenticatedRecords
            self.hiddenCellType = .login(hiddenRecords: hiddenRecords.count)
        }
        self.setupTableView()
        self.navSetup()
        
        self.view.endLoadingIndicator()
        
        // Note: Reloading data here as the table view doesn't seem to reload properly after deleting a record from the detail screen
        self.tableView.reloadData()
        self.checkForTestResultsToUpdate(ds: self.dataSource)
    }
    
    private func handleAuthenticatedMedicalRecords(patientRecords: [HealthRecordsDetailDataSource]) {
        // Note: Assumption is, if protective word is not stored in keychain at this point, then user does not have protective word enabled
        self.patientRecordsTemp = patientRecords
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
        if medFetchRequired {
            let tempRecord = HealthRecordsDetailDataSource(type: .medication(model: Perscription()))
            self.hiddenRecords = [tempRecord] // Note: Just doing this to get the cell to show
        } else {
            self.hiddenRecords.removeAll()
        }
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
    
    func performBCSCLogin() {
        self.showLogin(initialView: .Auth) { [weak self] authenticated in
            guard let `self` = self, authenticated else {return}
            self.fetchDataSource()
        }
    }
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
        return hiddenRecords.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hiddenRecords.isEmpty && section == 0 {
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
            case .login:
                self.performBCSCLogin()
            case .medicalRecords:
                self.promptProtectiveVC(medFetchRequired: <#Bool#>)
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
            self.deleteRecord(at: indexPath.row, reInitEditMode: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right, ableToDeleteRecord(at: indexPath.row) else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            guard let `self` = self else {return}
            self.deleteRecord(at: indexPath.row, reInitEditMode: false)
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
    
    private func deleteRecord(at index: Int, reInitEditMode: Bool) {
        guard dataSource.indices.contains(index) else {return}
        let record = dataSource[index]
        self.delete(record: record, completion: { [weak self] deleted in
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
    
    private func delete(record: HealthRecordsDetailDataSource, completion: @escaping(_ deleted: Bool)-> Void) {
        switch record.type {
        case .covidImmunizationRecord(model: let model, immunizations: _):
            alertConfirmation(title: .deleteRecord, message: .deleteCovidHealthRecord, confirmTitle: .delete, confirmStyle: .destructive) {
                StorageService.shared.deleteVaccineCard(vaccineQR: model.code)
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
        StorageService.shared.updateCovidTestResult(gateWayResponse: result) { [weak self] covidLabTestResult in
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
                alert(title: "Error", message: "The protective word you provided was incorrect. You must enter the correct protective word in order to view your medical records, would you like to try again?", buttonOneTitle: "Yes", buttonOneCompletion: {
                    self.promptProtectiveVC(medFetchRequired: false)
                }, buttonTwoTitle: "No") {
                    // Do nothing
                }
            }
        } else if purpose == .initialFetch {
            // TODO: Need to test this out
            self.performAuthenticatedBackgroundFetch(isManualFetch: false, showBanner: true, specificFetchTypes: [.MedicationStatement], protectiveWord: protectiveWordEntered)
        }
        
        
    }
}

// MARK: Protected word retry
//extension AuthenticatedHealthRecordsAPIWorker {
//    @objc private func protectedWordProvided(_ notification: Notification) {
//        guard let protectiveWord = notification.userInfo?[Constants.AuthenticatedMedicationStatementParameters.protectiveWord] as? String, let authCreds = self.authCredentials else { return }
//        guard let purposeRaw = notification.userInfo?[ProtectiveWordPurpose.purposeKey] as? String, let purpose = ProtectiveWordPurpose(rawValue: purposeRaw), purpose == .manualFetch else { return }
//        self.getAuthenticatedMedicationStatement(authCredentials: authCreds, protectiveWord: protectiveWord)
//    }
//}
