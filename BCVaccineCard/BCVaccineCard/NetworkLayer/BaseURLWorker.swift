//
//  BaseURLWorker.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-05-24.
//

import UIKit

class BaseURLWorker {
    public static let shared = BaseURLWorker()
    private var apiClient: APIClient
    private var executingVC: UIViewController
    var baseURL: URL?
    var isOnline: Bool?
    
    struct Config {
        var delegateOwner: UIViewController
    }
    private static var config: Config?
    
    class func setup(_ config: Config) {
        BaseURLWorker.config = config
    }
    
    private init() {
        guard let config = BaseURLWorker.config else {
            fatalError("You have to setup the BaseURLWorker apiClient before using BaseURLWorker.shared!")
        }
        self.apiClient = APIClient(delegateOwner: config.delegateOwner)
        self.executingVC = config.delegateOwner
    }
    
    func setBaseURL(completion: @escaping () -> Void) {
        let queueItTokenCached = Defaults.cachedQueueItObject?.queueitToken
        
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.incrementLoader(message: .FetchingConfig)
            }
        }
        
        self.apiClient.getBaseURLFromMobileConfig(token: queueItTokenCached, executingVC: self.executingVC, includeQueueItUI: false) { baseURLString, online in
            if let baseURLString = baseURLString, let url = URL(string: baseURLString) {
                self.baseURL = url
                self.isOnline = online
            }
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.decrementLoader()
                }
            }
            completion()
        }
    }
}
