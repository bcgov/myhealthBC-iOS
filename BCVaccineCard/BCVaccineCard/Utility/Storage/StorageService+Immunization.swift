//
//  StorageService+Immunization.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-07-06.
//

import Foundation
protocol StorageImmunizationManager {
    
    // MARK: Store
    func storeImmunization(
        patient: Patient,
        object: AuthenticatedImmunizationsResponseObject.ResourcePayload.Immunization,
        authenticated: Bool
    ) -> Immunization?
    

    // MARK: Fetch
    func fetchImmunization()-> [Immunization]
}
extension StorageService: StorageImmunizationManager {
    func storeImmunization(patient: Patient, object: AuthenticatedImmunizationsResponseObject.ResourcePayload.Immunization, authenticated: Bool) -> Immunization? {
        let detailsObject: ImmunizationDetails?
        if let details = object.immunizationDetails {
            detailsObject = storeImmunizationDetails(object: details)
        } else {
            detailsObject = nil
        }
        
        var dateOfImmunization: Date?
        
        if let timezoneDate = Date.Formatter.gatewayDateAndTimeWithTimeZone.date(from: object.dateOfImmunization ?? "") {
            dateOfImmunization = timezoneDate
        } else if let nozoneDate = Date.Formatter.gatewayDateAndTime.date(from: object.dateOfImmunization ?? "") {
            dateOfImmunization = nozoneDate
        }
        return storeImmunization(
            patient: patient,
            id: object.id,
            dateOfImmunization: dateOfImmunization,
            providerOrClinic: object.providerOrClinic,
            status: object.status,
            targetedDisease: object.targetedDisease,
            valid: object.valid,
            immunizationDetails: detailsObject,
            authenticated: authenticated
            )
                                                     
    }
    
    func storeImmunization(
        patient: Patient,
        id: String?,
        dateOfImmunization: Date?,
        providerOrClinic: String?,
        status: String?,
        targetedDisease: String?,
        valid: Bool?,
        immunizationDetails: ImmunizationDetails?,
        authenticated: Bool
    ) -> Immunization? {
        guard let context = managedContext else {return nil}
        let immunization = Immunization(context: context)
        immunization.id = id
        immunization.dateOfImmunization = dateOfImmunization
        immunization.providerOrClinic = providerOrClinic
        immunization.status = status
        immunization.targetedDisease = targetedDisease
        immunization.valid = valid ?? false
        immunization.immunizationDetails = immunizationDetails
        immunization.authenticated = authenticated
        immunization.patient = patient
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .Immunization, object: immunization))
            return immunization
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    private func storeImmunizationDetails(object: AuthenticatedImmunizationsResponseObject.ResourcePayload.ImmunizationDetails) -> ImmunizationDetails? {
        return storeImmunizationDetails(name: object.name, immunizationAgents: object.immunizationAgents ?? [])
    }

    private func storeImmunizationDetails(
        name: String?,
        immunizationAgents: [AuthenticatedImmunizationsResponseObject.ResourcePayload.ImmunizationDetails.ImmunizationAgent]?
    ) -> ImmunizationDetails? {
        guard let context = managedContext else {return nil}
        let detailsObject = ImmunizationDetails(context: context)
        detailsObject.name = name
        if let immunizationAgents = immunizationAgents {
            for agent in immunizationAgents {
                let object = ImmunizationAgent(context: context)
                object.code = agent.code
                object.name = agent.name
                object.lotNumber = agent.lotNumber
                object.productName = agent.productName
                detailsObject.addToImmunizationAgents(object)
            }
        }
        do {
            try context.save()
            return detailsObject
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    func fetchImmunization() -> [Immunization] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(Immunization.fetchRequest())
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
}
