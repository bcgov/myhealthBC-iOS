//
//  HealthRecordsFlowModels.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
//

import Foundation

// MARK: This is the data source used in the collection view on the base health records screen
struct HealthRecordsDataSource {
    let userName: String
//    let birthdate: String // TODO: Will need to implement this after health gateway returns this
    var numberOfRecords: Int
}
