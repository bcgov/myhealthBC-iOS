//
//  CancerScreening+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2024-01-26.
//
//

import Foundation
import CoreData


extension CancerScreening {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CancerScreening> {
        return NSFetchRequest<CancerScreening>(entityName: "CancerScreening")
    }

    @NSManaged public var eventDateTime: Date?
    @NSManaged public var eventType: String?
    @NSManaged public var fileID: String?
    @NSManaged public var id: String?
    @NSManaged public var itemType: String?
    @NSManaged public var programName: String?
    @NSManaged public var resultDateTime: Date?
    @NSManaged public var type: String?
    @NSManaged public var comments: Comment?
    @NSManaged public var patient: Patient?

}

// MARK: Generated accessors for comments
extension CancerScreening {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
