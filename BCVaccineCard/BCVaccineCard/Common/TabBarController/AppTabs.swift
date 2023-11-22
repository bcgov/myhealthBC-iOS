//
//  AppTabs.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-09.
//
// FIXME: NEED TO LOCALIZE 
import UIKit

protocol TabDelegate {
    func switchTo(tab: AppTabs)
    func showLogin()
    
}

enum AppTabs: Int, CaseIterable {
    case Home = 0, UnAuthenticatedRecords, AuthenticatedRecords, Services, Proofs, Dependents
    
    var getIndexOfTab: Int {
        return self.rawValue
    }
    
    var getIPadIconSelected: UIImage? {
        switch self {
        case .Home: return UIImage(named: "iPad-home-selected")
        case .UnAuthenticatedRecords, .AuthenticatedRecords: return UIImage(named: "iPad-records-selected")
        case .Services: return UIImage(named: "iPad-services-selected")
        case .Proofs: return nil
        case .Dependents: return UIImage(named: "iPad-dependent-selected")
        }
    }
    
    var getIPadIconUnselected: UIImage? {
        switch self {
        case .Home: return UIImage(named: "iPad-home-unselected")
        case .UnAuthenticatedRecords, .AuthenticatedRecords: return UIImage(named: "iPad-records-unselected")
        case .Services: return UIImage(named: "iPad-services-unselected")
        case .Proofs: return nil
        case .Dependents: return UIImage(named: "iPad-dependent-unselected")
        }
    }
    
    var getIPadText: String? {
        switch self {
        case .Home: return "Home"
        case .UnAuthenticatedRecords, .AuthenticatedRecords: return "Records"
        case .Services: return "Service"
        case .Proofs: return nil
        case .Dependents: return "Dependent"
        }
    }

    struct Properties {
        let title: String
        let selectedTabBarImage: UIImage
        let unselectedTabBarImage: UIImage
        let baseViewController: UIViewController
    }
    
    func properties(delegate: TabDelegate,
                    authManager: AuthManager,
                    syncService: SyncService,
                    networkService: Network,
                    configService: MobileConfigService,
                    patient: Patient?
    ) -> Properties? {
        
        switch self {
        case .Home:
            return Properties(title: "Home",
                              selectedTabBarImage: UIImage(named: "home-tab-selected")!,
                              unselectedTabBarImage:  UIImage(named: "home-tab-unselected")!,
                              baseViewController: HomeScreenViewController.construct())
            
        case .Proofs:
            let vm = HealthPassViewController.ViewModel(fedPassStringToOpen: nil)
            return Properties(title: "Proofs",
                              selectedTabBarImage: UIImage(named: "passes-tab-selected")!,
                              unselectedTabBarImage: UIImage(named: "passes-tab-unselected")!,
                              baseViewController: HealthPassViewController.construct(viewModel: vm))
            
        case .Dependents:
            let vm = DependentsHomeViewController.ViewModel(patient: patient)
            return Properties(title: "Dependents",
                              selectedTabBarImage: UIImage(named: "dependent-tab-selected")!,
                              unselectedTabBarImage: UIImage(named: "dependent-tab-unselected")!,
                              baseViewController: DependentsHomeViewController.construct(viewModel: vm))
            
        case .UnAuthenticatedRecords:
            return Properties(title: "Records",
                              selectedTabBarImage: UIImage(named: "records-tab-selected")!,
                              unselectedTabBarImage: UIImage(named: "records-tab-unselected")!,
                              baseViewController: HealthRecordsViewController.construct())
            
        case .AuthenticatedRecords:
            let vm = UsersListOfRecordsViewController.ViewModel(patient: patient, authenticated: patient?.authenticated ?? false, userType: .PrimaryPatient)
            return Properties(title: "Records",
                              selectedTabBarImage: UIImage(named: "records-tab-selected")!,
                              unselectedTabBarImage: UIImage(named: "records-tab-unselected")!,
                              baseViewController: UsersListOfRecordsViewController.construct(viewModel: vm))
        case .Services:
            let vm = ServicesViewController.ViewModel(authManager: authManager, network: networkService, configService: configService)
            return Properties(title: "Services",
                              selectedTabBarImage: UIImage(named: "services-tab-selected")!,
                              unselectedTabBarImage: UIImage(named: "services-tab-unselected")!,
                              baseViewController: ServicesViewController.construct(viewModel: vm))
        }
    }
    
    // TODO: Adjust this function for split screen VC
    func iPadSplitVC(delegate: TabDelegate,
                    authManager: AuthManager,
                    syncService: SyncService,
                    networkService: Network,
                    configService: MobileConfigService,
                    patient: Patient?
    ) -> UIViewController? {
        
        switch self {
        case .Home:
            let masterVCRoot = HomeScreenViewController.construct()
            let masterVC = CustomNavigationController.init(rootViewController: masterVCRoot)
            var secondaryVC: CustomNavigationController?
            if let patient = patient {
                let vm = NotificationsViewController.ViewModel.init(patient: patient, network: networkService, authManager: authManager, configService: configService)
                let notificationVC = NotificationsViewController.construct(viewModel: vm)
                secondaryVC = CustomNavigationController.init(rootViewController: notificationVC)
            } else {
                secondaryVC = nil
            }
//            return ReusableSplitViewController.construct(masterVC: masterVC, secondaryVC: secondaryVC)
            return masterVC
            
        case .Proofs:
            return nil
        case .Dependents:
            let vm = DependentsHomeViewController.ViewModel(patient: patient)
            let masterVCRoot = DependentsHomeViewController.construct(viewModel: vm)
            let masterVC = CustomNavigationController.init(rootViewController: masterVCRoot)
//            return ReusableSplitViewController.construct(masterVC: masterVC, secondaryVC: nil)
            return masterVC
        case .UnAuthenticatedRecords:
            let masterVCRoot = HealthRecordsViewController.construct()
            let masterVC = CustomNavigationController.init(rootViewController: masterVCRoot)
//            return ReusableSplitViewController.construct(masterVC: masterVC, secondaryVC: nil)
            return masterVC
        case .AuthenticatedRecords:
            let vm = UsersListOfRecordsViewController.ViewModel(patient: patient, authenticated: patient?.authenticated ?? false, userType: .PrimaryPatient)
            let masterVCRoot = UsersListOfRecordsViewController.construct(viewModel: vm)
            let masterVC = CustomNavigationController.init(rootViewController: masterVCRoot)
//            return ReusableSplitViewController.construct(masterVC: masterVC, secondaryVC: nil)
            return masterVC
        case .Services:
            let vm = ServicesViewController.ViewModel(authManager: authManager, network: networkService, configService: configService)
            let masterVCRoot = ServicesViewController.construct(viewModel: vm)
            let masterVC = CustomNavigationController.init(rootViewController: masterVCRoot)
//            return ReusableSplitViewController.construct(masterVC: masterVC, secondaryVC: nil)
            return masterVC
        }
    }
    
    func iPadSplitVCTest(delegate: TabDelegate,
                    authManager: AuthManager,
                    syncService: SyncService,
                    networkService: Network,
                    configService: MobileConfigService,
                    patient: Patient?
    ) -> UIViewController? {
        
        switch self {
        case .Home:
//            let masterVCRoot = TestViewController.construct(tab: "Home")
//            let masterVC = CustomNavigationController.init(rootViewController: masterVCRoot)
            
            let masterVCRoot = HomeScreenViewController.construct()
            let masterVC = CustomNavigationController.init(rootViewController: masterVCRoot)
            
            return masterVC
            
        case .Proofs, .Dependents, .UnAuthenticatedRecords, .AuthenticatedRecords, .Services:
            return nil
        }
    }
    
}
