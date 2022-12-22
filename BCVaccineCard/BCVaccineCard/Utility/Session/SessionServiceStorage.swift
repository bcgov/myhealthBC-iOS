//
//  ProtectedWordStorageService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-12-22.
//

import Foundation

class SessionStorage {
    static var protectiveWordEnteredThisSession = false
    static var lastLocalAuth: Date? = nil
}
