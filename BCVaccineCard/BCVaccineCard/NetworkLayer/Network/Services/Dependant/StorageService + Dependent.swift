//
//  StorageService + Dependent.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-01.
//

import Foundation

extension StorageService {
    
    func store(dependents: [RemoteDependent], for patient: Patient, completion: @escaping([Dependent])->Void) {
        var storedDependends: [Dependent] = []
        for dependent in dependents {
            
            if let info = dependent.dependentInformation,
               let versionInt = dependent.version,
               let reasonCodeInt = dependent.reasonCode,
               let totalDelegateCount = dependent.totalDelegateCount,
               let expiryDate = dependent.expiryDate
            {
                let firstName = info.firstname ?? ""
                let lastName = info.lastname ?? ""
                
                if let storedPatient = storePatient(
                    name: firstName + " " + lastName,
                    firstName: firstName,
                    lastName: lastName,
                    gender: info.gender,
                    birthday: info.dateOfBirth?.getGatewayDate(),
                    phn: info.phn,
                    hdid: info.hdid,
                    authenticated: false) {
                    if let storedDependent = storeDependent(ownerID: dependent.ownerID,
                                                            delegateID: dependent.delegateID,
                                                            version: Int64(versionInt),
                                                            reasonCode: Int64(reasonCodeInt),
                                                            totalDelegateCount: Int64(totalDelegateCount),
                                                            expiryDate: expiryDate.getGatewayDate(),
                                                            info: storedPatient)
                    {
                        storedDependends.append(storedDependent)
                    }
                }
            }
        }
        add(dependents: storedDependends, to: patient)
        return completion(storedDependends)
    }
    
    func storeDependent(
        ownerID: String?,
        delegateID: String?,
        version: Int64,
        reasonCode: Int64,
        totalDelegateCount: Int64,
        expiryDate: Date?,
        info: Patient
    ) -> Dependent? {
        guard let context = managedContext else {return nil}
        let dependent = Dependent(context: context)
        dependent.ownerID = ownerID
        dependent.delegateID = delegateID
        dependent.version = version
        dependent.reasonCode = reasonCode
        dependent.totalDelegateCount = totalDelegateCount
        dependent.expiryDate = expiryDate
        dependent.info = info
        do {
            try context.save()
            notify(event: StorageEvent(event: .Save, entity: .Dependent, object: dependent))
            return dependent
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    func add(dependents: [Dependent], to patient: Patient) {
        for dependent in dependents {
            addDependent(dependent: dependent, to: patient)
        }
    }
    
    func addDependent(dependent: Dependent, to patient: Patient) {
        guard let context = managedContext else {return}
        patient.addToDependents(dependent)
        do {
            try context.save()
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return
        }
    }
    
    func deleteDependents(for patient: Patient) {
        guard let context = managedContext else {return}
        guard let dependents = patient.dependents else {return}
        let dependentsArray = patient.dependentsArray
        patient.removeFromDependents(dependents)
        dependentsArray.forEach({delete(object: $0)})
        do {
            try context.save()
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return
        }
    }
    
    func delete(dependents: [Dependent], for patient: Patient) {
        guard let context = managedContext else {return}
        dependents.forEach({patient.removeFromDependents($0)})
        dependents.forEach({delete(object: $0)})
        do {
            try context.save()
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return
        }
    }
}
