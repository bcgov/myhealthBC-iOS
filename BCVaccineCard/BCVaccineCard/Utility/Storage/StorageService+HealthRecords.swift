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
        case CovidTest
        case VaccineCard
        case Prescription
        case LaboratoryOrder
        case Immunization
        case Recommendation
        case HealthVisit
        case SpecialAuthorityDrug
    }
    
    func getHeathRecords() -> [HealthRecord] {
        let tests = fetchCovidTestResults().map({HealthRecord(type: .CovidTest($0))})
        // NOTE: Remove vaccineCards if we want to use new immz UI
//        let vaccineCards = fetchVaccineCards().map({HealthRecord(type: .CovidImmunization($0))}).filter({$0.patient.authenticated})
        let medications = fetchPrescriptions().map({HealthRecord(type: .Medication($0))})
        let labOrders = fetchLaboratoryOrders().map({HealthRecord(type: .LaboratoryOrder($0))})
        let immunizations = fetchImmunization().map({HealthRecord(type: .Immunization($0))})
        let healthVisits = fetchHealthVisits().map({HealthRecord(type: .HealthVisit($0))})
        let specialAuthority = fetchSpecialAuthorityMedications().map({HealthRecord(type: .SpecialAuthorityDrug($0))})
        
        return tests + medications + labOrders + immunizations + healthVisits + specialAuthority
    }
    
    func getHealthRecords(forDependent dependent: Patient) -> [HealthRecord] {
        let tests = dependent.testResultArray.map { HealthRecord(type: .CovidTest($0)) }
        let medications = dependent.prescriptionArray.map { HealthRecord(type: .Medication($0)) }
        let labOrders = dependent.labOrdersArray.map { HealthRecord(type: .LaboratoryOrder($0)) }
        let immunizations = dependent.immunizationArray.map { HealthRecord(type: .Immunization($0)) }
        
        return tests + medications + labOrders + immunizations
    }
    
    func deleteHealthRecordsForDependent(dependent: Patient) {
        let tests = dependent.testResultArray
        deleteAllRecords(in: tests)
        let medications = dependent.prescriptionArray
        deleteAllRecords(in: medications)
        let labOrders = dependent.labOrdersArray
        deleteAllRecords(in: labOrders)
        let immunizations = dependent.immunizationArray
        deleteAllRecords(in: immunizations)
    }
    
    func delete(healthRecord: HealthRecord) {
        switch healthRecord.type {
        case .CovidTest(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .CovidLabTestResult, object: object))
        case .CovidImmunization(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .VaccineCard, object: object))
        case .Medication(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .Perscription, object: object))
        case .LaboratoryOrder(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .LaboratoryOrder, object: object))
        case .Immunization(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .Immunization, object: object))
        case .HealthVisit(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .HealthVisit, object: object))
        case .SpecialAuthorityDrug(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .SpecialAuthorityMedication, object: object))
        }
    }
    
    func deleteHealthRecordsForAuthenticatedUser(types: [healthRecordType]? = nil) {
        var toDelete: [NSManagedObject] = []
        let typesTodelete: [healthRecordType] = types ?? [.Prescription, .CovidTest, .VaccineCard, .LaboratoryOrder]
        if typesTodelete.contains(.VaccineCard) {
            let vaccineCards = fetchVaccineCards().filter({$0.authenticated == true})
            toDelete.append(contentsOf: vaccineCards)
            notify(event: StorageEvent(event: .Delete, entity: .VaccineCard, object: vaccineCards))
        }
        if typesTodelete.contains(.CovidTest) {
            let tests = fetchCovidTestResults().filter({$0.authenticated == true})
            toDelete.append(contentsOf: tests)
            notify(event: StorageEvent(event: .Delete, entity: .TestResult, object: tests))
        }
        if typesTodelete.contains(.Prescription) {
            let medications = fetchPrescriptions().filter({ $0.authenticated == true })
            toDelete.append(contentsOf: medications)
            notify(event: StorageEvent(event: .Delete, entity: .Perscription, object: medications))
        }
        if typesTodelete.contains(.LaboratoryOrder) {
            let orders = fetchLaboratoryOrders().filter({ $0.authenticated == true })
            toDelete.append(contentsOf: orders)
            notify(event: StorageEvent(event: .Delete, entity: .LaboratoryOrder, object: orders))
        }
        if typesTodelete.contains(.Immunization) {
            let imms = fetchImmunization().filter({ $0.authenticated == true })
            toDelete.append(contentsOf: imms)
            notify(event: StorageEvent(event: .Delete, entity: .Perscription, object: imms))
        }
        if typesTodelete.contains(.HealthVisit) {
            let visits = fetchHealthVisits().filter({ $0.authenticated == true })
            toDelete.append(contentsOf: visits)
            notify(event: StorageEvent(event: .Delete, entity: .HealthVisit, object: visits))
        }
        if typesTodelete.contains(.SpecialAuthorityDrug) {
            let objects = fetchSpecialAuthorityMedications().filter({ $0.authenticated == true })
            toDelete.append(contentsOf: objects)
            notify(event: StorageEvent(event: .Delete, entity: .SpecialAuthorityMedication, object: objects))
        }
        
        if typesTodelete.contains(.Recommendation) {
            let objects = fetchRecommendations().filter({ $0.authenticated == true })
            toDelete.append(contentsOf: objects)
            notify(event: StorageEvent(event: .Delete, entity: .Recommendation, object: objects))
        }
        
        deleteAllRecords(in: toDelete)
    }
    
    func deleteAllHealthRecords() {
        let vaccineCards = fetchVaccineCards()
        deleteAllRecords(in: vaccineCards)
        let tests = fetchCovidTestResults()
        deleteAllRecords(in: tests)
        let medications = fetchPrescriptions()
        deleteAllRecords(in: medications)
        let labOrders = fetchLaboratoryOrders()
        deleteAllRecords(in: labOrders)
        let imms = fetchImmunization()
        deleteAllRecords(in: imms)
        let visits = fetchHealthVisits()
        deleteAllRecords(in: visits)
        let specialAuth = fetchSpecialAuthorityMedications()
        deleteAllRecords(in: specialAuth)
        let recommendations = fetchRecommendations()
        deleteAllRecords(in: recommendations)
    }
}
