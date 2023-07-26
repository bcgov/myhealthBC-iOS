//
//  ManageHomeScreenViewModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-07-26.
//

import Foundation

extension ManageHomeScreenViewController {
    struct ViewModel {
        let dataSource: DataSource
    }
    
    enum DataSource {
        case introText(text: String)
        case healthRecord(types: [QuickLinksPreference])
        case service(types: [QuickLinksPreference])
    }
}
