//
//  ImmunizationRecord+CoreDataProperties.swift
//  
//
//  Created by Amir on 2021-11-30.
//
//

import Foundation
import CoreData


extension ImmunizationRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImmunizationRecord> {
        return NSFetchRequest<ImmunizationRecord>(entityName: "ImmunizationRecord")
    }

    @NSManaged public var snomed: String?
    @NSManaged public var date: Date?
    @NSManaged public var provider: String?
    @NSManaged public var lotNumber: String?
    @NSManaged public var vaccineCard: VaccineCard?

}
