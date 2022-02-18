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
    /// - Parameters:
    ///   - name: Patient name
    ///   - dob: date of birth
    ///   - phn: Optional phn
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
    /// Find stored patient or create a new one with given data
    /// - Parameters:
    ///   - phn: phn
    ///   - name: name
    ///   - birthday: birthday
    /// - Returns: stored patient
    func fetchOrCreatePatient(phn: String?, name: String?, birthday: Date?) -> Patient?
}

extension StorageService: StoragePatientManager {
    
    // MARK: Store
    /// returns existing patient
    /// or
    /// creates and returns a new one if it doesnt exist.
    /// - Does the same thing as fetchOrCreatePatient()
    public func storePatient(
        name: String? = nil,
        birthday: Date? = nil,
        phn: String? = nil
    ) -> Patient? {
        return fetchOrCreatePatient(phn: phn, name: name, birthday: birthday)
    }
    
    /// Create a new patient entry in storage.
    fileprivate func savePatient(
        name: String? = nil,
        birthday: Date? = nil,
        phn: String? = nil
    ) -> Patient? {
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
    
    /// Update a patient entity to add phn or add name and birthday.
    /// This function will find the patient based on the data given and update it. if not found, returns nil
    func updatePatient(phn: String, name: String, birthday: Date) -> Patient? {
        if let patient = fetchPatient(phn: phn) {
            return update(phn: phn, name: name, birthday: birthday, for: patient)
            
        } else if let patient = fetchPatient(name: name, birthday: birthday) {
            return update(phn: phn, name: name, birthday: birthday, for: patient)
        }
        return nil
    }
    
    /// Updates values that are not nil
    fileprivate func update(phn: String?, name: String?, birthday: Date?, for patient: Patient) -> Patient? {
        guard let context = managedContext else {return nil}
        if patient.name == name && patient.phn == phn && patient.birthday == birthday {return patient}
        do {
            if let patientName = name {
                patient.name = patientName
            }
            if let bday = birthday {
                patient.birthday = bday
            }
            if let healthNumber = phn {
                patient.phn = healthNumber
            }
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
    
    /// returns all stored patients
    /// - Returns: all stored patients
    public func fetchPatients() -> [Patient] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(Patient.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    /// fetch patient by phn
    /// - Parameter phn: patient phn
    /// - Returns: patient
    public func fetchPatient(phn: String) -> Patient? {
        let patients = fetchPatients()
        return patients.filter({$0.phn == phn}).first
    }
    
    /// fetch patient by name and birthday
    /// - Parameters:
    ///   - name: patient name
    ///   - birthday: patient birthday
    /// - Returns: patient
    public func fetchPatient(name: String, birthday: Date) -> Patient? {
        let patients = fetchPatients()
       
        return patients.filter({$0.getComparableName() == StorageService.getComparableName(from: name) && $0.birthday == birthday}).first
    }
    
    // MARK: Helpers
    /// Find stored patient or create a new one with given data
    /// - Parameters:
    ///   - phn: phn
    ///   - name: name
    ///   - birthday: birthday
    /// - Returns: stored patient
    public func fetchOrCreatePatient(phn: String?, name: String?, birthday: Date?) -> Patient? {
        var phnPatient: Patient?
        var dobPatient: Patient?
        
        if let heathNumber = phn {
            phnPatient = fetchPatient(phn: heathNumber)
        }
        
        if let bday = birthday, let patientName = name {
            dobPatient = fetchPatient(name: patientName, birthday: bday)
        }
        
        // If patient doesnt exist, create it
        let foundPatient = phnPatient ?? dobPatient
        guard let patient = foundPatient else {
            return createPatient(phn: phn, name: name, birthday: birthday)
        }
        
        // otherwise update user data if needed and return
        _ = update(phn: phn, name: name, birthday: birthday, for: patient)
        
        return patient
    }
    
    /// This function is meant to be used by fetchOrCreatePatient
    /// All is does is verify
    fileprivate func createPatient(phn: String?, name: String?, birthday: Date?) -> Patient? {
        if (phn != nil) || (birthday != nil && name != nil) {
            return savePatient(name: name, birthday: birthday, phn: phn)
        }
        
        return nil
    }
    
    /// Returns first name + first letter of last name (if exists)
    public static func getComparableName(from name: String) -> String {
        let splitName = name.split(separator: " ")
        guard let first = splitName.first else {
            return name
        }
        if let last = splitName.last {
            return "\(first) \(last.prefix(1))"
        }
        return name
    }
    
}
