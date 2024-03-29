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
