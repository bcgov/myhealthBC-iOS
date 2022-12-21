//
//  StorageService+Immunization.swift
//  HealthGatewayTest
//
//  Created by Amir on 2022-07-06.
//

import Foundation
protocol StorageImmunizationManager {
    
    // MARK: Store
    func storeImmunizations(
        patient: Patient,
        in: AuthenticatedImmunizationsResponseObject.ResourcePayload,
        authenticated: Bool
    ) -> [Immunization]
    
    func storeImmunization(
        patient: Patient,
        object: AuthenticatedImmunizationsResponseObject.ResourcePayload.Immunization,
        authenticated: Bool
    ) -> Immunization?
    

    // MARK: Fetch
    func fetchImmunization()-> [Immunization]
    
    // MARK: Remove Covid Records
    func removeCovidImmunizationDuplicates()
}
extension StorageService: StorageImmunizationManager {
    
    func storeImmunizations(patient: Patient, in object: AuthenticatedImmunizationsResponseObject.ResourcePayload, authenticated: Bool) -> [Immunization] {
        guard let imms = object.immunizations else {return []}
        var stored: [Immunization] = []
        for immObject in imms {
            if let storedObject = storeImmunization (patient: patient, object: immObject, authenticated: authenticated) {
                stored.append(storedObject)
            }
        }
        return stored
    }
    
    func storeImmunization(patient: Patient, object: AuthenticatedImmunizationsResponseObject.ResourcePayload.Immunization, authenticated: Bool) -> Immunization? {
        let detailsObject: ImmunizationDetails?
        if let details = object.immunizationDetails {
            detailsObject = storeImmunizationDetails(object: details)
        } else {
            detailsObject = nil
        }
        
        // TODO: UNCOMMENT TO ENABLE FORECAST
        let immForecast: ImmunizationForecast?
        if let remoteForecast = object.forecast, let forecast = storeImmunizationForecast(object: remoteForecast) {
            immForecast = forecast
        } else {
            immForecast = nil
        }
//        let immForecast: ImmunizationForecast? = nil
        
        
        return storeImmunization(
            patient: patient,
            id: object.id,
            dateOfImmunization: getGatewayDate(from: object.dateOfImmunization),
            providerOrClinic: object.providerOrClinic,
            status: object.status,
            targetedDisease: object.targetedDisease,
            valid: object.valid,
            immunizationDetails: detailsObject,
            forecast: immForecast,
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
        forecast: ImmunizationForecast?,
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
        immunization.forecast = forecast
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .Immunization, object: immunization))
            return immunization
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    func storeImmunizationDetails(object: AuthenticatedImmunizationsResponseObject.ResourcePayload.ImmunizationDetails) -> ImmunizationDetails? {
        return storeImmunizationDetails(name: object.name, immunizationAgents: object.immunizationAgents ?? [])
    }
    
    private func storeImmunizationForecast(object: AuthenticatedImmunizationsResponseObject.ResourcePayload.Immunization.Forecast) -> ImmunizationForecast? {
        return storeImmunizationForecast(
            recommendationID: object.recommendationID,
            createDate: getGatewayDate(from: object.createDate),
            status: object.status,
            displayName: object.displayName,
            eligibleDate: getGatewayDate(from: object.eligibleDate),
            dueDate: getGatewayDate(from: object.dueDate)
        )
    }
    
    private func storeImmunizationForecast(
       recommendationID: String?,
       createDate: Date?,
       status: String?,
       displayName: String?,
       eligibleDate: Date?,
       dueDate: Date?
    ) -> ImmunizationForecast? {
        guard let context = managedContext else {return nil}
        let forecast = ImmunizationForecast(context: context)
        forecast.recommendationID = recommendationID
        forecast.createDate = createDate
        forecast.status = status
        forecast.displayName = displayName
        forecast.eligibleDate = eligibleDate
        forecast.dueDate = dueDate
        do {
            try context.save()
            return forecast
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
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
    
    func removeCovidImmunizationDuplicates() {
        let immz = fetchImmunization()
        let vaxCards = fetchVaccineCards()
        let covidImmz = vaxCards.flatMap { $0.immunizations }
        for covidIm in covidImmz {
            let sameDateObjects = immz.filter { $0.dateOfImmunization == covidIm.date }
            let sameLotNumberObjects = sameDateObjects.filter { immunization in
                if let immunizationAgents = immunization.immunizationDetails?.immunizationAgents as? Set<ImmunizationAgent> {
                    let lotNumbers = immunizationAgents.compactMap({ $0.lotNumber })
                    guard let lotNumber = covidIm.lotNumber else { return false }
                    return lotNumbers.contains(lotNumber)
                }
                return false
            }
            let objects = Set(sameLotNumberObjects)
            for object in objects {
                delete(object: object)
            }
        }
    }
}
