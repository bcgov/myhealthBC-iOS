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
    
    public var hasConnection: Bool {
        return reachability?.connection != nil
    }
    
    private init() {
        do {
            reachability = try Reachability()
        } catch {
            reachability = nil
            Logger.log(string: "Unable to start Reachability", type: .Network)
        }
    }
    
    
    public func initListener() {
        guard let reachability = reachability else {
            return
        }

        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                Logger.log(string: "Reachable via WiFi", type: .Network)
            } else {
                Logger.log(string: "Reachable via Cellular", type: .Network)
            }
        }
        reachability.whenUnreachable = { _ in
            Logger.log(string: "Not reachable", type: .Network)
            AppDelegate.sharedInstance?.showToast(message: "No internet connection", style: .Warn)
        }

        do {
            try reachability.startNotifier()
        } catch {
            Logger.log(string: "Unable to start Reachability notifier", type: .Network)
        }

    }
}
