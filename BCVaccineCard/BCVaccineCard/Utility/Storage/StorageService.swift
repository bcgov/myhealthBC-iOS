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
    
    func deleteAllStoredData() {
        
    }
}
