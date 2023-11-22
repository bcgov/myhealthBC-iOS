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
        case .Dependents: return UIImage(named: "iPad-dependents-selected")
        }
    }
    
    var getIPadIconUnselected: UIImage? {
        switch self {
        case .Home: return UIImage(named: "iPad-home-unselected")
        case .UnAuthenticatedRecords, .AuthenticatedRecords: return UIImage(named: "iPad-records-unselected")
        case .Services: return UIImage(named: "iPad-services-unselected")
        case .Proofs: return nil
        case .Dependents: return UIImage(named: "iPad-dependents-unselected")
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
    
}
