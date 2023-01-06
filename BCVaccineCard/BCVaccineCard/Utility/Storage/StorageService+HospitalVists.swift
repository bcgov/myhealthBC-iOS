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
    func storeHospitalVisits(patient: Patient,
                             objects: [HospitalVisitsResponse],
                             authenticated: Bool
    ) -> [HospitalVisit] {
        var storedObjects: [HospitalVisit] = []
        for visit in objects {
            if let stored = storeHospitalVisit(encounterID: visit.encounterID,
                                               facility: visit.facility,
                                               healthService: visit.healthService,
                                               visitType: visit.visitType,
                                               healthAuthority: visit.healthAuthority,
                                               admitDateTime: visit.admitDateTime?.getGatewayDate(),
                                               endDateTime: visit.endDateTime?.getGatewayDate(),
                                               provider: visit.provider,
                                               patient: patient,
                                               authenticated: authenticated)
            {
                storedObjects.append(stored)
            }
            
        }
        return storedObjects
    }
    
    private func storeHospitalVisit(
        encounterID: String?,
        facility: String?,
        healthService: String?,
        visitType: String?,
        healthAuthority: String?,
        admitDateTime: Date?,
        endDateTime: Date?,
        provider: String?,
        patient: Patient?,
        authenticated: Bool
    ) -> HospitalVisit? {
        guard let context = managedContext else {return nil}
        let visit = HospitalVisit(context: context)
        visit.encounterID = encounterID
        visit.facility = facility
        visit.healthService = healthService
        visit.visitType = visitType
        visit.admitDateTime = admitDateTime
        visit.endDateTime = endDateTime
        visit.provider = provider
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
