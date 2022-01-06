//
//  StorageService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-10-22.
//

import Foundation
import CoreData
import UIKit

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

class StorageService {
    
    public static let shared = StorageService()
    
    var managedContext: NSManagedObjectContext?
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        managedContext = appDelegate.persistentContainer.viewContext
        
        // TODO: Refactor when authentication is added
        createUserIfneeded()
    }
    
    func notify(event: StorageEvent<Any>) {
        #if DEV
        print("StorageEvent \(event.entity) - \(event.event)")
        #endif
        NotificationCenter.default.post(name: .storageChangeEvent, object: event)
    }
    
    func deleteAllStoredData(for userId: String? = AuthManager().userId()) {
        /**
         We could do this, but then we would have to add do this with each new record type:
         
         let vaccineCards = fetchVaccineCards()
         let tests = fetchTestResults()
         deleteAllRecords(in: vaccineCards)
         deleteAllRecords(in: tests)
         */
       
        /**
         Or we can delete the user record.
         this will delete objects related to it as well because of the
         cascade delete rule on the relationships
         then we can create the user again with the same properties.
         */
        if let user = fetchUser(id: userId), let userID = user.id {
            // cache user data
            let userName = user.name ?? ""
            
            /// delete user record.
            /// this will delete objects related to it as well because of the
            /// cascade delete rule on the relationships
            deleteAllRecords(in: [user])
            // store user again
            _ = saveUser(id: userID, name: userName)
        }
        
    }
    
    fileprivate func deleteAllRecords(in array: [NSManagedObject]) {
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
