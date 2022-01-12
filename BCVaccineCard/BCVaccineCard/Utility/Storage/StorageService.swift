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
    }
    
    struct StorageEvent<T> {
        enum Event {
            case Delete
            case Save
            case Update
        }
        
        let event: Event
        let entity: Entity
        let object: T
    }
}

class StorageService: StorageManagerProtocol {
    
    public static let shared = StorageService()
    
    var managedContext: NSManagedObjectContext?
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        appDelegate.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        managedContext = appDelegate.persistentContainer.viewContext
        
    }
    
    func notify(event: StorageEvent<Any>) {
        Logger.log(string: "StorageEvent \(event.entity) - \(event.event)")
        NotificationCenter.default.post(name: .storageChangeEvent, object: event)
    }
    
    func deleteAllStoredData() {
        // this will delete objects related to it as well because of the
        let patients = fetchPatients()
        deleteAllRecords(in: patients)
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
