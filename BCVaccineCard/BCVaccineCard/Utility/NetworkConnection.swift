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
    
    private var debounceOnline = false
    private var debounceTimer: Timer? = nil
    
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
            guard let `self` = self, let notifier = self.onChange else {return}
            if self.debounceOnline {return}
            self.debounceOnline = true
            self.debounceTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.resetDebounce), userInfo: nil, repeats: false)
            
            if reachability.connection == .wifi {
                Logger.log(string: "Reachable via WiFi", type: .Network)
            } else {
                Logger.log(string: "Reachable via Cellular", type: .Network)
            }
            notifier(true)
        }
        reachability.whenUnreachable = { [weak self] _ in
            guard let `self` = self,let  notifier = self.onChange else {return}
            Logger.log(string: "Not reachable", type: .Network)
            AppDelegate.sharedInstance?.showToast(message: "No internet connection", style: .Warn)
            notifier(false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            Logger.log(string: "Unable to start Reachability notifier", type: .Network)
        }

    }
    
    @objc fileprivate func resetDebounce() {
        self.debounceOnline = false
    }
}
