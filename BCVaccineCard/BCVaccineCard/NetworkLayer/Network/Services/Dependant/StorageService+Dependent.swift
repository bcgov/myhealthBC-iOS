//
//  StorageService+Dependent.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-19.
//

import Foundation

extension StorageService {
    
    func store(dependents: [DependentInformation], for patient: Patient, completion: @escaping([Patient])->Void) {
        var storedPatients: [Patient] = []
        for dependent in dependents {
            let firstName = dependent.firstname ?? ""
            let lastName = dependent.lastname ?? ""
            
            if let storedPatient = storePatient(
                name: firstName + " " + lastName,
                birthday: dependent.dateOfBirth?.getGatewayDate(),
                phn: dependent.phn,
                hdid: dependent.hdid,
                authenticated: false) {
                storedPatients.append(storedPatient)
            }
        }
        add(dependents: storedPatients, to: patient)
        return completion(storedPatients)
    }
    
    func add(dependents: [Patient], to patient: Patient) {
        for dependent in dependents {
            addDependent(dependent: dependent, to: patient)
        }
    }
    
    func addDependent(dependent: Patient, to patient: Patient) {
        guard let context = managedContext else {return}
        patient.addToDependents(dependent)
        do {
            try context.save()
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return
        }
    }
}
