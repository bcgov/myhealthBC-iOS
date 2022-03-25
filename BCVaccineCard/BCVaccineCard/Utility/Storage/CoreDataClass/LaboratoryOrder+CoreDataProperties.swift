//
//  LaboratoryOrder+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-02-22.
//
//

import Foundation
import CoreData


extension LaboratoryOrder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LaboratoryOrder> {
        return NSFetchRequest<LaboratoryOrder>(entityName: "LaboratoryOrder")
    }

    @NSManaged public var id: String?
    @NSManaged public var authenticated: Bool
    @NSManaged public var labPdfId: String?
    @NSManaged public var reportingSource: String?
    @NSManaged public var reportID: String?
    @NSManaged public var collectionDateTime: Date?
    @NSManaged public var commonName: String?
    @NSManaged public var orderingProvider: String?
    @NSManaged public var testStatus: String?
    @NSManaged public var reportAvailable: Bool
    @NSManaged public var laboratoryTests: NSSet?
    @NSManaged public var patient: Patient?
    @NSManaged public var pdf: String?

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
