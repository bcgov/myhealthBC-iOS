//
//  ImmunizationForecast+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-07-19.
//
//

import Foundation
import CoreData


extension ImmunizationForecast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImmunizationForecast> {
        return NSFetchRequest<ImmunizationForecast>(entityName: "ImmunizationForecast")
    }

    @NSManaged public var recommendationID: String?
    @NSManaged public var createDate: Date?
    @NSManaged public var status: String?
    @NSManaged public var displayName: String?
    @NSManaged public var eligibleDate: Date?
    @NSManaged public var dueDate: Date?
    @NSManaged public var immunization: Immunization?

}
