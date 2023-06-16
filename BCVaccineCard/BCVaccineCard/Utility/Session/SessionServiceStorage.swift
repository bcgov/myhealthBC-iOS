//
//  ProtectedWordStorageService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-12-22.
//

import Foundation

class SessionStorage {
    
    // MARK: Protective word
    static var protectiveWordEnteredThisSession: String?
    static var protectiveWordEnabled = false
    
    // MARK: Notification fetch error
    static var notificationFethFilure = false
    
    static var protectiveWordRequired: Bool {
        guard protectiveWordEnabled else {
            return false
        }
        
        // Protecthive word doesnt match
        guard let word = SessionStorage.protectiveWordEnteredThisSession,
              let storedProtectiveWord = AuthManager().protectiveWord,
              word == storedProtectiveWord
        else {
            return true
        }
        
        // Protective word entered is valid
        return false
    }
    
    // MARK: Sync
    static var syncPerformedThisSession = false
    
    // MARK: Auth
    // Last time Local Authentication was shown to user
    static var lastLocalAuth: Date? = nil
    
    // MARK: Deoendent cache
    // Dependent records fetched in this session
    static var dependentRecordsFetched: [Patient] = []
    
    // MARK: On Sign out cleanup
    static func onSignOut() {
        dependentRecordsFetched = []
        protectiveWordEnteredThisSession = nil
        protectiveWordEnabled = false
    }
}
