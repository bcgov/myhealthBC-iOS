//
//  HomeScreenViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-03-16.
//

import UIKit

class HomeScreenViewController: BaseViewController {
    
    class func constructHealthPassViewController() -> HomeScreenViewController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: HomeScreenViewController.self)) as? HomeScreenViewController {
            return vc
        }
        return HomeScreenViewController()
    }
    
    @IBOutlet weak private var introLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
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
        setupDataSource()
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
    // TODO: Add observable here for when user is logged in or logged out
    private func addObservablesForChangeInAuthenticationStatus() {
        // TODO: In notification function, we will adjust the nav bar
    }
}

// MARK: UI Setup
extension HomeScreenViewController {
    private func setupIntroLabel() {
        // TODO: Label setup here
    }
}

// MARK: Data Source Setup
extension HomeScreenViewController {
    private func setupDataSource() {
        // TODO: DataSource setup here
    }
}

// MARK: Table View Setup
extension HomeScreenViewController {
    private func setupTableView() {
        // TODO: Setup Table View here setup here
    }
}

// MARK: Navigation logic for each type here
extension HomeScreenViewController {
    // TODO: Create navigation functions to essentially switch the tab bar on the tab bar view controller
}

