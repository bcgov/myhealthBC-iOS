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
        
        let authManager: AuthManager
        let network: Network
        let configService: MobileConfigService
        let pdfService: PDFService
        let patientService: PatientService
        
        init(authManager: AuthManager, network: Network, configService: MobileConfigService) {
            self.network = network
            self.configService = configService
            self.authManager = authManager
            self.pdfService = PDFService(network: network, authManager: authManager, configService: configService)
            self.patientService = PatientService(network: network, authManager: authManager, configService: configService)
            AppStates.shared.listenToAuth {[weak self] authenticated in
                guard let `self` = self else {return}
                if let handler = refreshNotifier {
                    handler()
                }
            }
            
            AppStates.shared.listenToStorage {[weak self] event in
                guard let `self` = self else {return}
                if event.event == .Save,
                    event.entity == .OrganDonorStatus
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
