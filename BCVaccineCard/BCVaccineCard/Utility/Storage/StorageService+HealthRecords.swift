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
    func getRecords(for patient: Patient) -> [HealthRecord] {
        let tests = patient.testResultArray.map({HealthRecord(type: .CovidTest($0))})
        let medications = patient.prescriptionArray.map({HealthRecord(type: .Medication($0))})
        let labOrders = patient.labOrdersArray.map({HealthRecord(type: .LaboratoryOrder($0))})
        let immunizations = patient.immunizationsArray.map({HealthRecord(type: .Immunization($0))})
        let healthVisits = patient.healthVisitsArray.map({HealthRecord(type: .HealthVisit($0))})
        let specialAuthority = patient.specialAuthorityDrugsArray.map({HealthRecord(type: .SpecialAuthorityDrug($0))})
        let hospitalVisits = patient.hospitalVisitsArray.map({HealthRecord(type: .HospitalVisit($0))})
        let clinicalDocs = patient.clinicalDocumentsArray.map({HealthRecord(type: .ClinicalDocument($0))})
        let diagnosticImaging = patient.diagnosticImagingArray.map({HealthRecord(type: .DiagnosticImaging($0))})
        var notesRecords: [HealthRecord] = []
        if let notes = notesArray(for: patient) {
            notesRecords = notes.map({HealthRecord(type: .Note($0))})
        }
        
        return tests + medications + labOrders + immunizations + healthVisits + specialAuthority + hospitalVisits + clinicalDocs + diagnosticImaging + notesRecords
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
        let hospitalVisits = fetchHospitalVisits().map({HealthRecord(type: .HospitalVisit($0))})
        let clinicalDocs = fetchClinicalDocuments().map({HealthRecord(type: .ClinicalDocument($0))})
        let diagnosticImaging = fetchDiagnosticImaging().map({HealthRecord(type: .DiagnosticImaging($0))})
        let notes = fetchNotes().map({HealthRecord(type: .Note($0))})
        
        return tests + medications + labOrders + immunizations + healthVisits + specialAuthority + hospitalVisits + clinicalDocs + diagnosticImaging + notes
    }
    
    func getRecords(forDependent dependent: Patient) -> [HealthRecord] {
        let tests = dependent.testResultArray.map { HealthRecord(type: .CovidTest($0)) }
        let medications = dependent.prescriptionArray.map { HealthRecord(type: .Medication($0)) }
        let labOrders = dependent.labOrdersArray.map { HealthRecord(type: .LaboratoryOrder($0)) }
        let immunizations = dependent.immunizationArray.map { HealthRecord(type: .Immunization($0)) }
        var notesRecords: [HealthRecord] = []
        if let notes = notesArray(for: dependent) {
            notesRecords = notes.map({HealthRecord(type: .Note($0))})
        }
        
        return tests + medications + labOrders + immunizations + notesRecords
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
        if let notesToDelete = notesArray(for: dependent)?.filter({ $0.addedToTimeline == true }) {
            deleteAllRecords(in: notesToDelete)
        }
    }
    
    func deleteDependentVaccineCards(forPatient patient: Patient) {
        var vaccineCardsArray: [[VaccineCard]] = []
        patient.dependentsArray.forEach({ dependent in
            if let array = dependent.info?.vaccineCardArray {
                vaccineCardsArray.append(array)
            }
        })
        let vaccineCards = vaccineCardsArray.flatMap { $0 }
        deleteAllRecords(in: vaccineCards)
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
        case .HospitalVisit(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .HealthVisit, object: object))
        case .ClinicalDocument(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .ClinicalDocument, object: object))
        case .DiagnosticImaging(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .DiagnosticImaging, object: object))
        case .CancerScreening(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .CancerScreening, object: object))
        case .Note(let object):
            delete(object: object)
            notify(event: StorageEvent(event: .Delete, entity: .Notes, object: object))
        }
    }
    
    func deleteComments(for patient: Patient) {
        let comments = fetchComments()
        deleteAllRecords(in: comments)
    }
    
    func deleteHealthRecords(for patient: Patient, types: [HealthRecordType]? = nil) {
        var toDelete: [NSManagedObject] = []
        let typesTodelete: [HealthRecordType] = types ?? HealthRecordType.allCases
        for type in typesTodelete {
            switch type {
            case .CovidTest:
                let tests = fetchCovidTestResults().filter({$0.authenticated == true})
                toDelete.append(contentsOf: tests)
                notify(event: StorageEvent(event: .Delete, entity: .TestResult, object: tests))
            case .VaccineCard:
                let vaccineCards = fetchVaccineCards().filter({$0.authenticated == true})
                toDelete.append(contentsOf: vaccineCards)
                notify(event: StorageEvent(event: .Delete, entity: .VaccineCard, object: vaccineCards))
            case .Prescription:
                let medications = fetchPrescriptions().filter({ $0.authenticated == true })
                toDelete.append(contentsOf: medications)
                notify(event: StorageEvent(event: .Delete, entity: .Perscription, object: medications))
            case .LaboratoryOrder:
                let orders = fetchLaboratoryOrders().filter({ $0.authenticated == true })
                toDelete.append(contentsOf: orders)
                notify(event: StorageEvent(event: .Delete, entity: .LaboratoryOrder, object: orders))
            case .Immunization:
                let imms = fetchImmunization().filter({ $0.authenticated == true })
                toDelete.append(contentsOf: imms)
                notify(event: StorageEvent(event: .Delete, entity: .Perscription, object: imms))
            case .Recommendation:
                let objects = fetchRecommendations().filter({ $0.authenticated == true })
                toDelete.append(contentsOf: objects)
                notify(event: StorageEvent(event: .Delete, entity: .Recommendation, object: objects))
            case .HealthVisit:
                let visits = fetchHealthVisits().filter({ $0.authenticated == true })
                toDelete.append(contentsOf: visits)
                notify(event: StorageEvent(event: .Delete, entity: .HealthVisit, object: visits))
            case .SpecialAuthorityDrug:
                let objects = fetchSpecialAuthorityMedications().filter({ $0.authenticated == true })
                toDelete.append(contentsOf: objects)
                notify(event: StorageEvent(event: .Delete, entity: .SpecialAuthorityMedication, object: objects))
            case .HospitalVisit:
                let objects = patient.hospitalVisitsArray
                toDelete.append(contentsOf: objects)
                notify(event: StorageEvent(event: .Delete, entity: .HospitalVisit, object: objects))
            case .ClinicalDocument:
                let objects = patient.clinicalDocumentsArray
                toDelete.append(contentsOf: objects)
                notify(event: StorageEvent(event: .Delete, entity: .ClinicalDocument, object: objects))
            case .DiagnosticImaging:
                let objects = patient.diagnosticImagingArray
                toDelete.append(contentsOf: objects)
                notify(event: StorageEvent(event: .Delete, entity: .DiagnosticImaging, object: objects))
            case .CancerScreening:
                let objects = patient.cancerScreeningArray
                toDelete.append(contentsOf: objects)
                notify(event: StorageEvent(event: .Delete, entity: .CancerScreening, object: objects))
            case .Notes:
                if let objects = notesArray(for: patient)?.filter({ $0.addedToTimeline == true }) {
                    toDelete.append(contentsOf: objects)
                    notify(event: StorageEvent(event: .Delete, entity: .Notes, object: objects))
                }
            }
        }
        
        deleteAllRecords(in: toDelete)
    }
    
    func deleteAllHealthRecords() {
        let typesTodelete = HealthRecordType.allCases
        for type in typesTodelete {
            switch type {
            case .CovidTest:
                let tests = fetchCovidTestResults()
                deleteAllRecords(in: tests)
            case .VaccineCard:
                let vaccineCards = fetchVaccineCards()
                deleteAllRecords(in: vaccineCards)
            case .Prescription:
                let medications = fetchPrescriptions()
                deleteAllRecords(in: medications)
            case .LaboratoryOrder:
                let labOrders = fetchLaboratoryOrders()
                deleteAllRecords(in: labOrders)
            case .Immunization:
                let imms = fetchImmunization()
                deleteAllRecords(in: imms)
            case .Recommendation:
                let recommendations = fetchRecommendations()
                deleteAllRecords(in: recommendations)
            case .HealthVisit:
                let visits = fetchHealthVisits()
                deleteAllRecords(in: visits)
            case .SpecialAuthorityDrug:
                let specialAuth = fetchSpecialAuthorityMedications()
                deleteAllRecords(in: specialAuth)
            case .HospitalVisit:
                let hospitalVisits = fetchHospitalVisits()
                deleteAllRecords(in: hospitalVisits)
            case .ClinicalDocument:
                let clinicalDocuments = fetchClinicalDocuments()
                deleteAllRecords(in: clinicalDocuments)
            case .DiagnosticImaging:
                let diagnosticImaging = fetchDiagnosticImaging()
                deleteAllRecords(in: diagnosticImaging)
            case .CancerScreening:
                let cancerScreening = fetchCancerScreening()
                deleteAllRecords(in: cancerScreening)
            case .Notes:
                let notes = fetchNotes().filter { $0.addedToTimeline == true }
                deleteAllRecords(in: notes)
            }
        }
    }
    
    func deleteHealthRecordsForDependent(dependent: Dependent) {
        let typesTodelete = HealthRecordType.allCases
        for type in typesTodelete {
            switch type {
            case .CovidTest:
                if let tests = dependent.info?.testResultArray {
                    deleteAllRecords(in: tests)
                }
            case .VaccineCard:
                if let vaccineCards = dependent.info?.vaccineCardArray {
                    deleteAllRecords(in: vaccineCards)
                }
            case .Prescription:
                if let medications = dependent.info?.prescriptionArray {
                    deleteAllRecords(in: medications)
                }
            case .LaboratoryOrder:
                if let labOrders = dependent.info?.labOrdersArray {
                    deleteAllRecords(in: labOrders)
                }
            case .Immunization:
                if let imms = dependent.info?.immunizationsArray {
                    deleteAllRecords(in: imms)
                }
            case .Recommendation:
                if let recommandations = dependent.info?.recommandationsArray {
                    deleteAllRecords(in: recommandations)
                }
            case .HealthVisit:
                if let visits = dependent.info?.healthVisitsArray {
                    deleteAllRecords(in: visits)
                }
            case .SpecialAuthorityDrug:
                if let specialAuth = dependent.info?.specialAuthorityDrugsArray {
                    deleteAllRecords(in: specialAuth)
                }
            case .HospitalVisit:
                if let hospitalVisits = dependent.info?.hospitalVisitsArray {
                    deleteAllRecords(in: hospitalVisits)
                }
            case .ClinicalDocument:
                if let clinicalDocuments = dependent.info?.clinicalDocumentsArray {
                    deleteAllRecords(in: clinicalDocuments)
                }
            case .DiagnosticImaging:
                if let diagnosticImaging = dependent.info?.diagnosticImagingArray {
                    deleteAllRecords(in: diagnosticImaging)
                }
            case .CancerScreening:
                if let cancerScreening = dependent.info?.cancerScreeningArray {
                    deleteAllRecords(in: cancerScreening)
                }
            case .Notes:
                if let notes = notesArray(for: dependent.info)?.filter({ $0.addedToTimeline == true }) {
                    deleteAllRecords(in: notes)
                }
            }
        }
    }
}

// MARK: Notes array, being that there is no longer a patient relationship
extension StorageService {
    
    public func notesArray(for patient: Patient?) -> [Note]? {
        guard let patient = patient else { return nil }
        let notes = fetchNotes().filter { $0.createdBy ?? "none" == patient.hdid ?? "no hdid" }
        return notes.sorted {
            $0.journalDate ?? Date() > $1.journalDate ?? Date()
        }
    }
}
