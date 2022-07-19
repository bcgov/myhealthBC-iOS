//
//  VaccineCard+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-01-07.
//
//

import Foundation
import CoreData


extension VaccineCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VaccineCard> {
        return NSFetchRequest<VaccineCard>(entityName: "VaccineCard")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var code: String?
    @NSManaged public var federalPass: String?
    @NSManaged public var firHash: String?
    @NSManaged public var issueDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var sortOrder: Int64
    @NSManaged public var vaxDates: [String]?
    @NSManaged public var immunizationRecord: NSSet?
    @NSManaged public var patient: Patient?

}

// MARK: Generated accessors for immunizationRecord
extension VaccineCard {

    @objc(addImmunizationRecordObject:)
    @NSManaged public func addToImmunizationRecord(_ value: CovidImmunizationRecord)

    @objc(removeImmunizationRecordObject:)
    @NSManaged public func removeFromImmunizationRecord(_ value: CovidImmunizationRecord)

    @objc(addImmunizationRecord:)
    @NSManaged public func addToImmunizationRecord(_ values: NSSet)

    @objc(removeImmunizationRecord:)
    @NSManaged public func removeFromImmunizationRecord(_ values: NSSet)

}
