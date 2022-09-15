//
//  Reachability.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-06-01.
//

import Foundation
import Reachability

class NetworkConnection {
    public static let shared = NetworkConnection()
    
    private let reachability: Reachability?
    
    private var onChange: ((_ connected: Bool)->Void)?
    
    public var hasConnection: Bool {
        if let connection = reachability?.connection {
            return connection != .unavailable
        } else {
            return false
        }
    }
    
    init() {
        do {
            reachability = try Reachability()
        } catch {
            reachability = nil
            Logger.log(string: "Unable to start Reachability", type: .Network)
        }
    }
    
    
    public func initListener(onChange: @escaping(_ connected: Bool) -> Void) {
        self.onChange = onChange
        guard let reachability = reachability else {
            return
        }

        reachability.whenReachable = { [weak self] reachability in
            if reachability.connection == .wifi {
                Logger.log(string: "Reachable via WiFi", type: .Network)
            } else {
                Logger.log(string: "Reachable via Cellular", type: .Network)
            }
            guard let `self` = self, let notifier = self.onChange else {return}
            notifier(true)
        }
        reachability.whenUnreachable = { [weak self] _ in
            
            Logger.log(string: "Not reachable", type: .Network)
            AppDelegate.sharedInstance?.showToast(message: "No internet connection", style: .Warn)
            guard let `self` = self,let  notifier = self.onChange else {return}
            notifier(false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            Logger.log(string: "Unable to start Reachability notifier", type: .Network)
        }

    }
}
