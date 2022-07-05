//
//  ImmunizationRecord+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-07-05.
//
//

import Foundation
import CoreData


extension ImmunizationRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImmunizationRecord> {
        return NSFetchRequest<ImmunizationRecord>(entityName: "ImmunizationRecord")
    }

    @NSManaged public var immunizations: Immunization?

}
