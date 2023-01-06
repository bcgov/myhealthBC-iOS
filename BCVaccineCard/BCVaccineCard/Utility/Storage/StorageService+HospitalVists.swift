//
//  StorageService+HospitalVists.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-05.
//

import Foundation

protocol StorageHospitalVisitsManager {
    
    // MARK: Store
    func storeHospitalVisits(
        patient: Patient,
        objects: [HospitalVisitsResponse],
        authenticated: Bool
    ) -> [HospitalVisit]
    

    // MARK: Fetch
    func fetchHospitalVisits()-> [HospitalVisit]
}

extension StorageService: StorageHospitalVisitsManager {
    func storeHospitalVisits(patient: Patient, objects: [HospitalVisitsResponse], authenticated: Bool) -> [HospitalVisit] {
        var storedObjects: [HospitalVisit] = []
        for visit in objects {
            if let stored = storeHospitalVisit(id: visit.id,
                                               encounterDate: visit.encounterDate.getGatewayDate(),
                                               specialtyDescription: visit.specialtyDescription,
                                               practitionerName: visit.practitionerName,
                                               clinicName: visit.clinic.name,
                                               authenticated: authenticated,
                                               patient: patient)
            {
                storedObjects.append(stored)
            }
            
        }
        return storedObjects
    }
    
    private func storeHospitalVisit(
        id: String?,
        encounterDate: Date?,
        specialtyDescription: String?,
        practitionerName: String?,
        clinicName: String?,
        authenticated: Bool,
        patient: Patient?
    ) -> HospitalVisit? {
        guard let context = managedContext else {return nil}
        let visit = HospitalVisit(context: context)
        let clinic = HospitalVisitClinic(context: context)
        clinic.name = clinicName
        visit.id = id
        visit.encounterDate = encounterDate
        visit.specialtyDescription = specialtyDescription
        visit.practitionerName = practitionerName
        visit.patient = patient
        visit.authenticated = authenticated
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .HospitalVisit, object: visit))
            return visit
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    
    func fetchHospitalVisits() -> [HospitalVisit] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(HospitalVisit.fetchRequest())
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
}
