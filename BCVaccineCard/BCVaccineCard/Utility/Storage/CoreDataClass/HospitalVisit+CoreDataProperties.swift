//
//  HospitalVisit+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2023-01-05.
//
//

import Foundation
import CoreData


extension HospitalVisit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HospitalVisit> {
        return NSFetchRequest<HospitalVisit>(entityName: "HospitalVisit")
    }

    @NSManaged public var facility: String?
    @NSManaged public var encounterID: String?
    @NSManaged public var visitType: String?
    @NSManaged public var healthService: String?
    @NSManaged public var authenticated: Bool
    @NSManaged public var healthAuthority: String?
    @NSManaged public var admitDateTime: Date?
    @NSManaged public var endDateTime: Date?
    @NSManaged public var provider: String?
    @NSManaged public var patient: Patient?
    @NSManaged public var comments: NSSet?

}

// MARK: Generated accessors for comments
extension HospitalVisit {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
