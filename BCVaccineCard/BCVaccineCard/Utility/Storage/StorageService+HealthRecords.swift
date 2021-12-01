//
//  StorageService+HealthRecords.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
//

import Foundation
import BCVaccineValidator

extension StorageService {
    
    // Note: This is used on the health records home screen to get a list of users and their number of health records
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
    
    // TODO: Add Birthday to the unique check, just need it from test endpoint first
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

    // Note: This is used to get a list of health records for a specific user for the list view
    func getListOfHealthRecordsForName(name: String, for userId: String? = AuthManager().userId(), completion: @escaping([HealthRecordsDetailDataSource]) -> Void) {
        guard let context = managedContext else {
            completion([])
            return
        }
        do {
            let users = try context.fetch(User.createFetchRequest())
            guard let current = users.filter({$0.userId == userId}).first else {
                completion([])
                return
            }
            let tests = getTestResultsForName(name: name, tests: current.testResultArray)
            let immunizationRecords = getImmunizationRecordsForName(name: name, immunizationRecords: current.vaccineCardArray)
            mapHealthRecords(testArray: tests, immunizationRecordArray: immunizationRecords)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            completion([])
        }
    }
    
    // TODO: Will need to include birthdate in the check here
    private func getTestResultsForName(name: String, tests: [TestResult]) -> [TestResult] {
        return tests.filter { $0.patientDisplayName == name }
    }

    private func getImmunizationRecordsForName(name: String, immunizationRecords: [VaccineCard]) -> [VaccineCard] {
        return immunizationRecords.filter { $0.name == name }
    }

    private func mapHealthRecordsForName(tests: [TestResult], immunizationRecords: [VaccineCard], completion: @escaping([HealthRecordsDetailDataSource]) -> Void) {
        var dataSource: [HealthRecordsDetailDataSource] = []
        for test in tests {
            let local = transformTestResultIntoCovidTestResultModel(test: test)
            let record = HealthRecordsDetailDataSource.RecordType.covidTestResult(model: local)
            let dsInstance = HealthRecordsDetailDataSource(type: record)
            dataSource.append(dsInstance)
        }
        // TODO: Check with Amir here that no card means that appModel is just an empty array
        for record in immunizationRecords {
            let instances = record.immunizations
            if let localModel = record.toLocal() {
                let r = HealthRecordsDetailDataSource.RecordType.covidImmunizationRecord(model: localModel, immunizations: instances)
                let dsInstance = HealthRecordsDetailDataSource(type: r)
                dataSource.append(dsInstance)
            }
        }
    }

    
}
