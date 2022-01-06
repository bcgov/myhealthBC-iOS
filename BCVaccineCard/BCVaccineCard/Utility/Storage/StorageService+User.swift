//
//  StorageService+User.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-03.
//

import Foundation

protocol StoragePatientManager {
    
    /// Save a new patient.
    /// The name formats we get can be inconsistent
    /// - Parameters:
    ///   - name: Patient name
    ///   - dob: date of birth
    ///   - phn: Optional phn
    ///   - firstName: Optional first name
    ///   - lastName: Optional last name
    /// - Returns: Success or fail
    func savePatient(name: String,
                     dob: Date,
                     phn: String?,
                     firstName: String?,
                     lastName: String?) -> Bool
}

extension StorageService: StoragePatientManager {
    
    func savePatient(name: String,
                     dob: Date,
                     phn: String? = nil,
                     firstName: String? = nil,
                     lastName: String? = nil) -> Bool {
        guard let context = managedContext else {return false}
        let patient = Patient(context: context)
        patient.birthhday = dob
        patient.name = name
        patient.phn = phn
        patient.firstName = firstName
        patient.lastName = lastName
        do {
            try context.save()
            notify(event: StorageEvent(event: .Save, entity: .Patient, object: patient))
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    
    /// Fetch a user by user id
    /// - Parameter id: user id
    /// - Returns: user
    func fetchUser(id: String? = AuthManager().userId()) -> User? {
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
