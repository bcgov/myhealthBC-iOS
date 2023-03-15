//
//  AppTabs.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-09.
//

import UIKit

protocol TabDelegate {
    func switchTo(tab: AppTabs)
}

enum AppTabs: Int, CaseIterable {
    case Home = 0, UnAuthenticatedRecords, AuthenticatedRecords, Proofs, Dependents
    
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
            return Properties(title: "Service Finder",
                              selectedTabBarImage: UIImage(named: "passes-tab-selected")!,
                              unselectedTabBarImage: UIImage(named: "passes-tab-unselected")!,
                              baseViewController: HealthPassViewController.construct(viewModel: vm))
            
        case .Dependents:
            let vm = DependentsHomeViewController.ViewModel(patient: patient)
            return Properties(title: "Service Finder",
                              selectedTabBarImage: UIImage(named: "dependent-tab-selected")!,
                              unselectedTabBarImage: UIImage(named: "dependent-tab-unselected")!,
                              baseViewController: DependentsHomeViewController.construct(viewModel: vm))
            
        case .UnAuthenticatedRecords:
            return Properties(title: "Records",
                              selectedTabBarImage: UIImage(named: "records-tab-selected")!,
                              unselectedTabBarImage: UIImage(named: "records-tab-unselected")!,
                              baseViewController: HealthRecordsViewController.construct())
            
        case .AuthenticatedRecords:
            let vm = UsersListOfRecordsViewController.ViewModel(patient: patient, authenticated: patient?.authenticated ?? false)
            return Properties(title: "Records",
                              selectedTabBarImage: UIImage(named: "records-tab-selected")!,
                              unselectedTabBarImage: UIImage(named: "records-tab-unselected")!,
                              baseViewController: UsersListOfRecordsViewController.construct(viewModel: vm))
        }
        return nil
    }
    
}
