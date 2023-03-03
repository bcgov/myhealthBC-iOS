//
//  ViewModel.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-03.
//

import Foundation


extension UsersListOfRecordsViewController {
    
    struct ViewModel {
        let patient: Patient?
        let authenticated: Bool = true
        let navStyle: NavStyle = .singleUser
        let hasUpdatedUnauthPendingTest = true
        let dataSource: [HealthRecordsDetailDataSource] = []
    }
    enum NavStyle {
        case singleUser
        case multiUser
    }
}
