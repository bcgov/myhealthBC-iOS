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
    
    public func saveContext() {
        saveContext(managedContext)
    }

    public func saveContext(_ context: NSManagedObjectContext) {
        if context != managedContext {
            saveDerivedContext(context)
            return
        }
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    public func saveDerivedContext(_ context: NSManagedObjectContext) {
        context.perform {
            do {
              try context.save()
            } catch let error as NSError {
              fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            self.saveContext(self.managedContext)
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
