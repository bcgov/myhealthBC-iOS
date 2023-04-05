//
//  CoreDataStack.swift
//  BCVaccineCard
//
//  Created by Mohamed Fawzy on 26/01/2022.
//

import Foundation
import CoreData
import EncryptedCoreData
import UIKit

public protocol StorageProvider {
    func loadPersistentContainer(attempt: Int, completion: @escaping(NSPersistentContainer?)->Void)
    func loadManagedContext(completion: @escaping(NSManagedObjectContext?)->Void)
}

extension AppDelegate {
    func showDBLoadError() {
        let errorView: DBLoadFatalError = DBLoadFatalError(frame: window?.bounds ?? .zero)
        
        self.window?.addSubview(errorView)
        let titleLabel = UILabel(frame: .zero)
        errorView.addSubview(titleLabel)
        let bodyLabel = UILabel(frame: .zero)
        errorView.addSubview(bodyLabel)
   
        titleLabel.text = "Storage Error"
        bodyLabel.text = "We couldn't initialize storage for this application.\n\nPlease try closing and launching this application again.\n\nif this error persists, please delete the app and download again from the App Store."
        
        titleLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        bodyLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        errorView.backgroundColor = UIColor.lightGray
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: errorView.topAnchor, constant: 50).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor, constant: 0).isActive = true
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32).isActive = true
        bodyLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor, constant: 0).isActive = true
        bodyLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 16).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -16).isActive = true
    }
}

//extension CoreDataStackProtocol {
//    var managedContext: NSManagedObjectContext {
//        return persistentContainer.viewContext
//    }
//
//    // MARK: - Core Data Saving support
//
//    func saveContext() {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
//}

class CoreDataProvider: StorageProvider {
    private init() { }
    public static let shared = CoreDataProvider()
    
    // Max number of attempts to initialize persitence container before giving up and returning nil
    private let maxAttempts: Int = 3
    
    // Cached container
    private var container: NSPersistentContainer?
    
    func loadManagedContext(completion: @escaping (NSManagedObjectContext?) -> Void) {
        if let container = self.container {
            return completion(container.viewContext)
        }
        
        loadPersistentContainer(attempt: 0) { container in
            if let container = container {
                return completion(container.viewContext)
            } else {
                return completion(nil)
            }
        }
    }
    
    func loadPersistentContainer(attempt: Int, completion: @escaping(NSPersistentContainer?)->Void) {
        if attempt > maxAttempts {
            return completion(nil)
        }
        
        let container = NSPersistentContainer(name: "BCVaccineCard")
        
        // Unlock encrypted storage
        do {
            let options = [
                EncryptedStorePassphraseKey : CoreDataEncryptionKeyManager.shared.key
            ]
            let description = try EncryptedStore.makeDescription(options: options, configuration: nil)
            container.persistentStoreDescriptions = [ description ]
        }
        catch {
            print("Could not initialize encrypted database storage: " + error.localizedDescription)
            // Remove DB and re-create DB by calling loadPersistentContainer again
            MigrationService().removeDB()
            loadPersistentContainer(attempt: attempt + 1, completion: completion)
            return
        }
        
        // Load
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Some error... Remove and re-create DB by calling loadPersistentContainer again
                print("Unresolved error \(error), \(error.userInfo)")
                MigrationService().removeDB()
                self.loadPersistentContainer(attempt: attempt + 1, completion: completion)
            }
            self.container = container
            return completion(container)
        })
    }
}
