//
//  ViewModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-03.
//

import Foundation


extension UsersListOfRecordsViewController {
    
    enum UserType {
        case PrimaryPatient
        case Dependent
    }
    
    struct ViewModel {
        var patient: Patient?
        let authenticated: Bool
        let navStyle: NavStyle = .singleUser
        let hasUpdatedUnauthPendingTest = true
        let dataSource: [HealthRecordsDetailDataSource] = []
        let userType: UserType
        
        var state: State {
            if AuthManager().isAuthenticated {
                return .authenticated
            }
            if AuthManager().authToken != nil {
                return .AuthExpired
            }
            return .AuthExpired
        }
        
        var protectiveWordRequired: Bool {
            return SessionStorage.protectiveWordRequired && !(patient?.isDependent() ??  true)
        }
        
        var showProtectiveWordPrompt: Bool {
            return protectiveWordRequired
        }
        
        
    }
    
    enum NavStyle {
        case singleUser
        case multiUser
    }
    
    enum State {
        case AuthExpired
        case authenticated
    }
}
