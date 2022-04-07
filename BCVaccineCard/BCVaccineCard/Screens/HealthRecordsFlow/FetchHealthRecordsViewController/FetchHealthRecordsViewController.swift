//
//  FetchHealthRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This will contain a table view with the two cells for immunization record and test results. This view controller will be shown automatically on top of the healthRecordsViewController when no health records exist - will have to show a loading indicator

import UIKit

class FetchHealthRecordsViewController: BaseViewController {
    
    enum DataSource {
        case recordType(type: GetRecordsView.RecordType)
        case login(type: HiddenRecordType)
    }
    
    class func constructFetchHealthRecordsViewController(hideNavBackButton: Bool, showSettingsIcon: Bool, completion: @escaping()->Void) -> FetchHealthRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: FetchHealthRecordsViewController.self)) as? FetchHealthRecordsViewController {
            vc.hideNavBackButton = hideNavBackButton
            vc.showSettingsIcon = showSettingsIcon
            vc.completion = completion
            return vc
        }
        return FetchHealthRecordsViewController()
    }
    
//    @IBOutlet weak private var headerLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
    private var hideNavBackButton = false
    private var showSettingsIcon: Bool!
    private var completion: (()->Void)?
    
    private var dataSource: [DataSource] = [.recordType(type: .covidImmunizationRecord),
                                            .recordType(type: .covidTestResult)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
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
        self.adjustDataSource()
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
//        setupLabel()
        setupTableView()
        setupListeners()
    }
    
//    private func setupLabel() {
//        headerLabel.font = UIFont.bcSansRegularWithSize(size: 17)
//        headerLabel.textColor = AppColours.textBlack
//        headerLabel.text = .fetchHealthRecordsIntroText
//        setupAccessibilty()
//    }
    
//    private func setupAccessibilty() {
//        self.headerLabel.accessibilityLabel = .fetchHealthRecordsIntroText.capitalized
//    }
    
    private func adjustDataSource() {
        self.dataSource = [
            .recordType(type: .covidImmunizationRecord),
            .recordType(type: .covidTestResult)
        ]
        if !AuthManager().isAuthenticated {
            self.dataSource.insert(.login(type: .authenticate), at: 0)
        }
        self.tableView.reloadData()
    }
}

// MARK: Listeners
extension FetchHealthRecordsViewController {
    // MARK: Listeners
    private func setupListeners() {
        NotificationManager.listenToLoginDataClearedOnLoginRejection(observer: self, selector: #selector(reloadFromForcedLogout))
    }
    
    @objc private func reloadFromForcedLogout(_ notification: Notification) {
        self.adjustDataSource()
    }
}

// MARK: Navigation setup
extension FetchHealthRecordsViewController {
    private func navSetup() {
        let navButton: NavButton? = showSettingsIcon ? NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)) : nil
        self.navDelegate?.setNavigationBarWith(title: .healthRecords,
                                               leftNavButton: nil,
                                               rightNavButton: navButton,
                                               navStyle: .large,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
}

// MARK: TableView setup
extension FetchHealthRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView.register(UINib.init(nibName: GetARecordTableViewCell.getName, bundle: .main), forCellReuseIdentifier: GetARecordTableViewCell.getName)
        tableView.register(UINib.init(nibName: HiddenRecordsTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HiddenRecordsTableViewCell.getName)
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
        let data = dataSource[indexPath.row]
        switch data {
        case .recordType(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: GetARecordTableViewCell.getName, for: indexPath) as? GetARecordTableViewCell {
                cell.configure(type: type)
                return cell
            }
        case .login(type: let type):
            if let cell = tableView.dequeueReusableCell(withIdentifier: HiddenRecordsTableViewCell.getName, for: indexPath) as? HiddenRecordsTableViewCell {
                cell.configure(forRecordType: type) { recType in
                    guard let recType = recType else { return }
                    switch recType {
                    case .authenticate:
                        self.performBCSCLogin()
                    default: break
                    }
                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataSource[indexPath.row]
        switch data {
        case .recordType(type: let type):
            var rememberDetails = RememberedGatewayDetails(storageArray: nil)
            if let details = Defaults.rememberGatewayDetails {
                rememberDetails = details
            }
            showForm(type: type, rememberDetails: rememberDetails)
        case .login: break
        }
        
    }
    
    
    private func showForm(type: GetRecordsView.RecordType, rememberDetails: RememberedGatewayDetails) {
        
        func showForm() {
            switch type {
            case .covidImmunizationRecord:
                self.showVaccineForm(rememberDetails: rememberDetails)
            case .covidTestResult:
                self.showTestForm(rememberDetails: rememberDetails)
            case .medication, .laboratoryOrder:
                // Currently we are not going to allow user to manually fetch meds or lab orders, so no action here
                return
            }
        }
        
//        if !AuthManager().isAuthenticated {
//            showLogin(initialView: .Landing) { authenticated in
//                if !authenticated {
//                    showForm()
//                }
//            }
//        } else {
//            showForm()
//        }
        showForm()
    }
    
    private func showVaccineForm(rememberDetails: RememberedGatewayDetails) {
        let vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: .vaccinationRecord)
        vc.completionHandler = { [weak self] details in
            guard let `self` = self else { return }
            self.handleRouting(id: details.id, recordType: .covidImmunizationRecord, details: details)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showTestForm(rememberDetails: RememberedGatewayDetails) {
        let vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: .covid19TestResult)
        vc.completionHandler = { [weak self] details in
            guard let `self` = self else { return }
            self.handleRouting(id: details.id, recordType: .covidTestResult, details: details)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    private func handleRouting(id: String, recordType: GetRecordsView.RecordType, details: GatewayFormCompletionHandlerDetails) {
        if let completion = completion {
            completion()
        }
        let records = StorageService.shared.getHeathRecords()
        var recordsCount: Int
        if let name = details.name,
           let birthday = details.dob,
           let birthDate = Date.Formatter.yearMonthDay.date(from: birthday),
           let patient = StorageService.shared.fetchPatient(name: name, birthday: birthDate) {
            recordsCount = records.detailDataSource(patient: patient).count
        } else {
            recordsCount = 1
        }
        let dataSource = records.fetchDetailDataSourceWithID(id: id, recordType: recordType)
        guard let ds = dataSource else {
            self.popBack(toControllerType: HealthRecordsViewController.self)
            return
        }
        DispatchQueue.main.async {
            let detailVC = HealthRecordDetailViewController.constructHealthRecordDetailViewController(dataSource: ds, authenticated: ds.isAuthenticated, userNumberHealthRecords: recordsCount)
            self.setupNavStack(details: details, detailVC: detailVC, authenticated: ds.isAuthenticated)
        }
    }
    
    private func setupNavStack(details: GatewayFormCompletionHandlerDetails, detailVC: HealthRecordDetailViewController, authenticated: Bool) {
        guard let name = details.name,
              let birthday = details.dob,
              let birthDate = Date.Formatter.yearMonthDay.date(from: birthday),
              let patient = StorageService.shared.fetchPatient(name: name, birthday: birthDate),
              let stack = self.navigationController?.viewControllers, stack.count > 0
        else {
            return
        }
        
        var navStack: [UIViewController] = []

        var containsUserRecordsVC = false
        for (_, vc) in stack.enumerated() {
            if vc is UsersListOfRecordsViewController {
                containsUserRecordsVC = true
            }
        }
        
        if containsUserRecordsVC == false {
            let secondVC = UsersListOfRecordsViewController.constructUsersListOfRecordsViewController(patient: patient, authenticated: authenticated, navStyle: .multiUser, hasUpdatedUnauthPendingTest: false)
            navStack.append(secondVC)
        }
        
        navStack.append(detailVC)
        self.tabBarController?.tabBar.isHidden = false
        guard let tabBarVC = self.tabBarController as? TabBarController else { return }
        AppDelegate.sharedInstance?.addLoadingViewHack()
        tabBarVC.resetHealthRecordsTab(viewControllersToInclude: navStack)
    }
}

// MARK: BCSC Login
extension FetchHealthRecordsViewController {
    func performBCSCLogin() {
        self.showLogin(initialView: .Landing, sourceVC: .FetchHealthRecordsVC) { [weak self] authenticated in
            guard let `self` = self, authenticated else {return}
            // TODO: Adjust nav stack here if necessary
            self.adjustDataSource()
        }
    }
}
