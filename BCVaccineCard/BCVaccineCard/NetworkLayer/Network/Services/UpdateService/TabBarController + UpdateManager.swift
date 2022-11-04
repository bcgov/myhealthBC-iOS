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
            checkForceUpdateWhenConnected()
            return completion(false)
        }
    }
    
    fileprivate func checkForceUpdateWhenConnected() {
        NetworkConnection().initListener { [weak self] connected in
            if connected {
                self?.checkForceUpdate(completion: {_ in })
            }
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
