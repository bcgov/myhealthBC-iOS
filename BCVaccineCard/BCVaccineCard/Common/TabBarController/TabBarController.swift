//
//  TabBarController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-20.
//

import UIKit

enum TabBarVCs {
    case healthPass, records, checker, booking, notifications
    
    struct Properties {
        let title: String
        let tabBarImage: UIImage
        let baseViewController: UIViewController
    }
    
    var properties: Properties? {
        switch self {
        case .healthPass:
            return Properties(title: Constants.Strings.MyCardFlow.tabBarTitle, tabBarImage: #imageLiteral(resourceName: "my-cards-tab"), baseViewController: CardsBaseViewController.constructCardsBaseViewController())
        case .records:
            return nil
        case .checker:
            return nil
        case .booking:
            return nil
        case .notifications:
            return nil
        }
    }
}

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    private func setup() {
        self.tabBar.tintColor = AppColours.appBlue
        self.tabBar.barTintColor = .white
        self.delegate = self
        self.viewControllers = setViewControllers(withVCs: [.healthPass])
        self.selectedIndex = 0
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

}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Tab Bar tab was tapped here
    }
    
}
