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
                   presentationStyle: UIModalPresentationStyle? = nil,
                   showTabOnSuccess: AppTabs? = nil,
                   completion: ((AuthenticationViewController.AuthenticationStatus)->Void)? = nil
    ) {
    
        // Find and display login from the tab bar controller.
        if self is AppTabBarController, let current = self as? AppTabBarController {
            self.showLogin(initialView: initialView,
                             presentationStyle: presentationStyle,
                             showTabOnSuccess: showTabOnSuccess,
                             tabBarController: current,
                             completion: completion)
        } else if let tabBar = self.tabBarController as? AppTabBarController {
            tabBar.showLogin(initialView: initialView,
                             presentationStyle: presentationStyle,
                             showTabOnSuccess: showTabOnSuccess,
                             completion: completion)
        } else if let navigationController = self.navigationController {
            navigationController.showLogin(initialView: initialView,
                                            presentationStyle: presentationStyle,
                                            showTabOnSuccess: showTabOnSuccess,
                                            completion: completion)
        } else {
            self.showLogin(initialView: initialView,
                           presentationStyle: presentationStyle,
                           showTabOnSuccess: showTabOnSuccess,
                           tabBarController: nil,
                           completion: completion)
        }
    }
    
    private func showLogin(initialView: AuthenticationViewController.InitialView,
                   presentationStyle: UIModalPresentationStyle? = nil,
                   showTabOnSuccess: AppTabs? = nil,
                   tabBarController: AppTabBarController?,
                   completion: ((AuthenticationViewController.AuthenticationStatus)->Void)? = nil
    ) {
        guard NetworkConnection.shared.hasConnection else {
            showToast(message: .noInternetConnection, style: .Warn)
            return
        }
  
        let authSetvice = AppDelegate.sharedInstance?.authManager ?? AuthManager()
        let ConfigService = AppDelegate.sharedInstance?.configService ?? MobileConfigService(network: AFNetwork())
        let viewModel: AuthenticationViewController.ViewModel = AuthenticationViewController.ViewModel(
            initialView: initialView,
            configService: ConfigService,
            authManager: authSetvice,
            completion: { result in
                if let completion = completion {
                    completion(result)
                }
                
                if result == .Completed,
                   let showTab = showTabOnSuccess
                {
                    tabBarController?.switchTo(tab: showTab)
                    return
                }
                if result == .Failed {
                    self.showAuthFailed()
                }
            })
        guard let controller = createController(route: .Authentication, viewModel: viewModel) else {
            return
        }
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = presentationStyle ?? .automatic
        }
        
        if let tabBar = self.tabBarController as? AppTabBarController {
            tabBar.present(controller, animated: true)
        } else {
            present(controller, animated: true)
        }
    }
    
    private func showAuthFailed() {
        let vc = AuthenticationFailedViewController.construct()
        present(vc, animated: true)
    }
    
    func showProtectedWordDialog(delegate: ProtectiveWordPromptDelegate, purpose: ProtectiveWordPurpose) {
        let vm = ProtectiveWordPromptViewController.ViewModel(delegate: delegate, purpose: purpose)
        let controller = ProtectiveWordPromptViewController.construct(viewModel: vm)
        if let tabBar = self.tabBarController as? AppTabBarController {
            tabBar.present(controller, animated: true)
        } else {
            present(controller, animated: true)
        }
    }
    
    func sendEmail() {
        let email = "HealthGateway@gov.bc.ca"
        if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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
        case FilterRecordsView
        case HealthRecordDetail
        case Resource
        case NewsFeed
        case DependentsHome
        case AddDependent
        case ManageDependents
        case DependentInfo
        case Comments
        case SecurityAndData
        case TermsOfService
    }
    
    fileprivate func createController(route: Route, viewModel: Any? = nil) -> UIViewController? {
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
            guard let vm = viewModel as? QRRetrievalMethodViewController.ViewModel else {
                return nil
            }
            return QRRetrievalMethodViewController.construct(viewModel: vm)
        case .UsersListOfRecords:
            guard let vm = viewModel as? UsersListOfRecordsViewController.ViewModel else {
                return nil
            }
            return UsersListOfRecordsViewController.construct(viewModel: vm)
        case .FilterRecordsView:
            guard let vm = viewModel as? FilterRecordsViewController.ViewModel else {
                return nil
            }
            return FilterRecordsViewController.construct(viewModel: vm)
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
        case .TermsOfService:
            return TermsOfServiceViewController.construct()
        }
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
    
    func dismiss(then: @escaping()->Void) {
        if self.parent is UINavigationController, let navController = navigationController {
            navController.dismiss(animated: true) {
                return then()
            }
        } else {
            self.dismiss(animated: true) {
                return then()
            }
        }
    }
}
