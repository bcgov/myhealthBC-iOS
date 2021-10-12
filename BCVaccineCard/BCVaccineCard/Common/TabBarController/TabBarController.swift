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
        let tabBarImage: UIImage
        let baseViewController: UIViewController
    }
    
    var properties: Properties? {
        switch self {
        case .healthPass:
            return Properties(title: .healthPass, tabBarImage: #imageLiteral(resourceName: "my-cards-tab"), baseViewController: HealthPassViewController.constructHealthPassViewController())
        case .records:
            return nil
        case .resource:
            return Properties(title: .resource, tabBarImage: #imageLiteral(resourceName: "resource-tab"), baseViewController: ResourceViewController.constructResourceViewController())
        case .booking:
            return nil
        case .newsFeed:
            return Properties(title: .newsFeed, tabBarImage: #imageLiteral(resourceName: "news-feed-tab"), baseViewController: NewsFeedViewController.constructNewsFeedViewController())
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    private func setup() {
        self.tabBar.tintColor = AppColours.appBlue
        self.tabBar.barTintColor = .white
        self.delegate = self
        self.viewControllers = setViewControllers(withVCs: [.healthPass, .resource, .newsFeed])
        self.selectedIndex = 0
        setupObserver()
    }
    
    private func setViewControllers(withVCs vcs: [TabBarVCs]) -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        vcs.forEach { vc in
            guard let properties = vc.properties else { return }
            let tabBarItem = UITabBarItem(title: properties.title, image: properties.tabBarImage, selectedImage: properties.tabBarImage)
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
    }
    
    @objc private func tabChanged(_ notification: Notification) {
        guard let viewController = (notification.userInfo?["viewController"] as? CustomNavigationController)?.visibleViewController else { return }
        if viewController is NewsFeedViewController {
            NotificationCenter.default.post(name: .reloadNewsFeed, object: nil, userInfo: nil)
        }
    }

}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        NotificationCenter.default.post(name: .tabChanged, object: nil, userInfo: ["viewController": viewController])
    }
    
}
