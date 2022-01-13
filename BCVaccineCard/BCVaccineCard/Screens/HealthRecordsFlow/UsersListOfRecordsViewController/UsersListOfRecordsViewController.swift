//
//  UsersListOfRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This will be a table view controller with editable cells (for deleting) - nav bar will have same edit/done functionality that covid 19 view controller has

import UIKit
import SwipeCellKit

class UsersListOfRecordsViewController: BaseViewController {
    
    // TODO: Replace params with USER after storage refactor
    class func constructUsersListOfRecordsViewController(name: String, birthdate: Date?) -> UsersListOfRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: UsersListOfRecordsViewController.self)) as? UsersListOfRecordsViewController {
            vc.name = name
            vc.birthdate = birthdate
            return vc
        }
        return UsersListOfRecordsViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var name: String!
    private var birthdate: Date?
    private var backgroundWorker: BackgroundTestResultUpdateAPIWorker?
    
    private var dataSource: [HealthRecordsDetailDataSource] = []
    
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
        fetchDataSource(checkForBackgroundUpdates: true)
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
        self.navDelegate?.setNavigationBarWith(title: self.name + " " + .recordText.capitalized,
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
    private func fetchDataSource(checkForBackgroundUpdates: Bool) {
        // TODO: Adding this check here for now, will remove once refactored
        if checkForBackgroundUpdates {
            self.view.startLoadingIndicator(backgroundColor: .clear)
        }
        StorageService.shared.getHeathRecords { [weak self] records in
            guard let `self` = self else {return}
//            Logger.log(string: records.first!.detailDataSource())
            self.dataSource = records.detailDataSource(userName: self.name, birthDate: self.birthdate)
            self.setupTableView()
            self.navSetup()
            if checkForBackgroundUpdates {
                self.view.endLoadingIndicator()
            }
            // Note: Reloading data here as the table view doesn't seem to reload properly after deleting a record from the detail screen
            self.tableView.reloadData()
            if checkForBackgroundUpdates {
                self.checkForTestResultsToUpdate(ds: self.dataSource)
            }
        }
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
                        backgroundWorker?.getTestResult(model: model, executingVC: self, row: indexPathRow)
                    }
                }
            default: print("")
            }
        }
    }
}

// MARK: TableView setup
extension UsersListOfRecordsViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: UserRecordListTableViewCell.getName, bundle: .main), forCellReuseIdentifier: UserRecordListTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: UserRecordListTableViewCell.getName, for: indexPath) as? UserRecordListTableViewCell else {
                return UITableViewCell()
            }
        cell.configure(record: dataSource[indexPath.row])
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                StorageService.shared.deleteTestResult(id: recordId)
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
        StorageService.shared.updateTestResult(gateWayResponse: result) { [weak self] success in
            guard let `self` = self else {return}
            // TODO: Need to find a better way to update the VC data source - refactor needed
            self.fetchDataSource(checkForBackgroundUpdates: false)
//            let indexPath = IndexPath(row: row, section: 0)
//            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func handleError(title: String, error: ResultError, row: Int) {
        print("BACKGROUND FETCH INFO: Error: ", title, error, "For Row: ", row)
    }
    
    
}
