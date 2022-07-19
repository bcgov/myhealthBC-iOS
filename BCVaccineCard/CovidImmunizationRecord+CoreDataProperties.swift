//
//  CovidImmunizationRecord+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-07-05.
//
//

import Foundation
import CoreData


extension CovidImmunizationRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CovidImmunizationRecord> {
        return NSFetchRequest<CovidImmunizationRecord>(entityName: "CovidImmunizationRecord")
    }

    @NSManaged public var date: Date?
    @NSManaged public var lotNumber: String?
    @NSManaged public var provider: String?
    @NSManaged public var snomed: String?
    @NSManaged public var vaccineCard: VaccineCard?

}
