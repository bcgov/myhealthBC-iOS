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
    private var iPadSideMenu: iPadSideTabTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // TODO: Set configuration for side menu, and app tab bar - hide/remove and show/add side tab bar controller based on onboarding screen or not
    private func configure() {
        delegate = self
        preferredDisplayMode = .oneBesideSecondary
        if #available(iOS 14.0, *) {
            preferredSplitBehavior = .tile
        }
        presentsWithGesture = false
        
        guard let authManager = authManager,
              let syncService = syncService,
              let networkService = networkService,
              let configService = configService
            else {
            showToast(message: "Fatal Error")
            return
        }
        appTabBar = AppTabBarController.construct(authManager: authManager, syncService: syncService, networkService: networkService, configService: configService)
        
        iPadSideMenu = iPadSideTabTableViewController.construct()
        
        guard let iPadSideMenu = iPadSideMenu, let appTabBar = appTabBar else { return }
        self.viewControllers = [iPadSideMenu, appTabBar]
        if #available(iOS 14.0, *) {
            self.preferredPrimaryColumnWidth = 92
        } else {
            self.preferredPrimaryColumnWidthFraction = 92/self.view.frame.width
        }
        setupListeners()
    }
    
    private func setupListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustIPadSideTab), name: .adjustIPadSideTab, object: nil)
    }
    
    @objc private func adjustIPadSideTab(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Bool] else { return }
        guard let hidden = userInfo["hide"] else { return }
        if #available(iOS 14.0, *) {
            if hidden {
                hide(.primary)
            } else {
                show(.primary)
            }
        } else {
            iPadSideMenu?.adjustUserInteraction(enabled: !hidden)
        }
    }

}

extension iPadParentSplitViewController: UISplitViewControllerDelegate {
    
}
