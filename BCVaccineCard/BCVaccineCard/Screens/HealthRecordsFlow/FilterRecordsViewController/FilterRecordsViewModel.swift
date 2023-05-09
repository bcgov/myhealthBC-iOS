//
//  FilterRecordsViewModel.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-05-05.
//

import UIKit

extension FilterRecordsViewController {
    struct ViewModel {
        let currentFilter: RecordsFilter?
        let availableFilters: [RecordsFilter.RecordType]
        let delegateOwner: UIViewController
    }
}
