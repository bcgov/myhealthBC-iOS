//
//  StorageService+Recommendations.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-08-23.
//

import Foundation
protocol StorageImmunizationRecommendationManager {
    
    // MARK: Store
    func storeRecommendation(
        patient: Patient,
        object: AuthenticatedImmunizationsResponseObject.ResourcePayload.Recommendation,
        authenticated: Bool
    ) -> ImmunizationRecommendation?
    

    // MARK: Fetch
    func fetchRecommendations()-> [ImmunizationRecommendation]
}
extension StorageService: StorageImmunizationRecommendationManager {
    func storeRecommendation(
        patient: Patient,
        object: AuthenticatedImmunizationsResponseObject.ResourcePayload.Recommendation,
        authenticated: Bool
    ) -> ImmunizationRecommendation? {
        
        let detailsObject: ImmunizationDetails?
        if let details = object.immunization {
            detailsObject = storeImmunizationDetails(object: details)
        } else {
            detailsObject = nil
        }
        
        var targetDiseases: [ImmunizationTargetDisease] = []
        if let payloadDiseases = object.targetDiseases {
            for disease in payloadDiseases {
                if let storedDisease = storeTargetDisease(code: disease.code, name: disease.name) {
                    targetDiseases.append(storedDisease)
                }
            }
        }
        
        return storeRecommendation(
            authenticated: authenticated,
            agentDueDate: getGatewayDate(from: object.agentDueDate),
            agentEligibleDate: getGatewayDate(from: object.agentEligibleDate),
            diseaseDueDate: getGatewayDate(from: object.diseaseDueDate),
            diseaseEligibleDate: getGatewayDate(from: object.diseaseEligibleDate),
            recommendationSetID: object.recommendationSetID,
            recommendedVaccinations: object.recommendedVaccinations,
            status: object.status,
            immunizationDetail: detailsObject,
            targetDiseases: targetDiseases,
            patient: patient
        )
    }
    
    func storeRecommendation(
    authenticated: Bool,
    agentDueDate: Date?,
    agentEligibleDate: Date?,
    diseaseDueDate: Date?,
    diseaseEligibleDate: Date?,
    recommendationSetID: String?,
    recommendedVaccinations: String?,
    status: String?,
    immunizationDetail: ImmunizationDetails?,
    targetDiseases: [ImmunizationTargetDisease],
    patient: Patient?
    ) ->  ImmunizationRecommendation? {
        guard let context = managedContext else {return nil}
        let object = ImmunizationRecommendation(context: context)
        object.authenticated = authenticated
        object.agentDueDate = agentDueDate
        object.agentEligibleDate = agentEligibleDate
        object.diseaseDueDate = diseaseDueDate
        object.diseaseEligibleDate = diseaseEligibleDate
        object.recommendationSetID = recommendationSetID
        object.recommendationVaccinations = recommendedVaccinations
        object.status = status
        object.immunizationDetail = immunizationDetail
        object.patient = patient
        for targetDisease in targetDiseases {
            object.addToTargetDiseases(targetDisease)
        }
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .Recommendation, object: object))
            return object
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    private func storeTargetDisease(code: String?, name: String?) -> ImmunizationTargetDisease? {
        guard let context = managedContext else {return nil}
        let object = ImmunizationTargetDisease(context: context)
        object.code = code
        object.name = name
        do {
            try context.save()
            return object
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    func fetchRecommendations() -> [ImmunizationRecommendation] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(ImmunizationRecommendation.fetchRequest())
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
    
}
