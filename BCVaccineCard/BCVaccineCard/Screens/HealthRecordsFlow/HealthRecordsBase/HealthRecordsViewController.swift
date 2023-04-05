//
//  HealthRecordsViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-05-06.
//

import UIKit

class HealthRecordsViewController: BaseViewController {
    
    class func construct() -> HealthRecordsViewController {
        if let vc = Storyboard.records.instantiateViewController(withIdentifier: String(describing: HealthRecordsViewController.self)) as? HealthRecordsViewController {
            return vc
        }
        return HealthRecordsViewController()
    }
    
    @IBOutlet weak private var homeRecordsView: HealthRecordsHomeView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
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
        setupView()
//        self.getTabBarController?.scrapeDBForEdgeCaseRecords(authManager: AuthManager(), currentTab: .records)
    }

}

// MARK: Navigation setup
extension HealthRecordsViewController {
    private func navSetup() {
        self.navDelegate?.setNavigationBarWith(title: .healthRecords,
                                               leftNavButton: nil,
                                               rightNavButton: NavButton(image: UIImage(named: "nav-settings"), action: #selector(self.settingsButton), accessibility: Accessibility(traits: .button, label: AccessibilityLabels.MyHealthPassesScreen.navRightIconTitle, hint: AccessibilityLabels.MyHealthPassesScreen.navRightIconHint)),
                                               navStyle: .large,
                                               navTitleSmallAlignment: .Center,
                                               targetVC: self,
                                               backButtonHintString: nil)
        
        
    }
}

// MARK: Login functionality
extension HealthRecordsViewController: AppStyleButtonDelegate {
    private func setupView() {
        homeRecordsView.configure(buttonDelegateOwner: self)
    }
    
    func buttonTapped(type: AppStyleButton.ButtonType) {
        if type == .login {
            self.performBCSCLogin()
        }
    }
    
    private func performBCSCLogin() {
        showLogin(initialView: .Landing, showTabOnSuccess: .AuthenticatedRecords)
    }
}
