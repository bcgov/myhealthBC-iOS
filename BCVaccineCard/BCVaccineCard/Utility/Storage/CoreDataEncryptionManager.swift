//
//  CoreDataEncryptionManager.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-06.
//

import Foundation
import KeychainAccess

class CoreDataEncryptionKeyManager {
    
    private let dbKey: String = "dbKey"
    private let keychain = Keychain(service: "ca.bc.gov.myhealth")
    
    public static let shared = CoreDataEncryptionKeyManager()
    
    public var key: String {
        return getStoredKey() ?? generateKey()
    }
    
    
    private func getStoredKey() -> String? {
        return keychain[dbKey]
    }
    
    private func generateKey() -> String {
        let key = UUID().uuidString
        do {
            try keychain.set(key, key: dbKey)
        }
        catch let error {
            print(error)
        }
        return key
    }
}
