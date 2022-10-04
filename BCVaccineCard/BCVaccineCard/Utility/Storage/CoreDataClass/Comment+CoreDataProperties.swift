//
//  Comment+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-10-03.
//
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var createdBy: String?
    @NSManaged public var createdDateTime: Date?
    @NSManaged public var entryTypeCode: String?
    @NSManaged public var id: String?
    @NSManaged public var parentEntryID: String?
    @NSManaged public var text: String?
    @NSManaged public var updatedBy: String?
    @NSManaged public var updatedDateTime: Date?
    @NSManaged public var userProfileID: String?
    @NSManaged public var version: Int64
    @NSManaged public var prescription: NSSet?
    @NSManaged public var laboratoryOrder: LaboratoryOrder?
    @NSManaged public var specialAuthorityDrug: SpecialAuthorityDrug?
    @NSManaged public var healthVIsit: HealthVisit?
    @NSManaged public var covidLabTestResult: CovidLabTestResult?

}

// MARK: Generated accessors for prescription
extension Comment {

    @objc(addPrescriptionObject:)
    @NSManaged public func addToPrescription(_ value: Perscription)

    @objc(removePrescriptionObject:)
    @NSManaged public func removeFromPrescription(_ value: Perscription)

    @objc(addPrescription:)
    @NSManaged public func addToPrescription(_ values: NSSet)

    @objc(removePrescription:)
    @NSManaged public func removeFromPrescription(_ values: NSSet)

}
