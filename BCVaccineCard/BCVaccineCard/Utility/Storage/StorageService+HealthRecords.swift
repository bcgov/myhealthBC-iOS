//
//  StorageService+HealthRecords.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-11-30.
//

import Foundation
import BCVaccineValidator

extension StorageService {
    
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
    
    func deleteHealthRecordsForAuthenticatedUser() {
        let tests = fetchTestResults().filter({$0.authenticated == true})
        let vaccineCards = fetchVaccineCards().filter({$0.authenticated == true})
        let medications = fetchPrescriptions().filter({ $0.authenticated == true })
        deleteAllRecords(in: tests)
        deleteAllRecords(in: vaccineCards)
        deleteAllRecords(in: medications)
    }
}
