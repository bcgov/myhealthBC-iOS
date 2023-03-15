//
//  Routes.swift
//  HealthGatewayTest
//
//  Created by Amir Shayegh on 2023-03-03.
//

import UIKit

// MARK: Special Routing
extension UIViewController {
    
    func showLogin(initialView: AuthenticationViewController.InitialView,
                   completion: @escaping (AuthenticationViewController.AuthenticationStatus)->Void
    ) {
        let authSetvice = AppDelegate.sharedInstance?.authManager ?? AuthManager()
        let ConfigService = AppDelegate.sharedInstance?.configService ?? MobileConfigService(network: AFNetwork())
        let viewModel: AuthenticationViewController.ViewModel = AuthenticationViewController.ViewModel(initialView: initialView,
                                                                                                       configService: ConfigService,
                                                                                                       authManager: authSetvice,
                                                                                                       completion: completion)
        guard let controller = createController(route: .Authentication, viewModel: viewModel) else {
            return
        }
        present(controller, animated: true)
    }
}

// MARK: Routes
/**
 To add a new ViewController/Route:
 - Add route to Route enum
 - Create ViewController and ViewModel if needed
 - Add new route enum case in createController
 */
extension UIViewController {
    
    enum Route {
        case Home
        case Recommendations
        case Authentication
        case Settings
        case Profile
        case HealthPass
        case CovidVaccineCards
        case QRRetrievalMethod
        case GatewayForm
        case UsersListOfRecords
        case HealthRecordDetail
        case Resource
        case NewsFeed
        case DependentsHome
        case AddDependent
        case ManageDependents
        case DependentInfo
        case Comments
        case SecurityAndData
    }
    
    fileprivate func createController(route: Route, viewModel: Any? = nil) -> UIViewController? {
        let controller: UIViewController?
        switch route {
        case .Home:
            return HomeScreenViewController.construct()
        case .Recommendations:
            return RecommendationsViewController.construct()
        case .Authentication:
            guard let vm = viewModel as? AuthenticationViewController.ViewModel else {
                return nil
            }
            return AuthenticationViewController.construct(viewModel: vm)
        case .Settings:
            return ProfileAndSettingsViewController.construct()
        case .Profile:
            guard let vm = viewModel as? ProfileDetailsViewController.ViewModel else {
                return nil
            }
            return ProfileDetailsViewController.construct(viewModel: vm)
        case .HealthPass:
            guard let vm = viewModel as? HealthPassViewController.ViewModel else {
                return nil
            }
            return HealthPassViewController.construct(viewModel: vm)
        case .CovidVaccineCards:
            guard let vm = viewModel as? CovidVaccineCardsViewController.ViewModel else {
                return nil
            }
            return CovidVaccineCardsViewController.construct(viewModel: vm)
        case .QRRetrievalMethod:
            return QRRetrievalMethodViewController.construct()
        case .UsersListOfRecords:
            guard let vm = viewModel as? UsersListOfRecordsViewController.ViewModel else {
                return nil
            }
            return UsersListOfRecordsViewController.construct(viewModel: vm)
        case .HealthRecordDetail:
            guard let vm = viewModel as? HealthRecordDetailViewController.ViewModel else {
                return nil
            }
            return HealthRecordDetailViewController.construct(viewModel: vm)
        case .Resource:
            return ResourceViewController.construct()
        case .NewsFeed:
            return NewsFeedViewController.construct()
        case .DependentsHome:
            guard let vm = viewModel as? DependentsHomeViewController.ViewModel else {
                return nil
            }
            return DependentsHomeViewController.construct(viewModel: vm)
        case .AddDependent:
            guard let vm = viewModel as? AddDependentViewController.ViewModel else {
                return nil
            }
            return AddDependentViewController.construct(viewModel: vm)
        case .ManageDependents:
            guard let vm = viewModel as? ManageDependentsViewController.ViewModel else {
                return nil
            }
            return ManageDependentsViewController.construct(viewModel: vm)
        case .DependentInfo:
            guard let vm = viewModel as? DependentInfoViewController.ViewModel else {
                return nil
            }
            return DependentInfoViewController.construct(viewModel: vm)
        case .Comments:
            guard let vm = viewModel as? CommentsViewController.ViewModel else {
                return nil
            }
            return CommentsViewController.construct(viewModel: vm)
        case .SecurityAndData:
            return SecurityAndDataViewController.construct()
        case .GatewayForm:
            guard let vm = viewModel as? GatewayFormViewController.ViewModel else {
                return nil
            }
            return GatewayFormViewController.construct(viewModel: vm)
        }
        return controller
    }
}


// MARK: General Routing
extension UIViewController {
    
    func show(tab: AppTabs) {
        // TODO: Adjust if tabs need to be switched from VC whose parent is nav controller
        guard let tabBar = self.tabBarController as? AppTabBarController else {
            return
        }
        
        tabBar.switchTo(tab: tab)
    }
    
    func show(route: Route, withNavigation: Bool, viewModel: Any? = nil) {
        guard let controller = createController(route: route, viewModel: viewModel) else {
            return
        }
        show(controller: controller, withNavigation: withNavigation)
    }
    
    func show(controller: UIViewController, withNavigation: Bool) {
        // No navigation
        if !withNavigation {
            present(controller, animated: true)
            return
        }
        // Add to existing navigation flow
        if navigationController != nil {
            controller.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(controller, animated: true)
            return
        } else {
            // New navigation flow
            let navigationController = UINavigationController(rootViewController: controller)
            controller.modalPresentationStyle = .fullScreen
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
            return
        }
    }
    
    func dismiss() {
        if self.parent is UINavigationController, let navController = navigationController {
            navController.dismiss(animated: true)
            return
        } else {
            self.dismiss(animated: true)
        }
    }
}
