//
//  SyncService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-02-14.
// TODO: Put toast messages in strings file

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
        MobileConfigService(network: network).fetchConfig(forceNetworkRefetch: true) { config in
            guard let config = config, config.online else {
                return completion(nil)
            }
            
//            Defaults.enabledTypes = config.getEnabledTypes()
            // Submit comments before removing all records
            let commentsService = CommentService(network: network, authManager: authManager, configService: configService)
            commentsService.submitUnsyncedComments {
                // Remove authenticated patient records
                // TODO: Figure out how to keep local notes here....
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
        let notificationService = NotificationService(network: network, authManager: authManager, configService: configService)
        if showToast {
            network.showToast(message: .retrievingRecords)
        }
        AppDelegate.sharedInstance?.cachedCommunicationPreferences = nil
        patientService.fetchAndStoreDetails { patient in
            guard let patient = patient else {
                // Could not fetch patient details
                Logger.log(string: .noPatientDetails, type: .Network)
                return completion(nil)
            }
            var hadFailures = false
            let group = DispatchGroup()
            
            group.enter()
            patientService.fetchAndStoreOrganDonorStatus(for: patient) { status in
                if status == nil {
                    hadFailures = true
                }
                Logger.log(string: "\(String.fetchedDonorStatus) \(status != nil)", type: .Network)
                group.leave()
            }
            
            if Defaults.enabledTypes?.contains(dataset: .DiagnosticImaging) == true {
                group.enter()
                patientService.fetchAndStoreDiagnosticImaging(for: patient) { imaging in
                    if imaging == nil {
                        hadFailures = true
                    }
                    Logger.log(string: "\(String.fetchedDiagnosticImaging) \(imaging?.count)", type: .Network)
                    group.leave()
                }
            }
            
            group.enter()
            dependentService.fetchDependents(for: patient) { dependents in
                if dependents == nil {
                    hadFailures = true
                }
                Logger.log(string: "\(String.fetched) \(dependents?.count ?? 0) \(String.dependents.lowercased())", type: .Network)
                group.leave()
            }
            
            group.enter()
            recordsService.fetchAndStore(for: patient, protectiveWord: protectiveWord) { records, hadFails in
                if hadFails {
                    hadFailures = true
                }
                
                if HealthRecordConstants.commentsEnabled {
                    commentsService.fetchAndStore(for: patient) { comments in
                        Logger.log(string: "\(String.fetched) \(comments.count) \(String.comments.lowercased())", type: .Network)
                        group.leave()
                    }
                } else {
                    group.leave()
                }
                Logger.log(string: "\(String.fetched) \(records.count) \(String.records.lowercased())", type: .Network)
            }
            
//            group.enter()
//            notificationService.fetchAndStore(for: patient, loadingStyle: .SyncingRecords) { notifications in
//                Logger.log(string: "fetched \(notifications.count) notification", type: .Network)
//                group.leave()
//            }
            
            group.notify(queue: .main) {
                let message: String = !hadFailures ? .recordsRetrieved : .fetchRecordError
                
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
