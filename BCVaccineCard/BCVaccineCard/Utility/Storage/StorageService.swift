//
//  StorageService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-10-22.
//



import Foundation
import CoreData
import UIKit

protocol StorageManagerProtocol {
    func notify(event: StorageService.StorageEvent<Any>)
    func deleteAllStoredData()
}

extension StorageService {
    enum Entity {
        case Patient
        case CovidLabTestResult
        case TestResult
        case CovidImmunizationRecord
        case VaccineCard
        case Perscription
        case Medication
        case Pharmacy
        case LaboratoryOrder
        case Comments
        case Immunization
        case Recommendation
        case HealthVisit
        case HospitalVisit
        case ClinicalDocument
        case SpecialAuthorityMedication
        case Dependent
        case OrganDonorStatus
    }
    
    struct StorageEvent<T> {
        enum Event {
            case Delete
            case Save
            case Update
            case ManuallyAddedRecord
            case ProtectedMedicalRecordsInitialFetch
            case ManuallyAddedPendingTestBackgroundRefetch
            case Synced
        }
        
        let event: Event
        let entity: Entity
        let object: T
    }
}

class StorageService: StorageManagerProtocol {
    
    public static let shared = StorageService()
    
    var managedContext: NSManagedObjectContext?
    
    init(context: NSManagedObjectContext? = AppDelegate.sharedInstance?.coreDataContext,
         mergePolicy: Any = NSMergeByPropertyObjectTrumpMergePolicy) {
        self.managedContext = context
        self.managedContext?.mergePolicy = mergePolicy
    }
    
    func notify(event: StorageEvent<Any>) {
        Logger.log(string: "StorageEvent \(event.entity) - \(event.event)", type: .storage)
        NotificationCenter.default.post(name: .storageChangeEvent, object: event)
    }
    
    func deleteAllStoredData() {
        // this will delete objects related to it as well because of the
        let patients = fetchPatients()
        deleteAllRecords(in: patients)
        deleteAllHealthRecords()
        self.notify(event: StorageEvent(event: .Delete, entity: .Patient, object: patients))
    }
    
    // MARK: Helper functions
    func deleteAllRecords(in array: [NSManagedObject]) {
        for object in array {
           delete(object: object)
        }
    }
    
    func delete(object: NSManagedObject) {
        let context = managedContext
        do {
            context?.delete(object)
            try context?.save()
        } catch {
            return
        }
    }
}
