//
//  CoreDataStack.swift
//  BCVaccineCard
//
//  Created by Mohamed Fawzy on 26/01/2022.
//

import Foundation
import CoreData
import EncryptedCoreData

public protocol CoreDataStackProtocol {
    var persistentContainer: NSPersistentContainer { get }
}

extension CoreDataStackProtocol {
    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

class CoreDataStack: CoreDataStackProtocol {
    private init() { }
    public static let shared = CoreDataStack()
    
    var persistentContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: "BCVaccineCard")
        do {
            let options = [
                EncryptedStorePassphraseKey : CoreDataEncryptionKeyManager.shared.key
            ]
            let description = try EncryptedStore.makeDescription(options: options, configuration: nil)
            container.persistentStoreDescriptions = [ description ]
        }
        catch {
            // TODO: WE need to handle this better
            fatalError("Could not initialize encrypted database storage: " + error.localizedDescription)
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // TODO: WE need to handle this better
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }
}
