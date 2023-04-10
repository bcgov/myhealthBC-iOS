//
//  ServicesViewModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-04-10.
//

import Foundation

extension ServicesViewController {
    class ViewModel {
        enum State {
            case Authenticated
            case AuthenticationExpired
            case UnAuthenticated
        }
        
        var currentState: State {
            switch authManager.authStaus {
            case .Authenticated:
                return .Authenticated
            case .AuthenticationExpired:
                return .AuthenticationExpired
            case .UnAuthenticated:
                return .UnAuthenticated
            }
        }
        
        private var refreshNotifier: (()->Void)?
        
        private let authManager: AuthManager
        
        init(authManager: AuthManager) {
            self.authManager = authManager
            AppStates.shared.listenToAuth {[weak self] authenticated in
                guard let `self` = self else {return}
                if let handler = refreshNotifier {
                    handler()
                }
            }
            
            AppStates.shared.listenToStorage {[weak self] event in
                guard let `self` = self else {return}
                // TODO: listen to the correct entity
                if event.event == .Save &&
                    (event.entity == .Patient ||
                    event.entity == .OrganDonorStatus )
                {
                    if let handler = refreshNotifier {
                        handler()
                    }
                }
            }
        }
        
        func listenToChanges(onChange: @escaping()->Void) {
            refreshNotifier = onChange
        }
    }
}
