//
//  StorageService+HealthRecords.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
//

import Foundation
import BCVaccineValidator
import CoreData

extension StorageService {
    enum healthRecordType {
        case Test
        case VaccineCard
        case Prescription
    }
    
    func getHeathRecords() -> [HealthRecord] {
        let tests = fetchTestResults().map({HealthRecord(type: .Test($0))})
        let vaccineCards = fetchVaccineCards().map({HealthRecord(type: .CovidImmunization($0))})
        let medications = fetchPrescriptions().map({HealthRecord(type: .Medication($0))})
        return tests + vaccineCards + medications
    }
    
    func delete(healthRecord: HealthRecord) {
        switch healthRecord.type {
        case .Test(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .CovidLabTestResult, object: object))
        case .CovidImmunization(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .VaccineCard, object: object))
        case .Medication(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .Perscription, object: object))
        }
    }
    
    func deleteHealthRecordsForAuthenticatedUser(types: [healthRecordType]? = nil) {
        var toDelete: [NSManagedObject] = []
        let typesTodelete: [healthRecordType] = types ?? [.Prescription, .Test, .VaccineCard]
        if typesTodelete.contains(.VaccineCard) {
            let vaccineCards = fetchVaccineCards().filter({$0.authenticated == true})
            toDelete.append(contentsOf: vaccineCards)
            notify(event: StorageEvent(event: .Delete, entity: .VaccineCard, object: vaccineCards))
        }
        if typesTodelete.contains(.Test) {
            let tests = fetchTestResults().filter({$0.authenticated == true})
            toDelete.append(contentsOf: tests)
            notify(event: StorageEvent(event: .Delete, entity: .TestResult, object: tests))
        }
        if typesTodelete.contains(.Prescription) {
            let medications = fetchPrescriptions().filter({ $0.authenticated == true })
            toDelete.append(contentsOf: medications)
            notify(event: StorageEvent(event: .Delete, entity: .Perscription, object: medications))
        }
        deleteAllRecords(in: toDelete)
    }
    
    func deleteAllHealthRecords() {
        let vaccineCards = fetchVaccineCards()
        deleteAllRecords(in: vaccineCards)
        let tests = fetchTestResults()
        deleteAllRecords(in: tests)
        let medications = fetchPrescriptions()
        deleteAllRecords(in: medications)
    }
}
