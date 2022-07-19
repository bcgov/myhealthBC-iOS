//
//  ImmunizationAgent+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-07-05.
//
//

import Foundation
import CoreData


extension ImmunizationAgent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImmunizationAgent> {
        return NSFetchRequest<ImmunizationAgent>(entityName: "ImmunizationAgent")
    }

    @NSManaged public var code: String?
    @NSManaged public var lotNumber: String?
    @NSManaged public var name: String?
    @NSManaged public var productName: String?
    @NSManaged public var immunizationDetails: ImmunizationDetails?

}
