//
//  ProtectedWordStorageService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-12-22.
//

import Foundation

class SessionStorage {
    // If protective word was entered and validated in this session
    static var protectiveWordEnteredThisSession = false
    // Last time Local Authentication was shown to user
    static var lastLocalAuth: Date? = nil
    
    /* This flag lets AuthenticatedHealthRecordsAPIWorker
     know if protectiveWordEnteredThisSession
     should be set to true after succesfull fetch
     using stored protective word
     */
    static var attemptingProtectiveWord = false
    
}
