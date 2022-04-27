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
        case ImmunizationRecord
        case VaccineCard
        case Perscription
        case Medication
        case Pharmacy
        case LaboratoryOrder
        case Comments
    }
    
    struct StorageEvent<T> {
        enum Event {
            case Delete
            case Save
            case Update
            case ManuallyAddedRecord
            case ProtectedMedicalRecordsInitialFetch
            case ManuallyAddedPendingTestBackgroundRefetch
        }
        
        let event: Event
        let entity: Entity
        let object: T
    }
}

class StorageService: StorageManagerProtocol {
    
    public static let shared = StorageService()
    
    private var container: NSPersistentContainer?
    var managedContext: NSManagedObjectContext? {
        let context =  container?.newBackgroundContext()
        context?.automaticallyMergesChangesFromParent = true
        return context
    }
    
    init(managedContext: NSManagedObjectContext = CoreDataStack.shared.managedContext,
         container: NSPersistentContainer = CoreDataStack.shared.container,
         mergePolicy: Any = NSMergeByPropertyObjectTrumpMergePolicy) {
        self.container = container
//        let context = container.newBackgroundContext()
//        context.automaticallyMergesChangesFromParent = true
//        self.managedContext = context
//        self.managedContext?.mergePolicy = mergePolicy
//        self.managedContext?.automaticallyMergesChangesFromParent = true
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
        DispatchQueue.main.async {
            let context = self.managedContext
            let contextObject = context?.object(with: object.objectID)
            guard let context = context, let contextObject = contextObject else {
                return
            }
            context.perform {
                do {
                    context.delete(contextObject)
                    try context.save()
                } catch {
                    return
                }
            }
        }
    }
}
