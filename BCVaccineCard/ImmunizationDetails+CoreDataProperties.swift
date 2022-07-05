//
//  ImmunizationDetails+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-07-05.
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
    @NSManaged public var immunizationAgents: ImmunizationAgent?

}
