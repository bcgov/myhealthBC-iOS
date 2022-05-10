//
//  HomeScreenViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-16.
//

import UIKit

class HomeScreenViewController: BaseViewController {
    
    enum DataSource {
        case text(text: String)
        case button(type: HomeScreenCellType)
    }
    
    class func constructHomeScreenViewController() -> HomeScreenViewController {
        if let vc = Storyboard.home.instantiateViewController(withIdentifier: String(describing: HomeScreenViewController.self)) as? HomeScreenViewController {
            return vc
        }
        return HomeScreenViewController()
    }
    
    @IBOutlet weak private var tableView: UITableView!
    private var dataSource: [DataSource] = [.text(text: "What do you want to focus on today?"), .button(type: .Records), .button(type: .Proofs), .button(type: .Resources)]
    private var authManager: AuthManager = AuthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.darkContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    private func setup() {
        addObservablesForChangeInAuthenticationStatus()
        setupTableView()
        navSetup()
    }
    
}

// MARK: Navigation setup
extension HomeScreenViewController {
    fileprivate func navTitle(firstName: String? = nil) -> String {
        if authManager.isAuthenticated, let name = firstName ?? StorageService.shared.fetchAuthenticatedPatient()?.name?.firstName ?? authManager.firstName  {
            let sentenceCaseName = name.nameCase()
            return "Hi \(sentenceCaseName),"
        } else {
            return "Hello"
        }
    }
    
    private func navSetup(firstName: String? = nil) {
        var title: String = navTitle(firstName: firstName)
        self.navDelegate?.setNavigationBarWith(title: title,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
    }
}

// MARK: Observable logic for authentication status change
extension HomeScreenViewController {
    private func addObservablesForChangeInAuthenticationStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(authStatusChanged), name: .authStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(patientAPIFetched), name: .patientAPIFetched, object: nil)
        NotificationManager.listenToLoginDataClearedOnLoginRejection(observer: self, selector: #selector(reloadFromForcedLogout))
    }
    
    @objc private func reloadFromForcedLogout(_ notification: Notification) {
        navSetup()
        self.tableView.reloadData()
    }
    
    // Note: Not using authenticated value right now, may just remove it. Leaving in for now in case some requirements change or if there are any edge cases not considered
    // FIXME: Either use the userInfo value or remove it - need to test more first (comment above)
    @objc private func authStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Bool] else { return }
        guard let authenticated = userInfo[Constants.AuthStatusKey.key] else { return }
        self.navSetup()
        self.tableView.reloadData()
    }
    
    @objc private func patientAPIFetched(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String?] else { return }
        guard let firstName = userInfo["firstName"] else { return }
        self.navSetup(firstName: firstName)
        self.tableView.reloadData()
    }
}

// MARK: Table View Setup
extension HomeScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.register(UINib.init(nibName: TextTableViewCell.getName, bundle: .main), forCellReuseIdentifier: TextTableViewCell.getName)
        tableView.register(UINib.init(nibName: HomeScreenTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HomeScreenTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 231
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row]
        switch data {
        case .text(text: let text):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.getName, for: indexPath) as? TextTableViewCell else { return UITableViewCell() }
            cell.configure(forType: .plainText, text: text, withFont: UIFont.bcSansBoldWithSize(size: 20), labelSpacingAdjustment: 30, textColor: AppColours.appBlue)
            return cell
        case .button(type: let type):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeScreenTableViewCell.getName, for: indexPath) as? HomeScreenTableViewCell else { return UITableViewCell() }
            cell.configure(forType: type, auth: authManager.isAuthenticated)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataSource[indexPath.row]
        switch data {
        case .button(type: let type):
            goToTabForType(type: type)
        default: break
        }
    }
}

// MARK: Navigation logic for each type here
extension HomeScreenViewController {
    private func goToTabForType(type: HomeScreenCellType) {
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard type == .Records && !authManager.isAuthenticated else {
            tabBarController.selectedIndex = type.getTabIndex
            return
        }
        handleGetStartedScenario(tabBarController: tabBarController)
    }
    
    private func handleGetStartedScenario(tabBarController: TabBarController) {
        self.showLogin(initialView: .Landing, sourceVC: .HomeScreen, presentingViewControllerReference: self) { authenticationStatus in
            guard authenticationStatus != .Cancelled else { return }
            let recordFlowDetails = RecordsFlowDetails(currentStack: self.getCurrentStacks.recordsStack)
            let passesFlowDetails = PassesFlowDetails(currentStack: self.getCurrentStacks.passesStack)
            let scenario = AppUserActionScenarios.LoginSpecialRouting(values: ActionScenarioValues(currentTab: .records, affectedTabs: [.records], recordFlowDetails: recordFlowDetails, passesFlowDetails: passesFlowDetails, loginSourceVC: .HomeScreen, authenticationStatus: authenticationStatus))
            self.routerWorker?.routingAction(scenario: scenario, goToTab: .records)
        }
    }
}

