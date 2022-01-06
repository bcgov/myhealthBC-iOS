//
//  StorageService+User.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-03.
//

import Foundation

protocol StoragePatientManager {
    
    // MARK: Store
    /// Save a new patient.
    /// The name formats we get can be inconsistent
    /// - Parameters:
    ///   - name: Patient name
    ///   - dob: date of birth
    ///   - phn: Optional phn
    ///   - firstName: Optional first name
    ///   - lastName: Optional last name
    /// - Returns: Success or fail
    func storePatient(name: String,
                     dob: Date,
                     phn: String?,
                     firstName: String?,
                     lastName: String?) -> Bool
    // MARK: Update
    /// Update a patient entity to add phn or add name and birthday.
    /// This function will find the patient based on the data given and update it. if not found, returns nil
    /// - Parameters:
    ///   - phn: phn to update or search with
    ///   - name: name to update or search with
    ///   - birthday: birthday to update or search with
    /// - Returns: Updated patient if found and updated successfully.
    func updatePatient(phn: String, name: String, birthday: Date) -> Patient?
    
    // MARK: Delete
    func deletePatient(phn: String)
    func deletePatient(name: String, birthday: Date)
    
    // MARK: Fetch
    /// Returns all stored patients
    /// - Returns: all stored patients
    func fetchPatients() -> [Patient]
    
    /// Returns the patient with matching phn
    /// - Returns: patient
    func fetchPatient(phn: String) -> Patient?
    
    /// Returns the patient with matching name and bitthday
    /// - Returns: patient
    func fetchPatient(name: String, birthday: Date) -> Patient?
}

extension StorageService: StoragePatientManager {
    
    // MARK: Store
    public func storePatient(name: String,
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
    
    // MARK: Update
    func updatePatient(phn: String, name: String, birthday: Date) -> Patient? {
        if let patient = fetchPatient(phn: phn) {
            // Update birthday and name
            return update(phn: phn, for: patient)
            
        } else if let patient = fetchPatient(name: name, birthday: birthday) {
            // Update phn
            return update(name: name, birthday: birthday, for: patient)
        }
        return nil
    }
    
    fileprivate func update(phn: String, for patient: Patient) -> Patient? {
        guard let context = managedContext else {return nil}
        do {
            patient.phn = phn
            try context.save()
            notify(event: StorageEvent(event: .Update, entity: .Patient, object: patient))
            return patient
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
       
    }
    
    fileprivate func update(name: String, birthday: Date, for patient: Patient) -> Patient? {
        guard let context = managedContext else {return nil}
        do {
            patient.name = name
            patient.birthhday = birthday
            try context.save()
            notify(event: StorageEvent(event: .Update, entity: .Patient, object: patient))
            return patient
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // MARK: Delete
    func deletePatient(phn: String) {
        guard let patient = fetchPatient(phn: phn) else {return}
        delete(object: patient)
        notify(event: StorageEvent(event: .Delete, entity: .Patient, object: patient))
    }
    
    func deletePatient(name: String, birthday: Date) {
        guard let patient = fetchPatient(name: name, birthday: birthday) else {return}
        delete(object: patient)
        notify(event: StorageEvent(event: .Delete, entity: .Patient, object: patient))
    }
    
    // MARK: Fetch
    public func fetchPatients() -> [Patient] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(Patient.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    public func fetchPatient(phn: String) -> Patient? {
        let patients = fetchPatients()
        return patients.filter({$0.phn == phn}).first
    }
    
    public func fetchPatient(name: String, birthday: Date) -> Patient? {
        let patients = fetchPatients()
        return patients.filter({$0.name == name && $0.birthhday == birthday}).first
    }
    
}
