//
//  HealthRecordsFlowModels.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
//

import Foundation

// MARK: This is the data source used in the collection view on the base health records screen
struct HealthRecordsDataSource {
    let patient: Patient
    var numberOfRecords: Int
    var authenticated: Bool
}


struct HealthRecord {
    public enum Record {
        case Test(CovidLabTestResult)
        case CovidImmunization(VaccineCard)
    }
    
    public let type: Record
    public let patient: Patient
    public let patientName: String
    public let birthDate: Date?
    
    init(type: HealthRecord.Record) {
        self.type = type
        switch type {
        case .Test(let test):
            let results = test.resultArray
            patient = test.patient!
            birthDate = test.patient?.birthday
            if let first = results.first {
                patientName = first.patientDisplayName ?? ""
                
            } else {
                patientName = ""
            }
        case .CovidImmunization(let card):
            patient = card.patient!
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
    
    var isAuthenticated: Bool {
        switch type {
        case .Test(let test):
            return test.authenticated
        case .CovidImmunization(let covidImmunization):
            return covidImmunization.authenticated
        }
    }
}

extension Array where Element == HealthRecord {
    
    /// Convert array of HealthRecord to HealthRecordsDataSource
    /// - Returns: Array of Detail Data Source
    func dataSource() -> [HealthRecordsDataSource] {
        var result: [HealthRecordsDataSource] = []
        for record in self {
            if let i = result.firstIndex(where: {$0.patient == record.patient}) {
                if record.isAuthenticated {
                    result[i].authenticated = true
                }
                result[i].numberOfRecords += 1
            } else {
                result.append(HealthRecordsDataSource(patient: record.patient, numberOfRecords: 1, authenticated: record.isAuthenticated))
            }
        }
        return result
    }
    
    func detailDataSource(patient: Patient) -> [HealthRecordsDetailDataSource] {
        let filtered = self.filter { $0.patient == patient }
        return filtered.compactMap({$0.detailDataSource()}).sorted(by: {first,second in
            let firstDate: Date?
            let secondDate: Date?
            switch first.type {
            case .covidImmunizationRecord(model: let model, immunizations: _):
                firstDate = Date(timeIntervalSince1970: model.issueDate)
            case .covidTestResultRecord(model: let model):
                firstDate = model.createdAt
            }
            switch second.type {
            case .covidImmunizationRecord(model: let model, immunizations: _):
                secondDate = Date(timeIntervalSince1970: model.issueDate)
            case .covidTestResultRecord(model: let model):
                secondDate = model.createdAt
            }
            return firstDate ?? Date() < secondDate ?? Date()
        })
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
