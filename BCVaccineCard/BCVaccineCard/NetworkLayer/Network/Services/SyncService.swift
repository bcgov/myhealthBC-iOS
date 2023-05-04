//
//  SyncService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-02-14.
//

import Foundation

struct SyncService {
    
    let network: Network
    let authManager: AuthManager
    let configService: MobileConfigService
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    func performSync(showToast: Bool, completion: @escaping(Patient?) -> Void) {
        // Network status
        guard NetworkConnection.shared.hasConnection else { return completion(nil) }
        
        // auth
        guard authManager.isAuthenticated else {return completion(nil)}
        
        // check if user has changed - clear protective word
        if let authenticatedPatient = StorageService.shared.fetchAuthenticatedPatient(),
           let storedHDID = authenticatedPatient.hdid,
           storedHDID != authManager.hdid
        {
            authManager.removeProtectiveWord()
            SessionStorage.onSignOut()
        }
        
        SessionStorage.syncPerformedThisSession = true
        
        // API status
        MobileConfigService(network: network).fetchConfig { config in
            guard let config = config, config.online else {
                return completion(nil)
            }
            
            // Submit comments before removing all records
            let commentsService = CommentService(network: network, authManager: authManager, configService: configService)
            commentsService.submitUnsyncedComments {
                // Remove authenticated patient records
                StorageService.shared.deleteAuthenticatedPatient()
                // Fetch
                fetchData(protectiveWord: authManager.protectiveWord, showToast: showToast, completion: { result in
                    NotificationCenter.default.post(name: .syncPerformed, object: nil, userInfo: nil)
                    return completion(result)
                })
            }
        }
    }
    
    private func fetchData(protectiveWord: String?, showToast: Bool, completion: @escaping(Patient?) -> Void) {
        let patientService = PatientService(network: network, authManager: authManager, configService: configService)
        let dependentService = DependentService(network: network, authManager: authManager, configService: configService)
        let recordsService = HealthRecordsService(network: network, authManager: authManager, configService: configService)
        let commentsService = CommentService(network: network, authManager: authManager, configService: configService)
        if showToast {
            network.showToast(message: "Retrieving records")
        }
        patientService.fetchAndStoreDetails { patient in
            guard let patient = patient else {
                // Could not fetch patient details
                Logger.log(string: "Could not fetch patient details", type: .Network)
                return completion(nil)
            }
            var hadFailures = false
            let group = DispatchGroup()
            
            group.enter()
            patientService.fetchAndStoreOrganDonorStatus(for: patient) { status in
                if status == nil {
                    hadFailures = true
                }
                Logger.log(string: "fetched donor status: \(status != nil)", type: .Network)
                group.leave()
            }
            
            group.enter()
            dependentService.fetchDependents(for: patient) { dependents in
                if dependents == nil {
                    hadFailures = true
                }
                Logger.log(string: "fetched \(dependents?.count ?? 0) dependents", type: .Network)
                group.leave()
            }
            
            group.enter()
            recordsService.fetchAndStore(for: patient, protectiveWord: protectiveWord) { records, hadFails in
                if hadFails {
                    hadFailures = true
                }
                
                if HealthRecordConstants.commentsEnabled {
                    commentsService.fetchAndStore(for: patient) { comments in
                        Logger.log(string: "fetched \(comments.count) comments", type: .Network)
                        group.leave()
                    }
                } else {
                    group.leave()
                }
                Logger.log(string: "fetched \(records.count) records", type: .Network)
            }
            
            group.notify(queue: .main) {
                let message: String = !hadFailures ? "Records retrieved" : .fetchRecordError
                
                if showToast {
                    network.showToast(message: message)
                } else if hadFailures {
                    network.showToast(message: message, style: .Warn)
                }
                
                return completion(patient)
            }
        }
    }
    
}
