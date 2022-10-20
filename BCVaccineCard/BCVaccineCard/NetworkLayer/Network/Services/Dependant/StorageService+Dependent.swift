//
//  StorageService+Dependent.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-19.
//

import Foundation

extension StorageService {
    
    func store(dependents: [RemoteDependents], for patient: Patient, completion: @escaping([Patient])->Void) {
        var storedPatients: [Patient] = []
        for dependent in dependents {
            let firstName = dependent.dependentInformation?.firstname ?? ""
            let lastName = dependent.dependentInformation?.lastname ?? ""
            
            if let storedPatient = storePatient(
                name: firstName + " " + lastName,
                birthday: dependent.dependentInformation?.dateOfBirth?.getGatewayDate(),
                phn: dependent.dependentInformation?.phn,
                hdid: dependent.dependentInformation?.hdid,
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
