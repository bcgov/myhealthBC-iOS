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
        return TabBarVCs.Properties(title: .records, selectedTabBarImage: #imageLiteral(resourceName: "records-tab-selected"), unselectedTabBarImage: #imageLiteral(resourceName: "records-tab-unselected"), baseViewController: FetchHealthRecordsViewController.constructFetchHealthRecordsViewController(hideNavBackButton: true))
    }
    
    private var previousSelectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
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
                } else if event.event == .Save, StorageService.shared.getHeathRecords().count == 1 {
                    // If data was saved and now health records now have exactly 1 item
                    self.resetHealthRecordsTab()
                }
            default:
                break
            }
        }
    }
    
    private func resetHealthRecordsTab() {
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
    }
    
}
