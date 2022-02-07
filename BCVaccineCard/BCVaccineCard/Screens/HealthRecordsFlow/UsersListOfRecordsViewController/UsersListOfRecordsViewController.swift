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
    
    private func setup() {
        self.backgroundWorker = BackgroundTestResultUpdateAPIWorker(delegateOwner: self)
        fetchDataSource()
    }
    
}

// MARK: Navigation setup
extension UsersListOfRecordsViewController {
    private func navSetup() {
        let hasRecords = !self.dataSource.isEmpty
        let editModeNavButton = inEditMode ? NavButton(title: .done,
                                                       image: nil, action: #selector(self.doneButton),
                                                       accessibility: Accessibility(traits: .button, label: AccessibilityLabels.ListOfHealthRecordsScreen.navRightDoneIconTitle, hint: AccessibilityLabels.ListOfHealthRecordsScreen.navRightDoneIconHint)) :
        NavButton(title: .edit,
                  image: nil, action: #selector(self.editButton),
                  accessibility: Accessibility(traits: .button, label: AccessibilityLabels.ListOfHealthRecordsScreen.navRightEditIconTitle, hint: AccessibilityLabels.ListOfHealthRecordsScreen.navRightEditIconHint))
        let rightNavButton = hasRecords ? editModeNavButton : nil
        self.navDelegate?.setNavigationBarWith(title: self.patient?.name ?? "" + " " + .recordText.capitalized,
                                               leftNavButton: nil,
                                               rightNavButton: rightNavButton,
                                               navStyle: .small,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
    
    @objc private func doneButton() {
        inEditMode = false
    }
    
    @objc private func editButton() {
        tableView.isEditing = false
        inEditMode = true
    }
}

// MARK: Data Source Setup
extension UsersListOfRecordsViewController {
    private func fetchDataSource() {
        guard let patient = self.patient else {return}
        self.view.startLoadingIndicator(backgroundColor: .clear)
        
        let records = StorageService.shared.getHeathRecords()
        let patientRecords = records.detailDataSource(patient: patient)
        if AuthManager().isAuthenticated {
            self.dataSource = patientRecords
            self.hiddenRecords.removeAll()
        } else {
            let unauthenticatedRecords = patientRecords.filter({!$0.isAuthenticated})
            let authenticatedRecords = patientRecords.filter({$0.isAuthenticated})
            self.dataSource = unauthenticatedRecords
            self.hiddenRecords = authenticatedRecords
        }
        self.setupTableView()
        self.navSetup()
        
        self.view.endLoadingIndicator()
        
        // Note: Reloading data here as the table view doesn't seem to reload properly after deleting a record from the detail screen
        self.tableView.reloadData()
        self.checkForTestResultsToUpdate(ds: self.dataSource)
        
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
                              let collectionDate = Date.Formatter.monthDayYearDate.date(from: collectionDatePresentableFormat)?.yearMonthDayString else { return }
                        
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
        cell.configure(numberOfHiddenRecords: hiddenRecords.count, onLogin: {[weak self] in
            guard let `self` = self else {return}
            self.performBCSCLogin()
            
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !hiddenRecords.isEmpty && indexPath.section == 0 {
            return hiddenRecordsCell(indexPath: indexPath)
        } else {
            return recordCell(indexPath: indexPath)
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !hiddenRecords.isEmpty && indexPath.section == 0 { return }
        guard dataSource.count > indexPath.row else {return}
        let ds = dataSource[indexPath.row]
        let vc = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: ds, userNumberHealthRecords: dataSource.count)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard !dataSource.isEmpty || !inEditMode else { return .none }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteRecord(at: indexPath.row, reInitEditMode: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if inEditMode {
            deleteRecord(at: indexPath.row, reInitEditMode: true)
        }
        
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            guard let `self` = self else {return}
            self.deleteRecord(at: indexPath.row, reInitEditMode: false)
        }
        deleteAction.hidesWhenSelected = true
        deleteAction.image = UIImage(named: "unlink")
        deleteAction.backgroundColor = .white
        deleteAction.textColor = Constants.UI.Theme.primaryColor
        deleteAction.isAccessibilityElement = true
        deleteAction.accessibilityLabel = AccessibilityLabels.UnlinkFunctionality.unlinkButton
        deleteAction.accessibilityTraits = .button
        return [deleteAction]
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
                StorageService.shared.deleteTestResult(id: recordId, sendDeleteEvent: true)
                completion(true)
            } onCancel: {
                completion(false)
            }
        }
    }
    
}

extension UsersListOfRecordsViewController: BackgroundTestResultUpdateAPIWorkerDelegate {
    func handleTestResult(result: GatewayTestResultResponse, row: Int) {
        print("BACKGROUND FETCH INFO: Response: ", result, "Row to update: ", row)
        StorageService.shared.updateTestResult(gateWayResponse: result) { [weak self] covidLabTestResult in
            guard let `self` = self else {return}
 
            guard let covidLabTestResult = covidLabTestResult else { return }
            guard let healthRecordDetailDS = HealthRecord(type: .Test(covidLabTestResult)).detailDataSource() else { return }
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
