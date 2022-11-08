//
//  TabBar + UpdateManager.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-02.
//

import Foundation
import StoreKit

extension TabBarController: SKStoreProductViewControllerDelegate, ForceUpdateViewDelegate{
    
    func showAppStoreUpdateDialogIfNeeded() {
        guard NetworkConnection().hasConnection else {return}
        UpdateService(network: AFNetwork()).isUpdateAvailableInStore { [weak self] updateAvailable in
            guard let `self` = self, updateAvailable, !UpdateServiceStorage.updateDilogShownThisSession else {return}
            UpdateServiceStorage.updateDilogShownThisSession = true
            self.alert(title: "New update is available", message: "A new version of the Health Gateway mobile application is available on the app store.", buttonOneTitle: "Update Now", buttonOneCompletion: { [weak self] in
                guard let `self` = self else {return}
                self.openStoreAppStore()
            }, buttonTwoTitle: "Later") {
                return
            }
        }
    }
    
    func showForceUpateIfNeeded(completion: @escaping (Bool)->Void) {
        if NetworkConnection.shared.hasConnection {
            checkForceUpdate(completion: completion)
        } else {
            return completion(false)
        }
    }
    
    fileprivate func checkForceUpdate(completion: @escaping (Bool)->Void) {
        UpdateService(network: AFNetwork()).isBreakingConfigChangeAvailable { available in
            guard available else {return completion(false)}
            ForceUpdateView.show(delegate: self, tabBarController: self)
            return completion(true)
        }
    }
    
    func openStoreAppStore() {
        let appId = "1590009068"
        
        openAppStoreWithStoreKit(appId: appId) { [weak self] success in
            if success { return }
            self?.openAppStoreWithDeeplink(appId: appId)
        }
    }
    
    private func openAppStoreWithStoreKit(appId: String , completion: @escaping(Bool)->Void) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : appId]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                self?.present(storeViewController, animated: true, completion: nil)
                return completion(true)
            } else {
                return completion(false)
            }
        }
    }
    
    private func openAppStoreWithDeeplink(appId: String) {
        if let url  = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
private func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
    viewController.dismiss(animated: true, completion: nil)
}

extension UIViewController {
    func checkForAppStoreVersionUpdate() {
        if let tabBar = tabBarController as? TabBarController {
            tabBar.showAppStoreUpdateDialogIfNeeded()
        } else if let tabBar = self as? TabBarController {
            tabBar.showAppStoreUpdateDialogIfNeeded()
        }
    }
}
