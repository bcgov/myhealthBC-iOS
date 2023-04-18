//
//  StorageService+User.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-03.
//

import Foundation
import CoreData

protocol StoragePatientManager {
    
    // MARK: Store
    /// Save a new patient.
    /// - Parameters:
    ///   - name: Patient name
    ///   - dob: date of birth
    ///   - phn: Optional phn
    /// - Returns: Patient object
    func storePatient(name: String?,
                      firstName: String?,
                      lastName: String?,
                      gender: String?,
                      birthday: Date?,
                      phn: String?,
                      physicalAddress: Address?,
                      mailingAddress: Address?,
                      hdid: String?,
                      authenticated: Bool
    ) -> Patient?
    
    // MARK: Update
    /// Update a patient entity to add phn or add name and birthday.
    /// This function will find the patient based on the data given and update it. if not found, returns nil
    /// - Parameters:
    ///   - phn: phn to update or search with
    ///   - name: name to update or search with
    ///   - birthday: birthday to update or search with
    /// - Returns: Updated patient if found and updated successfully.
    func updatePatient(phn: String,
                       name: String,
                       firstName: String?,
                       lastName: String?,
                       gender: String?,
                       birthday: Date,
                       physicalAddress: Address?,
                       mailingAddress: Address?,
                       hdid: String?,
                       authenticated: Bool
    ) -> Patient?
    
    // MARK: Delete
    func deletePatient(phn: String)
    func deletePatient(name: String, birthday: Date)
    func deleteAuthenticatedPatient()
    func deleteAuthenticatedPatient(with authManagerDisplayName: String)
    
    // MARK: Fetch
    /// Returns all stored patients
    /// - Returns: all stored patients
    func fetchPatients(context: NSManagedObjectContext?) -> [Patient]
    
    /// Returns the patient with authenticated results
    /// - Returns: patient
    func fetchAuthenticatedPatient() -> Patient?
    
    /// Returns the patient with authenticated results
    /// - Returns: patients
    func fetchAuthenticatedPatients() -> [Patient]?
    
    /// Returns the list of unauthenticated patients
    /// - Returns: patients
    func fetchUnauthenticatedPatients() -> [Patient]?
    
    /// Returns the patient with matching phn
    /// - Returns: patient
    func fetchPatient(phn: String, context: NSManagedObjectContext?) -> Patient?
    
    /// Returns the patient with matching name and bitthday
    /// - Returns: patient
    func fetchPatient(name: String, birthday: Date) -> Patient?
    
    //MARK: Helpers
    /// Find stored patient or create a new one with given data
    /// - Parameters:
    ///   - phn: phn
    ///   - name: name
    ///   - birthday: birthday
    ///   - hdid: hdid
    /// - Returns: stored patient
    func fetchOrCreatePatient(phn: String?,
                              name: String?,
                              firstName: String?,
                              lastName: String?,
                              gender: String?,
                              birthday: Date?,
                              physicalAddress: Address?,
                              mailingAddress: Address?,
                              hdid: String?,
                              authenticated: Bool
    ) -> Patient?
    
    // MARK: Creates an address to attach to a Patient
    func createAndReturnAddress(addressDetails: AuthenticatedPatientDetailsResponseObject.Address?) -> Address?
}

extension StorageService: StoragePatientManager {
    
    // MARK: Store
    func store(
        organDonorStatus object: OrganDonorStatusResponse,
        for patient: Patient
    ) -> OrganDonorStatus? {
        guard let context = managedContext,
              let phn = patient.phn,
              let patientRefetch = fetchPatient(phn: phn, context: context) else {return nil}
        let model = OrganDonorStatus(context: context)
        model.status = object.status
        model.statusMessage = object.statusMessage
        model.fileId = object.registrationFileID
        model.patient = patientRefetch
        do {
            try context.save()
            notify(event: StorageEvent(event: .Save, entity: .OrganDonorStatus, object: patient))
            return model
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    /// returns existing patient
    /// or
    /// creates and returns a new one if it doesnt exist.
    /// - Does the same thing as fetchOrCreatePatient()
    public func storePatient(
        name: String? = nil,
        firstName: String?,
        lastName: String?,
        gender: String?,
        birthday: Date? = nil,
        phn: String? = nil,
        physicalAddress: Address? = nil,
        mailingAddress: Address? = nil,
        hdid: String? = nil,
        authenticated: Bool
    ) -> Patient? {
        return fetchOrCreatePatient(
            phn: phn,
            name: name,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            birthday: birthday,
            physicalAddress: physicalAddress,
            mailingAddress: mailingAddress,
            hdid: hdid,
            authenticated: authenticated)
    }
    
    /// Create a new patient entry in storage.
    fileprivate func savePatient(
        name: String? = nil,
        firstName: String?,
        lastName: String?,
        gender: String?,
        birthday: Date? = nil,
        phn: String? = nil,
        physicalAddress: Address? = nil,
        mailingAddress: Address? = nil,
        hdid: String? = nil,
        authenticated: Bool
    ) -> Patient? {
        guard let context = managedContext else {return nil}
        let patient = Patient(context: context)
        patient.birthday = birthday
        patient.name = name
        patient.firstName = firstName
        patient.lastName = lastName
        patient.gender = gender
        patient.phn = phn
        patient.physicalAddress = physicalAddress
        patient.postalAddress = mailingAddress
        patient.authenticated = authenticated
        patient.hdid = hdid
        patient.authManagerDisplayName = AuthManager().displayName
        do {
            try context.save()
            notify(event: StorageEvent(event: .Save, entity: .Patient, object: patient))
            return patient
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    // MARK: Update
    
    /// Update a patient entity to add phn or add name and birthday.
    /// This function will find the patient based on the data given and update it. if not found, returns nil
    func updatePatient(
        phn: String,
        name: String,
        firstName: String?,
        lastName: String?,
        gender: String?,
        birthday: Date,
        physicalAddress: Address?,
        mailingAddress: Address?,
        hdid: String?,
        authenticated: Bool
    ) -> Patient? {
        if let patient = fetchPatient(phn: phn) {
            return update(phn: phn, name: name, birthday: birthday, physicalAddress: physicalAddress, mailingAddress: mailingAddress, hdid: hdid, authenticated: authenticated, for: patient)
            
        } else if let patient = fetchPatient(name: name, birthday: birthday) {
            return update(phn: phn, name: name, birthday: birthday, physicalAddress: physicalAddress, mailingAddress: mailingAddress, hdid: hdid, authenticated: authenticated, for: patient)
        }
        return nil
    }
    
    /// Updates values that are not nil
    fileprivate func update(phn: String?, name: String?, birthday: Date?, physicalAddress: Address?, mailingAddress: Address?, hdid: String?, authenticated: Bool, for patient: Patient) -> Patient? {
        guard let context = managedContext else {return nil}
        if patient.name == name && patient.phn == phn && patient.birthday == birthday && patient.hdid == hdid && patient.authenticated == authenticated {return patient}
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
            if let physicalAddress = physicalAddress {
                patient.physicalAddress = physicalAddress
            }
            if let mailingAddress = mailingAddress {
                patient.postalAddress = mailingAddress
            }
            if let hdid = hdid {
                patient.hdid = hdid
            }
            if authenticated != patient.authenticated {
                patient.authenticated = authenticated
            }
            // Unsure if we need to set patient.authManagerDisplayName = AuthManager().displayName here
            try context.save()
            notify(event: StorageEvent(event: .Update, entity: .Patient, object: patient))
            return patient
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
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
    
    func deleteAuthenticatedPatient() {
        guard let patient = fetchAuthenticatedPatient() else {
            return
        }
        deleteHealthRecords(for: patient)
        deleteComments(for: patient)
        delete(object: patient)
        notify(event: StorageEvent(event: .Delete, entity: .Patient, object: patient))
    }
    
    func deleteAuthenticatedPatient(with authManagerDisplayName: String) {
        guard let patient = fetchAuthenticatedPatients()?.filter({ $0.authManagerDisplayName == authManagerDisplayName }).first else { return }
        delete(object: patient)
        notify(event: StorageEvent(event: .Delete, entity: .Patient, object: patient))
    }
    
    // MARK: Fetch
    
    /// returns all stored patients
    /// - Returns: all stored patients
    public func fetchPatients(context: NSManagedObjectContext? = nil) -> [Patient] {
        let contextToUse: NSManagedObjectContext?
        if let givenContext = context {
            contextToUse = givenContext
        } else if let currentContext = managedContext {
            contextToUse = currentContext
        } else {
            contextToUse = nil
            return []
        }
        guard let contextToUse = contextToUse else {return []}
        do {
            return try contextToUse.fetch(Patient.fetchRequest())
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
    
    /// fetch patient by auth status
    /// - Returns: authenticated patient
    public func fetchAuthenticatedPatient() -> Patient? {
        let patients = fetchPatients()
        return patients.filter { $0.authenticated == true }.first
    }
    
    /// fetch patient by auth status
    /// - Returns: authenticated patients
    public func fetchAuthenticatedPatients() -> [Patient]? {
        let patients = fetchPatients()
        let authenticatedPatients = patients.filter { $0.authenticated == true }
        guard authenticatedPatients.count > 0 else { return nil }
        return authenticatedPatients
    }
    
    /// fetch patient by auth status
    /// - Returns: unauthenticated patients
    public func fetchUnauthenticatedPatients() -> [Patient]? {
        let patients = fetchPatients()
        let unauthenticatedPatients = patients.filter { $0.authenticated == false }
        guard unauthenticatedPatients.count > 0 else { return nil }
        return unauthenticatedPatients
    }
    
    /// fetch patient by phn
    /// - Parameter phn: patient phn
    /// - Returns: patient
    public func fetchPatient(phn: String, context: NSManagedObjectContext? = nil) -> Patient? {
        let patients = fetchPatients(context: context)
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
    public func fetchOrCreatePatient(
        phn: String?,
        name: String?,
        firstName: String?,
        lastName: String?,
        gender: String?,
        birthday: Date?,
        physicalAddress: Address?,
        mailingAddress: Address?,
        hdid: String? = nil,
        authenticated: Bool
    ) -> Patient? {
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
            return createPatient(
                phn: phn,
                name: name,
                firstName: firstName,
                lastName: lastName,
                gender: gender,
                birthday: birthday,
                physicalAddress: physicalAddress,
                mailingAddress: mailingAddress,
                hdid: hdid,
                authenticated: authenticated)
        }
        
        // otherwise update user data if needed and return
        _ = update(phn: phn, name: name, birthday: birthday, physicalAddress: physicalAddress, mailingAddress: mailingAddress, hdid: hdid, authenticated: authenticated, for: patient)
        
        return patient
    }
    
    /// This function is meant to be used by fetchOrCreatePatient
    /// All is does is verify
    fileprivate func createPatient(phn: String?,
                                   name: String?,
                                   firstName: String?,
                                   lastName: String?,
                                   gender: String?,
                                   birthday: Date?,
                                   physicalAddress: Address?,
                                   mailingAddress: Address?,
                                   hdid: String?,
                                   authenticated: Bool) -> Patient? {
        if (phn != nil) || (birthday != nil && name != nil) {
            return savePatient(
                name: name,
                firstName: firstName,
                lastName: lastName,
                gender: gender,
                birthday: birthday,
                phn: phn,
                physicalAddress: physicalAddress,
                mailingAddress: mailingAddress,
                hdid: hdid,
                authenticated: authenticated)
        }
        
        return nil
    }
    
    func createAndReturnAddress(addressDetails: AuthenticatedPatientDetailsResponseObject.Address?) -> Address? {
        guard let context = managedContext else {return nil}
        let address = Address(context: context)
        address.streetLines = addressDetails?.streetLines
        address.city = addressDetails?.city
        address.state = addressDetails?.state
        address.postalCode = addressDetails?.postalCode
        address.country = addressDetails?.country
        return address
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
