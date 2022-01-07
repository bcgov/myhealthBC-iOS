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
    let birthdate: Date?
    var numberOfRecords: Int
}


struct HealthRecord {
    public enum Record {
        case Test(CovidLabTestResult)
        case CovidImmunization(VaccineCard)
    }
    
    public let type: Record
    public let patientName: String
    public let birthDate: Date?
    
    init(type: HealthRecord.Record) {
        self.type = type
        switch type {
        case .Test(let test):
            let results = test.resultArray
            birthDate = test.patient?.birthday
            if let first = results.first {
                patientName = first.patientDisplayName ?? ""
                
            } else {
                patientName = ""
            }
        case .CovidImmunization(let card):
            patientName = card.name ?? ""
            birthDate = card.patient?.birthday
        }
    }
}


// MARK: Helpers
extension HealthRecord {
    
    /// Convert to a HealthRecordsDetailDataSource
    /// - Returns: Detail Data Source
    func detailDataSource() -> HealthRecordsDetailDataSource? {
        switch type {
        case .Test(let test):
            return HealthRecordsDetailDataSource(type: .covidTestResultRecord(model: test))
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
        for record in self {
            // TODO: check for birthday too
            if let i = result.firstIndex(where: {$0.userName == record.patientName}) {
                result[i].numberOfRecords += 1
            } else {
                result.append(HealthRecordsDataSource(userName: record.patientName, birthdate: record.birthDate, numberOfRecords: 1))
            }
        }
        return result
    }
    
    func detailDataSource(userName: String, birthDate: Date?) -> [HealthRecordsDetailDataSource] {
        let filtered = self.filter { $0.patientName == userName && $0.birthDate == birthDate }
        return filtered.compactMap({$0.detailDataSource()})
    }
    
    func fetchDetailDataSourceWithID(id: String, recordType: GetRecordsView.RecordType) -> HealthRecordsDetailDataSource? {
        if let index = self.firstIndex(where: { record in
            switch record.type {
            case .Test(let testResult):
                if recordType == .covidTestResult {
                    return testResult.id == id
                }
                return false
            case .CovidImmunization(let immunizationRecord):
                if recordType == .covidImmunizationRecord {
                    return immunizationRecord.id == id
                }
                return false
            }
        }) {
            return self[index].detailDataSource()
        }
        return nil
    }
}
