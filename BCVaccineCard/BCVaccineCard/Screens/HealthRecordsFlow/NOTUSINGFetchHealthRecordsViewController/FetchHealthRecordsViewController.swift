//
//  FetchHealthRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-29.
// TODO: This will contain a table view with the two cells for immunization record and test results. This view controller will be shown automatically on top of the healthRecordsViewController when no health records exist - will have to show a loading indicator

// TODO: CONNOR: Delete this view controller when we know that we for sure won't be using it anymore

import UIKit

class FetchHealthRecordsViewController: BaseViewController {
    
    enum DataSource {
        case recordType(type: GetRecordsView.RecordType)
        case login(type: HiddenRecordType)
    }
    
    class func constructFetchHealthRecordsViewController(hasHealthRecords: Bool) -> FetchHealthRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: FetchHealthRecordsViewController.self)) as? FetchHealthRecordsViewController {
//            vc.hideNavBackButton = hideNavBackButton
//            vc.showSettingsIcon = showSettingsIcon
            vc.hasHealthRecords = hasHealthRecords
//            vc.completion = completion
            return vc
        }
        return FetchHealthRecordsViewController()
    }
    
//    @IBOutlet weak private var headerLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
//    private var hideNavBackButton = false
    private var showSettingsIcon: Bool = true
    private var hasHealthRecords: Bool!
//    private var completion: (()->Void)?
    
    private var dataSource: [DataSource] = [.recordType(type: .covidImmunizationRecord),
                                            .recordType(type: .covidTestResult)]
    
//    override var getRecordFlowType: RecordsFlowVCs? {
//        return .FetchHealthRecordsViewController
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        self.adjustDataSource()
        self.tabBarController?.tabBar.isHidden = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setHidesBackButton(false, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        checkIfIsRootVCInStack()
        navSetup()
//        setupLabel()
        setupTableView()
        setupListeners()
    }
    // TODO: Make this safer?
    private func checkIfIsRootVCInStack() {
        self.showSettingsIcon = (((self.tabBarController as? TabBarController)?.viewControllers?[TabBarVCs.records.rawValue] as? CustomNavigationController)?.viewControllers as? [BaseViewController])?.first is FetchHealthRecordsViewController ? true : false
    }
    
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
        self.navDelegate?.setNavigationBarWith(title: hasHealthRecords ? .addHealthRecord : .healthRecords,
                                               leftNavButton: nil,
                                               rightNavButton: navButton,
                                               navStyle: hasHealthRecords ? .small : .large,
                                               navTitleSmallAlignment: .Center,
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
            case .medication, .laboratoryOrder, .immunization, .healthVisit, .SpecialAuthority, .hospitalVisit, .clinicalDocument:
                // Currently we are not going to allow user to manually fetch meds or lab orders, so no action here
                return
            }
        }
        
        showForm()
    }
    //FIXME: CONNOR: Adjust routing here to use router worker
    private func showVaccineForm(rememberDetails: RememberedGatewayDetails) {
        let vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: .vaccinationRecord)
        vc.completionHandler = { [weak self] details in
            guard let `self` = self else { return }
//            self.handleRouting(id: details.id, recordType: .covidImmunizationRecord, details: details)
            let record = StorageService.shared.getHeathRecords().fetchDetailDataSourceWithID(id: details.id, recordType: .covidImmunizationRecord)
            DispatchQueue.main.async {
                
                let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack, actioningPatient: details.patient, addedRecord: record)
                let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack, recentlyAddedCardId: details.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil)
                let values = ActionScenarioValues(currentTab: self.getCurrentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
                self.routerWorker?.routingAction(scenario: .ManualFetch(values: values))
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //FIXME: CONNOR: Adjust routing here to use router worker
    private func showTestForm(rememberDetails: RememberedGatewayDetails) {
        let vc = GatewayFormViewController.constructGatewayFormViewController(rememberDetails: rememberDetails, fetchType: .covid19TestResult)
        vc.completionHandler = { [weak self] details in
            guard let `self` = self else { return }
//            self.handleRouting(id: details.id, recordType: .covidTestResult, details: details)
            let record = StorageService.shared.getHeathRecords().fetchDetailDataSourceWithID(id: details.id, recordType: .covidTestResult)
            DispatchQueue.main.async {
                
                let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack, actioningPatient: details.patient, addedRecord: record)
                let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack, recentlyAddedCardId: details.id, fedPassStringToOpen: nil, fedPassAddedFromHealthPassVC: nil)
                let values = ActionScenarioValues(currentTab: self.getCurrentTab, recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails)
                self.routerWorker?.routingAction(scenario: .ManualFetch(values: values))
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: BCSC Login
extension FetchHealthRecordsViewController {
    func performBCSCLogin() {
        self.showLogin(initialView: .Landing, sourceVC: .FetchHealthRecordsVC) { [weak self] authenticationStatus in
            guard let `self` = self, authenticationStatus == .Completed else {return}
            // TODO: Adjust nav stack here if necessary
            self.adjustDataSource()
        }
    }
}
