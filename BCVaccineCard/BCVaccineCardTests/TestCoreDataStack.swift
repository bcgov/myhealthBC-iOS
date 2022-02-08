//
//  TestCoreData.swift
//  BCVaccineCardTests
//
//  Created by Mohamed Fawzy on 26/01/2022.
//

import CoreData
import BCVaccineCard

class TestCoreDataStack: CoreDataStackProtocol {
    var persistentContainer: NSPersistentContainer {
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        let container = NSPersistentContainer(name: "BCVaccineCard")
        container.persistentStoreDescriptions = [persistentStoreDescription]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }
}
