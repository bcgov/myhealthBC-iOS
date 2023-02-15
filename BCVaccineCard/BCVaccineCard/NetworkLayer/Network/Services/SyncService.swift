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
    
    private var endpoints: UrlAccessor {
        return UrlAccessor()
    }
    
    func performSync(completion: @escaping(Patient?) -> Void) {
        // Network status
        guard NetworkConnection.shared.hasConnection else { return completion(nil) }
        
        // auth
        guard authManager.isAuthenticated else {return completion(nil)}
        
        // check if user has changed - clear protective word
        if let authenticatedPatient = StorageService.shared.fetchAuthenticatedPatient(),
           let storedHDID = authenticatedPatient.hdid,
           storedHDID != authManager.hdid
        {
            authManager.clearMedFetchProtectiveWordDetails()
        }
        
        // API status
        MobileConfigService(network: network).fetchConfig { config in
            guard let config = config, config.online else {
                return completion(nil)
            }
            
            // Submit comments before removing all records
            let commentsService = CommentService(network: network, authManager: authManager)
            commentsService.submitUnsyncedComments {
                // Remove authenticated patient records
                StorageService.shared.deleteAuthenticatedPatient()
                // Fetch
                fetchData(protectiveWord: authManager.protectiveWord, completion: completion)
            }
        }
        
        
    }
    
    private func fetchData(protectiveWord: String?, completion: @escaping(Patient?) -> Void) {
        let patientService = PatientService(network: network, authManager: authManager)
        let dependentService = DependentService(network: network, authManager: authManager)
        let recordsService = HealthRecordsService(network: network, authManager: authManager)
        let commentsService = CommentService(network: network, authManager: authManager)
        
        patientService.fetchAndStoreDetails { patient in
            guard let patient = patient else {
                // Could not fetch patient details
                Logger.log(string: "Could not fetch patient details", type: .Network)
                return completion(nil)
            }
            let group = DispatchGroup()
            
            group.enter()
            dependentService.fetchDependents(for: patient) { dependents in
                Logger.log(string: "fetched \(dependents.count) dependents", type: .Network)
                group.leave()
            }
            
            group.enter()
            recordsService.fetchAndStore(for: patient, protectiveWord: protectiveWord) { records in
                Logger.log(string: "fetched \(records.count) records", type: .Network)
                group.leave()
            }
            
            group.enter()
            commentsService.fetchAndStore(for: patient) { comments in
                Logger.log(string: "fetched \(comments.count) comments", type: .Network)
                group.leave()
            }
            
            group.notify(queue: .main) {
                return completion(patient)
            }
        }
    }
    
}
