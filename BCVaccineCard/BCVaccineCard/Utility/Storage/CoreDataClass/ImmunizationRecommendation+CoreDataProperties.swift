//
//  ImmunizationRecommendation+CoreDataProperties.swift
//  
//
//  Created by Connor Ogilvie on 2022-09-29.
//
//

import Foundation
import CoreData


extension ImmunizationRecommendation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImmunizationRecommendation> {
        return NSFetchRequest<ImmunizationRecommendation>(entityName: "ImmunizationRecommendation")
    }

    @NSManaged public var agentDueDate: Date?
    @NSManaged public var agentEligibleDate: Date?
    @NSManaged public var authenticated: Bool
    @NSManaged public var diseaseDueDate: Date?
    @NSManaged public var diseaseEligibleDate: Date?
    @NSManaged public var recommendationSetID: String?
    @NSManaged public var recommendedVaccinations: String?
    @NSManaged public var status: String?
    @NSManaged public var immunizationDetail: ImmunizationDetails?
    @NSManaged public var patient: Patient?
    @NSManaged public var targetDiseases: NSSet?

}

// MARK: Generated accessors for targetDiseases
extension ImmunizationRecommendation {

    @objc(addTargetDiseasesObject:)
    @NSManaged public func addToTargetDiseases(_ value: ImmunizationTargetDisease)

    @objc(removeTargetDiseasesObject:)
    @NSManaged public func removeFromTargetDiseases(_ value: ImmunizationTargetDisease)

    @objc(addTargetDiseases:)
    @NSManaged public func addToTargetDiseases(_ values: NSSet)

    @objc(removeTargetDiseases:)
    @NSManaged public func removeFromTargetDiseases(_ values: NSSet)

}
