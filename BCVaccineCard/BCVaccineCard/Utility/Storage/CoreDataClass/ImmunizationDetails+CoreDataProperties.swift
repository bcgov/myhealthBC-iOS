//
//  ImmunizationDetails+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-08-23.
//
//

import Foundation
import CoreData


extension ImmunizationDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImmunizationDetails> {
        return NSFetchRequest<ImmunizationDetails>(entityName: "ImmunizationDetails")
    }

    @NSManaged public var name: String?
    @NSManaged public var immunization: Immunization?
    @NSManaged public var immunizationAgents: NSSet?
    @NSManaged public var recommendation: ImmunizationRecommendation?

}

// MARK: Generated accessors for immunizationAgents
extension ImmunizationDetails {

    @objc(addImmunizationAgentsObject:)
    @NSManaged public func addToImmunizationAgents(_ value: ImmunizationAgent)

    @objc(removeImmunizationAgentsObject:)
    @NSManaged public func removeFromImmunizationAgents(_ value: ImmunizationAgent)

    @objc(addImmunizationAgents:)
    @NSManaged public func addToImmunizationAgents(_ values: NSSet)

    @objc(removeImmunizationAgents:)
    @NSManaged public func removeFromImmunizationAgents(_ values: NSSet)

}
