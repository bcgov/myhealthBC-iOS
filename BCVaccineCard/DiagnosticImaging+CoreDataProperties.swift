//
//  DiagnosticImaging+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-05-23.
//
//

import Foundation
import CoreData


extension DiagnosticImaging {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiagnosticImaging> {
        return NSFetchRequest<DiagnosticImaging>(entityName: "DiagnosticImaging")
    }

    @NSManaged public var bodyPart: String?
    @NSManaged public var examDate: Date?
    @NSManaged public var examStatus: String?
    @NSManaged public var fileID: String?
    @NSManaged public var healthAuthority: String?
    @NSManaged public var id: String?
    @NSManaged public var itemType: String?
    @NSManaged public var modality: String?
    @NSManaged public var organization: String?
    @NSManaged public var procedureDescription: String?
    @NSManaged public var type: String?
    @NSManaged public var isObjectUpdated: Bool
    @NSManaged public var patient: Patient?
    @NSManaged public var comments: NSSet?

}

// MARK: Generated accessors for comments
extension DiagnosticImaging {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
