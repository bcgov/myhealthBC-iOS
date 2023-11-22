//
//  iPadParentSplitViewController.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-11-20.
//

import UIKit

class iPadParentSplitViewController: UISplitViewController {
    
    class func construct(authManager: AuthManager,
                         syncService: SyncService,
                         networkService: Network,
                         configService: MobileConfigService
    ) -> iPadParentSplitViewController {
        if let vc =  Storyboard.iPadHome.instantiateViewController(withIdentifier: String(describing: iPadParentSplitViewController.self)) as? iPadParentSplitViewController {
            vc.authManager = authManager
            vc.syncService = syncService
            vc.networkService = networkService
            vc.configService = configService
            return vc
        }
        return iPadParentSplitViewController()
    }
    
    private var authManager: AuthManager?
    private var syncService: SyncService?
    private var networkService: Network?
    private var configService: MobileConfigService?
    
    private var appTabBar: AppTabBarController?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // TODO: Set configuration for side menu, and app tab bar - hide/remove and show/add side tab bar controller based on onboarding screen or not
    private func configure() {
        guard let authManager = authManager,
              let syncService = syncService,
              let networkService = networkService,
              let configService = configService
            else {
            showToast(message: "Fatal Error")
            return
        }
        appTabBar = AppTabBarController.construct(authManager: authManager, syncService: syncService, networkService: networkService, configService: configService)
    }
    

}
