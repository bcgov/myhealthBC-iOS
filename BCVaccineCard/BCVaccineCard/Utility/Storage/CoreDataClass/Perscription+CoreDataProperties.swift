//
//  Perscription+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-03-04.
//
//

import Foundation
import CoreData


extension Perscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Perscription> {
        return NSFetchRequest<Perscription>(entityName: "Perscription")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var dateEntered: Date?
    @NSManaged public var directions: String?
    @NSManaged public var dispensedDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var practitionerSurname: String?
    @NSManaged public var prescriptionIdentifier: String?
    @NSManaged public var status: String?
    @NSManaged public var medication: Medication?
    @NSManaged public var patient: Patient?
    @NSManaged public var pharmacy: Pharmacy?
    @NSManaged public var comments: NSSet?

}

// MARK: Generated accessors for comments
extension Perscription {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
