//
//  TabBar + UpdateManager.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-02.
//

import Foundation
import StoreKit

extension TabBarController: SKStoreProductViewControllerDelegate{
    func showAppStoreUpdateDialogIfNeeded() {
        guard NetworkConnection().hasConnection else {return}
        UpdateManager(network: AFNetwork()).isUpdateAvailableInStore { [weak self] updateAvailable in
            guard let `self` = self, !UpdateManager.updateDilogShownThisSession else {return}
            UpdateManager.updateDilogShownThisSession = true
            self.alert(title: "New update is available", message: "", buttonOneTitle: "Update Now", buttonOneCompletion: { [weak self] in
                guard let `self` = self else {return}
                self.openStoreAppStore()
            }, buttonTwoTitle: "Later") {
                return
            }
        }
    }
    
    func openStoreAppStore() {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : "1590009068"]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                self?.present(storeViewController, animated: true, completion: nil)
            }
        }
    }
    private func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func checkForAppStoreVersionUpdate() {
        if let tabBar = tabBarController as? TabBarController {
            tabBar.showAppStoreUpdateDialogIfNeeded()
        }
    }
}
