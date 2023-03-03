//
//  HealthRecordDetailView.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-03-03.
//

import Foundation

extension HealthRecordDetailViewController {
    struct ViewModel {
        let dataSource: HealthRecordsDetailDataSource
        let authenticatedRecord: Bool
        let userNumberHealthRecords: Int
        let patient: Patient?
    }
}
