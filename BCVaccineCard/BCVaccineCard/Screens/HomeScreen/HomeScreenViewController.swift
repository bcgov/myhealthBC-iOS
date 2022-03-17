//
//  HomeScreenViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-16.
//

import UIKit

class HomeScreenViewController: BaseViewController {
    
    class func constructHomeScreenViewController() -> HomeScreenViewController {
        if let vc = Storyboard.home.instantiateViewController(withIdentifier: String(describing: HomeScreenViewController.self)) as? HomeScreenViewController {
            return vc
        }
        return HomeScreenViewController()
    }
    
    @IBOutlet weak private var introLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    private var dataSource: [HomeScreenCellType] = [.Records, .Proofs, .Resources]
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
        navSetup()
        addObservablesForChangeInAuthenticationStatus()
        setupIntroLabel()
        setupTableView()
    }
    
}

// MARK: Navigation setup
extension HomeScreenViewController {
    private func navSetup() {
        var title: String
        if authManager.isAuthenticated, let name = authManager.displayName {
            title = name
        } else {
            title = "Hello"
        }
        self.navDelegate?.setNavigationBarWith(title: title,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
}

// MARK: Observable logic for authentication status change
extension HomeScreenViewController {
    private func addObservablesForChangeInAuthenticationStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(authStatusChanged), name: .authStatusChanged, object: nil)
    }
    
    // Note: Not using authenticated value right now, may just remove it. Leaving in for now in case some requirements change or if there are any edge cases not considered
    // FIXME: Either use the userInfo value or remove it - need to test more first (comment above)
    @objc private func authStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Bool] else { return }
        guard let authenticated = userInfo[Constants.AuthStatusKey.key] else { return }
        self.navSetup()
    }
}

// MARK: UI Setup
extension HomeScreenViewController {
    private func setupIntroLabel() {
        introLabel.font = UIFont.bcSansBoldWithSize(size: 20)
        introLabel.textColor = AppColours.appBlue
        introLabel.text = "What do you want to focus on today?"
    }
}

// MARK: Table View Setup
extension HomeScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.register(UINib.init(nibName: HomeScreenTableViewCell.getName, bundle: .main), forCellReuseIdentifier: HomeScreenTableViewCell.getName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 231
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeScreenTableViewCell.getName, for: indexPath) as? HomeScreenTableViewCell else { return UITableViewCell() }
        let type = dataSource[indexPath.row]
        cell.configure(forType: type)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = dataSource[indexPath.row]
        goToTabForType(type: type)
    }
}

// MARK: Navigation logic for each type here
extension HomeScreenViewController {
    private func goToTabForType(type: HomeScreenCellType) {
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tabBarController.selectedIndex = type.getTabIndex
    }
}

