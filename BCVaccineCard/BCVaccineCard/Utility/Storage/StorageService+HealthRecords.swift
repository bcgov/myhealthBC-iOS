//
//  StorageService+HealthRecords.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
//

import Foundation

extension StorageService {
    
    func getHealthRecordsDataSource(for userId: String? = AuthManager().userId()) -> [HealthRecordsDataSource] {
        guard let context = managedContext else {return []}
        do {
            let users = try context.fetch(User.createFetchRequest())
            guard let current = users.filter({$0.userId == userId}).first else {return []}
            let tests = current.testResultArray
            let immunizationRecords = current.vaccineCardArray
            return mapHealthRecords(testArray: tests, immunizationRecordArray: immunizationRecords)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    private func mapHealthRecords(testArray: [TestResult], immunizationRecordArray: [VaccineCard]) -> [HealthRecordsDataSource] {
        var users = testArray.map { HealthRecordsDataSource(userName: $0.patientDisplayName ?? "", numberOfRecords: $0.reportId != nil ? 1 : 0) }
        let immRecords = immunizationRecordArray.map { HealthRecordsDataSource(userName: $0.name ?? "", numberOfRecords: $0.code != nil ? 1 : 0) }
        users.append(contentsOf: immRecords)
        var healthRecordsDataSource: [HealthRecordsDataSource] = []
        users.forEach { healthRecord in
            guard healthRecord.userName != "" else { return }
            if let index = healthRecordsDataSource.firstIndex(where: { $0.userName == healthRecord.userName }) {
                healthRecordsDataSource[index].numberOfRecords += healthRecord.numberOfRecords
            } else {
                healthRecordsDataSource.append(healthRecord)
            }
        }
        return healthRecordsDataSource
    }
    
    
    
}
