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


struct HealthRecord {
    public enum Record {
        case Test(TestResult)
        case CovidImmunization(VaccineCard)
        
        fileprivate func patientName() -> String? {
            switch self {
            case .Test(let test):
                return test.patientDisplayName
            case .CovidImmunization(let card):
                return card.name
            }
        }
    }
    
    public let type: Record
    public var patientName: String? {
        return type.patientName()
    }
}


// MARK: Helpers
extension HealthRecord {
    
    /// Convert to a HealthRecordsDetailDataSource
    /// - Returns: Detail Data Source
    func detailDataSource() -> HealthRecordsDetailDataSource? {
        switch type {
        case .Test(let test):
            guard let model = test.toLocal() else {return nil}
            return HealthRecordsDetailDataSource(type: .covidTestResult(model: model))
        case .CovidImmunization(let covidImmunization):
            guard let model = covidImmunization.toLocal() else {return nil}
            return HealthRecordsDetailDataSource(type: .covidImmunizationRecord(model: model, immunizations: covidImmunization.immunizations))
        }
    }
}

extension Array where Element == HealthRecord {
    
    /// Convert array of HealthRecord to HealthRecordsDataSource
    /// - Returns: Array of Detail Data Source
    func dataSource() -> [HealthRecordsDataSource] {
        var result: [HealthRecordsDataSource] = []
        for record in self where record.patientName != nil {
            // TODO: check for birthday too
            if let i = result.firstIndex(where: {$0.userName == record.patientName}) {
                result[i].numberOfRecords += 1
            } else {
                result.append(HealthRecordsDataSource(userName: record.patientName ?? "", numberOfRecords: 1))
            }
        }
        return result
    }
    
    func detailDataSource(userName: String) -> [HealthRecordsDetailDataSource] {
        let filtered = self.filter { $0.patientName ?? "" == userName }
        return filtered.compactMap({$0.detailDataSource()})
    }
}
