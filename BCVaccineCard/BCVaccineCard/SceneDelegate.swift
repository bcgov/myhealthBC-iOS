//
//  SceneDelegate.swift
//  BCVaccineCard
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // Populated by UIKit from UISceneStoryboardFile before scene(_:willConnectTo:options:) is called
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard scene is UIWindowScene,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }
        appDelegate.attach(window: window)
        
        if let url = connectionOptions.urlContexts.first?.url {
            appDelegate.handleOpenURL(url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }
        appDelegate.handleOpenURL(url)
    }
}
