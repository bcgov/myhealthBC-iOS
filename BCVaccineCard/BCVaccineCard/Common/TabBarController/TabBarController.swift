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
    private var loadingView: AuthenticatedFetchLoader?
    var authWorker: AuthenticatedHealthRecordsAPIWorker?
    // TODO: Rework this in a future sprint
    var fetchProgress: [AuthenticationFetchType: CGFloat] = [:]
    
    // TODO: Connor 3: Create authenticated API worker in tab bar initialization, which we will call from the authentication component, triggering updates in our listener in this screen

    override func viewDidLoad() {
        super.viewDidLoad()
        self.authWorker = AuthenticatedHealthRecordsAPIWorker(delegateOwner: self)
        setup(selectedIndex: 0)
//        testLoader()
        self.fetchProgress = [
            .VaccineCard: 0.0,
            .TestResults: 0.0
        ]
    }
    

    private func setup(selectedIndex: Int) {
        self.tabBar.tintColor = AppColours.appBlue
        self.tabBar.barTintColor = .white
        self.delegate = self
        self.viewControllers = setViewControllers(withVCs: [.healthPass, .records, .resource, .newsFeed])
        self.selectedIndex = selectedIndex
        setupObserver()
    }
    
//    private func testLoader() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.addCustomLoadingView()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.updateLoadingView(status: "Test", loadingProgress: 0.2)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.updateLoadingView(status: "Test", loadingProgress: 0.4)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        self.updateLoadingView(status: "Test", loadingProgress: 0.75)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            self.updateLoadingView(status: "Test", loadingProgress: 1.0)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                self.removeCustomLoadingView()
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
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
                // TODO: CONNOR 4: Handle authentication data reloads for specific screens here
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

// MARK: Custom Loader for fetching authenticated records
extension TabBarController {
    func addCustomLoadingView() {
        loadingView = AuthenticatedFetchLoader(frame: .zero)
        let bannerHeight: CGFloat = 60
        let closedTopAnchor = 0 - bannerHeight
        let openTopAnchor: CGFloat = 0
        // Position container
        guard let loadingView = self.loadingView else { return }
        self.view.addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        let topContraint = loadingView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: closedTopAnchor)
        loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: bannerHeight).isActive = true
        
        NSLayoutConstraint.activate([topContraint])
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {[weak self] in
            guard let `self` = self else {return}
            topContraint.constant = openTopAnchor
            self.view.layoutIfNeeded()
        }
    }
    
    func updateLoadingView(status: String, loadingProgress: CGFloat?) {
        loadingView?.configure(status: status, loadingProgress: loadingProgress)
    }
    
    func removeCustomLoadingView() {
        UIView.animate(withDuration: 2.0, delay: 2.0, options: .curveEaseOut) {
            self.loadingView?.alpha = 0
            self.loadingView?.layoutIfNeeded()
        } completion: { done in
            self.loadingView?.removeFromSuperview()
        }
    }
    
}

// MARK: Auth Fetch delegates
extension TabBarController: AuthenticatedHealthRecordsAPIWorkerDelegate {
    func openLoader() {
        self.addCustomLoadingView()
    }
    
    func handleDataProgress(fetchType: AuthenticationFetchType, totalCount: Int, completedCount: Int) {
        let progress: CGFloat = CGFloat(completedCount) / CGFloat(totalCount)
//        fetchProgress[fetchType] = progress
//        // For now, this is how we will switch between loading types (as a sync setup was tricky with fetching)
//        if fetchType == .VaccineCard && progress == 1 {
//            self.updateLoadingView(status: fetchType.getName, loadingProgress: progress)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                self.updateLoadingView(status: AuthenticationFetchType.TestResults.getName, loadingProgress: self.fetchProgress[fetchType])
//            }
//        } else if fetchType == .TestResults, let value = fetchProgress[.VaccineCard], value < 1 {
//            // Do nothing here when vaccine card is still fetching
//        } else {
//            self.updateLoadingView(status: fetchType.getName, loadingProgress: progress)
//        }
        
        // For now, only update loading view when loading is completed
        self.updateLoadingView(status: fetchType.getName, loadingProgress: progress)
        
    }
    
    func handleError(fetchType: AuthenticationFetchType, error: String) {
        self.updateLoadingView(status: error, loadingProgress: nil)
    }
    
    func dismissLoader() {
        self.removeCustomLoadingView()
    }
}
