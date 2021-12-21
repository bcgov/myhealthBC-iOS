//
//  FetchHealthRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This will contain a table view with the two cells for immunization record and test results. This view controller will be shown automatically on top of the healthRecordsViewController when no health records exist - will have to show a loading indicator

import UIKit

class FetchHealthRecordsViewController: BaseViewController {
    
    class func constructFetchHealthRecordsViewController(hideNavBackButton: Bool) -> FetchHealthRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: FetchHealthRecordsViewController.self)) as? FetchHealthRecordsViewController {
            vc.hideNavBackButton = hideNavBackButton
            return vc
        }
        return FetchHealthRecordsViewController()
    }
    
    @IBOutlet weak private var headerLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
    private var hideNavBackButton = false
    
    private var dataSource: [GetRecordsView.RecordType] = [.covidImmunizationRecord, .covidTestResult]

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        if hideNavBackButton {
            self.navigationItem.setHidesBackButton(true, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setHidesBackButton(false, animated: animated)
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
        navSetup()
        setupLabel()
        setupTableView()
    }
    
    private func setupLabel() {
        headerLabel.font = UIFont.bcSansRegularWithSize(size: 17)
        headerLabel.textColor = AppColours.textBlack
        headerLabel.text = .fetchHealthRecordsIntroText
    }

}

// MARK: Navigation setup
extension FetchHealthRecordsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .healthRecords,
                                               leftNavButton: nil,
                                               rightNavButton: nil,
                                               navStyle: .large,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
}

// MARK: TableView setup
extension FetchHealthRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: GetARecordTableViewCell.getName, bundle: .main), forCellReuseIdentifier: GetARecordTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: GetARecordTableViewCell.getName, for: indexPath) as? GetARecordTableViewCell {
            cell.configure(type: dataSource[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = dataSource[indexPath.row]
        var rememberDetails = RememberedGatewayDetails(storageArray: nil)
        if let details = Defaults.rememberGatewayDetails {
            rememberDetails = details
        }
        switch type {
        case .covidImmunizationRecord:
            let vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: .vaccinationRecord)
            vc.completionHandler = { [weak self] details in
                guard let `self` = self else { return }
                self.handleRouting(id: details.id, recordType: .covidImmunizationRecord, name: details.name, birthday: details.dob)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .covidTestResult:
            let vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: .covid19TestResult)
            vc.completionHandler = { [weak self] details in
                guard let `self` = self else { return }
                self.handleRouting(id: details.id, recordType: .covidTestResult, name: details.name, birthday: details.dob)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func handleRouting(id: String, recordType: GetRecordsView.RecordType, name: String?, birthday: String?) {
        StorageService.shared.getHeathRecords { [weak self] records in
            guard let `self` = self else { return }
            var recordsCount: Int
            if let name = name, let birthday = birthday {
                let birthDate = Date.Formatter.yearMonthDay.date(from: birthday)
                recordsCount = records.detailDataSource(userName: name, birthDate: birthDate).count
            } else {
                recordsCount = 1
            }
            let dataSource = records.fetchDetailDataSourceWithID(id: id, recordType: recordType)
            guard let ds = dataSource else {
                self.popBack(toControllerType: HealthRecordsViewController.self)
                return
            }
            let detailVC = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: ds, userNumberHealthRecords: recordsCount)
            self.navigationController?.pushViewController(detailVC, animated: true)
            self.setupNavStack(name: name, birthday: birthday)
        }
    }
    
    
    private func setupNavStack(name: String?, birthday: String?) {
//        // Step 1: Check if HealthRecords VC is in the stack or not
        guard let viewControllerStack = self.navigationController?.viewControllers, viewControllerStack.count > 0 else { return }
//        var containsHealthRecordsBaseVC = false
//        for (_, vc) in viewControllerStack.enumerated() {
//            if vc is HealthRecordsViewController {
//                containsHealthRecordsBaseVC = true
//            }
//        }
//        if containsHealthRecordsBaseVC == false {
//            let vc = HealthRecordsViewController.constructHealthRecordsViewController()
//            self.navigationController?.viewControllers.insert(vc, at: 0)
//        }
        var containsUserRecordsVC = false
        for (_, vc) in viewControllerStack.enumerated() {
            if vc is UsersListOfRecordsViewController {
                containsUserRecordsVC = true
            }
        }
        if containsUserRecordsVC == false, let name = name, let birthday = birthday {
            let birthDate = Date.Formatter.yearMonthDay.date(from: birthday)
            let vc = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(name: name, birthdate: birthDate)
            self.navigationController?.viewControllers.insert(vc, at: 1)
        }
        for (index, vc) in viewControllerStack.enumerated() {
            if vc is GatewayFormViewController {
                self.navigationController?.viewControllers.remove(at: index)
            }
        }
        for (index, vc) in viewControllerStack.enumerated() {
            if vc is FetchHealthRecordsViewController {
                self.navigationController?.viewControllers.remove(at: index)
            }
        }
    }
}
