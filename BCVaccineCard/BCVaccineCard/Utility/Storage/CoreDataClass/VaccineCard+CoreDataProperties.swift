//
//  VaccineCard+CoreDataProperties.swift
//  
//
//  Created by Amir on 2021-12-02.
//
//

import Foundation
import CoreData


extension VaccineCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VaccineCard> {
        return NSFetchRequest<VaccineCard>(entityName: "VaccineCard")
    }

    @NSManaged public var birthdate: String?
    @NSManaged public var code: String?
    @NSManaged public var federalPass: String?
    @NSManaged public var firHash: String?
    @NSManaged public var issueDate: Double
    @NSManaged public var name: String?
    @NSManaged public var phn: String?
    @NSManaged public var sortOrder: Int64
    @NSManaged public var vaxDates: NSObject?
    @NSManaged public var immunizationRecord: NSSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for immunizationRecord
extension VaccineCard {

    @objc(addImmunizationRecordObject:)
    @NSManaged public func addToImmunizationRecord(_ value: ImmunizationRecord)

    @objc(removeImmunizationRecordObject:)
    @NSManaged public func removeFromImmunizationRecord(_ value: ImmunizationRecord)

    @objc(addImmunizationRecord:)
    @NSManaged public func addToImmunizationRecord(_ values: NSSet)

    @objc(removeImmunizationRecord:)
    @NSManaged public func removeFromImmunizationRecord(_ values: NSSet)

}
