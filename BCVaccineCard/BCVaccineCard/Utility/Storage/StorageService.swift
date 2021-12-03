//
//  StorageService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-10-22.
//

import Foundation
import CoreData
import UIKit

private enum VaccineCardKey: String {
    case code = "code"
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
    
    func createUserIfneeded() {
        // TODO: add appropriate name when authentication is added
        if fetchUser(id: AuthManager().userId()) == nil {
            _ = saveUser(id: AuthManager().userId(), name: AuthManager().userId())
        }
    }
    
    
    ///  Save a new user with user id and user name
    /// - Parameters:
    ///   - id: Unique user id
    ///   - name: user's name
    /// - Returns: boolean indicating success or failure
    func saveUser(id: String, name: String) -> Bool {
        guard let context = managedContext else {return false}
        let user = User(context: context)
        user.id = id
        user.name = name
        do {
            try context.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    
    /// Fetch a user by user id
    /// - Parameter id: user id
    /// - Returns: user
    func fetchUser(id: String) -> User? {
        guard let context = managedContext else {return nil}
        do {
            let users = try context.fetch(User.fetchRequest())
            guard let filtered = users.filter({$0.userId == id}).first else {return nil}
            return filtered
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
}
