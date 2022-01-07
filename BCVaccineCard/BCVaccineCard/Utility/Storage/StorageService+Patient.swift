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
    /// - Returns: Patient object
    func storePatient(name: String?,
                      birthday: Date?,
                      phn: String?) -> Patient?
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
    
    //MARK: Helpers
    func fetchOrCreatePatient(phn: String) -> Patient?
    func fetchOrCreatePatient(name: String, birthday: Date) -> Patient?
}

extension StorageService: StoragePatientManager {
    
    // MARK: Store
    public func storePatient(
        name: String? = nil,
        birthday: Date? = nil,
        phn: String? = nil) -> Patient? {
            guard let context = managedContext else {return nil}
            let patient = Patient(context: context)
            patient.birthday = birthday
            patient.name = name
            patient.phn = phn
            do {
                try context.save()
                notify(event: StorageEvent(event: .Save, entity: .Patient, object: patient))
                return patient
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return nil
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
            patient.birthday = birthday
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
        return patients.filter({$0.name == name && $0.birthday == birthday}).first
    }
    
    // MARK: Helpers
    func fetchOrCreatePatient(name: String, birthday: Date) -> Patient? {
        if let existing = fetchPatient(name: name, birthday: birthday) { return existing}
        return storePatient(name: name, birthday: birthday)
    }
    
    func fetchOrCreatePatient(phn: String) -> Patient? {
        if let existing = fetchPatient(phn: phn) { return existing}
       return  storePatient(phn: phn)
    }
    
    
}
