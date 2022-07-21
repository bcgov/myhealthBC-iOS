//
//  StorageService+HealthVisits.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-07-12.
//

import Foundation
protocol StorageHealthVisitsManager {
    
    // MARK: Store
    func storeHealthVisit(
        patient: Patient,
        object: AuthenticatedHealthVisitsResponseObject.HealthVisit,
        authenticated: Bool
    ) -> HealthVisit?
    

    // MARK: Fetch
    func fetchHealthVisits()-> [HealthVisit]
}
extension StorageService: StorageHealthVisitsManager {
    func storeHealthVisit(patient: Patient, object: AuthenticatedHealthVisitsResponseObject.HealthVisit, authenticated: Bool) -> HealthVisit? {
        return storeHealthVisit(authenticated: authenticated, id: object.id, encounterDate:  getGatewayDate(from: object.encounterDate), specialtyDescription: object.specialtyDescription, practitionerName: object.practitionerName, clinicName: object.clinic?.name, patient: patient)
    }
    
    private func storeHealthVisit(
        authenticated: Bool,
        id: String?,
        encounterDate: Date?,
        specialtyDescription: String?,
        practitionerName: String?,
        clinicName: String?,
        patient: Patient?
    ) -> HealthVisit? {
        guard let context = managedContext else {return nil}
        let visit = HealthVisit(context: context)
        let clinic = HealthVisitClinic(context: context)
        clinic.name = clinicName
        visit.authenticated = authenticated
        visit.id = id
        visit.encounterDate = encounterDate
        visit.specialtyDescription = specialtyDescription
        visit.practitionerName = practitionerName
        visit.patient = patient
        visit.clinic = clinic
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .HealthVisit, object: visit))
            return visit
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    
    func fetchHealthVisits() -> [HealthVisit] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(HealthVisit.fetchRequest())
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
    
    
}
