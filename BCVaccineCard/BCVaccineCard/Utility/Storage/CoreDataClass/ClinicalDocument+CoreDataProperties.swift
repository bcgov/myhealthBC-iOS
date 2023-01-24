//
//  ClinicalDocument+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2023-01-05.
//
//

import Foundation
import CoreData


extension ClinicalDocument {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClinicalDocument> {
        return NSFetchRequest<ClinicalDocument>(entityName: "ClinicalDocument")
    }

    @NSManaged public var id: String?
    @NSManaged public var fileID: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var facilityName: String?
    @NSManaged public var discipline: String?
    @NSManaged public var serviceDate: Date?
    @NSManaged public var authenticated: Bool
    @NSManaged public var patient: Patient?
    @NSManaged public var comments: NSSet?

}

// MARK: Generated accessors for comments
extension ClinicalDocument {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
