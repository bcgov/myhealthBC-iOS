//
//  TabBarController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-20.
//

import UIKit

enum TabBarVCs {
    case healthPass, records, resource, booking, newsFeed
    
    struct Properties {
        let title: String
        let selectedTabBarImage: UIImage
        let unselectedTabBarImage: UIImage
        let baseViewController: UIViewController
    }
    
    var properties: Properties? {
        switch self {
        case .healthPass:
            return Properties(title: .passes, selectedTabBarImage: #imageLiteral(resourceName: "passes-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "passes-tab-unselected"), baseViewController: HealthPassViewController.constructHealthPassViewController())
        case .records:
            return Properties(title: .records, selectedTabBarImage: #imageLiteral(resourceName: "records-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "records-tab-unselected"), baseViewController: HealthRecordsViewController.constructHealthRecordsViewController())
        case .resource:
            return Properties(title: .resources, selectedTabBarImage: #imageLiteral(resourceName: "resource-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "resource-tab-unselected"), baseViewController: ResourceViewController.constructResourceViewController())
        case .booking:
            return nil
        case .newsFeed:
            return Properties(title: .newsFeed, selectedTabBarImage: #imageLiteral(resourceName: "news-feed-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "news-feed-tab-unselected"), baseViewController: NewsFeedViewController.constructNewsFeedViewController())
        }
    }
}

class TabBarController: UITabBarController {
    
    class func constructTabBarController() -> TabBarController {
        if let vc = Storyboard.main.instantiateViewController(withIdentifier: String(describing: TabBarController.self)) as? TabBarController {
            return vc
        }
        return TabBarController()
    }
    
    fileprivate var addHeathRecords: TabBarVCs.Properties {
        return TabBarVCs.Properties(title: .records, selectedTabBarImage: #imageLiteral(resourceName: "records-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "records-tab-unselected"), baseViewController: FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true, showSettingsIcon: true))
    }
    
    private var previousSelectedIndex: Int?
    private var updateRecordsScreenState = false
    var authWorker: AuthenticatedHealthRecordsAPIWorker?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.authWorker = AuthenticatedHealthRecordsAPIWorker(delegateOwner: self)
        setup(selectedIndex: 0)
    }
    

    private func setup(selectedIndex: Int) {
        self.tabBar.tintColor = AppColours.appBlue
        self.tabBar.barTintColor = .white
        self.delegate = self
        self.viewControllers = setViewControllers(withVCs: [.healthPass, .records, .resource, .newsFeed])
        self.selectedIndex = selectedIndex
        setupObserver()
    }
    
    private func setViewControllers(withVCs vcs: [TabBarVCs]) -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        vcs.forEach { vc in
            guard let properties = (vc == .records && StorageService.shared.getHeathRecords().isEmpty) ? addHeathRecords : vc.properties  else { return }
            let tabBarItem = UITabBarItem(title: properties.title, image: properties.unselectedTabBarImage, selectedImage: properties.selectedTabBarImage)
            tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansBoldWithSize(size: 10)], for: .normal)
            let viewController = properties.baseViewController
            viewController.tabBarItem = tabBarItem
            viewController.title = properties.title
            let navController = CustomNavigationController.init(rootViewController: viewController)
            viewControllers.append(navController)
        }
        return viewControllers
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(tabChanged), name: .tabChanged, object: nil)
        Notification.Name.storageChangeEvent.onPost(object: nil, queue: .main) {[weak self] notification in
            guard let `self` = self, let event = notification.object as? StorageService.StorageEvent<Any> else {return}
            switch event.entity {
            case .VaccineCard, .CovidLabTestResult, .Patient:
                if event.event == .Delete, StorageService.shared.getHeathRecords().isEmpty {
                    // If data was deleted and now health records are empty
                    self.resetHealthRecordsTab()
                }
                if event.event == .Save, StorageService.shared.getHeathRecords().count == 1 {
                    self.updateRecordsScreenState = true
                }
            default:
                break
            }
        }
    }
    
    // This function is called within the tab bar 1.) (when records are deleted and go to zero, called in the listener above), and called when the 2.) health records tab is selected, to appropriately show the correct VC, and is called 3.) on the FetchHealthRecordsViewController in the routing section to apporiately reset the health records tab's vc stack and route to the details screen
    func resetHealthRecordsTab(viewControllersToInclude vcs: [UIViewController]? = nil) {
        let vc: TabBarVCs = .records
        guard let properties = (vc == .records && StorageService.shared.getHeathRecords().isEmpty) ? addHeathRecords : vc.properties  else { return }
        let tabBarItem = UITabBarItem(title: properties.title, image: properties.unselectedTabBarImage, selectedImage: properties.selectedTabBarImage)
        tabBarItem.setTitleTextAttributes([.font: UIFont.bcSansBoldWithSize(size: 10)], for: .normal)
        let viewController = properties.baseViewController
        viewController.tabBarItem = tabBarItem
        viewController.title = properties.title
        let navController = CustomNavigationController.init(rootViewController: viewController)
        let isOnRecordsTab = self.selectedIndex == 1
        viewControllers?.remove(at: 1)
        viewControllers?.insert(navController, at: 1)
        if isOnRecordsTab {
            selectedIndex = 1
            // This portion is used to handle the re-setting of the health records VC stack for proper routing - in order to maintain the correct Navigation UI, we must push the VC's onto the stack (and not set the VC's with .setViewControllers() as this causes issues) - the loading view on the app delegate window is to hide the consecutive pushes to make a smoother UI transition - tested and works
            if let vcs = vcs {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    for vc in vcs {
                        navController.pushViewController(vc, animated: false)
                    }
                    AppDelegate.sharedInstance?.removeLoadingViewHack()
                }
            }
        }
    }
    
    @objc private func tabChanged(_ notification: Notification) {
        guard let viewController = (notification.userInfo?["viewController"] as? CustomNavigationController)?.visibleViewController else { return }
        if viewController is NewsFeedViewController {
            NotificationCenter.default.post(name: .reloadNewsFeed, object: nil, userInfo: nil)
        }
    }

}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Save the previously selected index, so that we can check if the tab was selected again
        self.previousSelectedIndex = tabBarController.selectedIndex
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        NotificationCenter.default.post(name: .tabChanged, object: nil, userInfo: ["viewController": viewController])
        // First we are checking if the health records screen state needs to be updated when a user taps on records tab - this is to handle the case where a user adds a vaccine pass via health pass flow, and we need to reflect the state change in the records tab. This boolean property is being set in a listener above
        if self.selectedIndex == 1 && updateRecordsScreenState {
            updateRecordsScreenState = false
            self.resetHealthRecordsTab()
        } else if self.selectedIndex == 1 && self.previousSelectedIndex == 1 {
            // This is called here to rest the records tab appropriately, when the tab is tapped
            self.resetHealthRecordsTab()
        }
    }
    
}

// MARK: Auth Fetch delegates
extension TabBarController: AuthenticatedHealthRecordsAPIWorkerDelegate {
    func showPatientDetailsError(error: String) {
        self.showBanner(message: error, style: .Bottom)
    }
    
    func showFetchStartedBanner() {
        self.showBanner(message: "Retrieving records", style: .Bottom)
    }
    
    func showFetchCompletedBanner(recordsSuccessful: Int, recordsAttempted: Int, errors: [AuthenticationFetchType : String]?) {
        // TODO: Connor - handle error case
        self.showBanner(message: "\(recordsSuccessful)/\(recordsAttempted) records fetched", style: .Bottom)
    }
}
