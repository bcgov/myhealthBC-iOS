//
//  LaboratoryOrder+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-10-03.
//
//

import Foundation
import CoreData


extension LaboratoryOrder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LaboratoryOrder> {
        return NSFetchRequest<LaboratoryOrder>(entityName: "LaboratoryOrder")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var collectionDateTime: Date?
    @NSManaged public var commonName: String?
    @NSManaged public var id: String?
    @NSManaged public var labPdfId: String?
    @NSManaged public var orderingProvider: String?
    @NSManaged public var orderStatus: String?
    @NSManaged public var pdf: String?
    @NSManaged public var reportAvailable: Bool
    @NSManaged public var reportID: String?
    @NSManaged public var reportingSource: String?
    @NSManaged public var testStatus: String?
    @NSManaged public var timelineDateTime: Date?
    @NSManaged public var laboratoryTests: NSSet?
    @NSManaged public var patient: Patient?
    @NSManaged public var comments: NSSet?

}

// MARK: Generated accessors for laboratoryTests
extension LaboratoryOrder {

    @objc(addLaboratoryTestsObject:)
    @NSManaged public func addToLaboratoryTests(_ value: LaboratoryTest)

    @objc(removeLaboratoryTestsObject:)
    @NSManaged public func removeFromLaboratoryTests(_ value: LaboratoryTest)

    @objc(addLaboratoryTests:)
    @NSManaged public func addToLaboratoryTests(_ values: NSSet)

    @objc(removeLaboratoryTests:)
    @NSManaged public func removeFromLaboratoryTests(_ values: NSSet)

}

// MARK: Generated accessors for comments
extension LaboratoryOrder {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
