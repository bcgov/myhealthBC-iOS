//
//  SpecialAuthorityDrug+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-12-07.
//
//

import Foundation
import CoreData


extension SpecialAuthorityDrug {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpecialAuthorityDrug> {
        return NSFetchRequest<SpecialAuthorityDrug>(entityName: "SpecialAuthorityDrug")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var drugName: String?
    @NSManaged public var effectiveDate: Date?
    @NSManaged public var expiryDate: Date?
    @NSManaged public var prescriberFirstName: String?
    @NSManaged public var prescriberLastName: String?
    @NSManaged public var referenceNumber: String?
    @NSManaged public var requestedDate: Date?
    @NSManaged public var requestStatus: String?
    @NSManaged public var patient: Patient?
    @NSManaged public var comments: NSSet?

}

// MARK: Generated accessors for comments
extension SpecialAuthorityDrug {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
