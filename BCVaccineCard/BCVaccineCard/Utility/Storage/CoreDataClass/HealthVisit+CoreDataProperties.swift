//
//  HealthVisit+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-12-07.
//
//

import Foundation
import CoreData


extension HealthVisit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HealthVisit> {
        return NSFetchRequest<HealthVisit>(entityName: "HealthVisit")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var encounterDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var practitionerName: String?
    @NSManaged public var specialtyDescription: String?
    @NSManaged public var clinic: HealthVisitClinic?
    @NSManaged public var patient: Patient?
    @NSManaged public var comments: NSSet?

}

// MARK: Generated accessors for comments
extension HealthVisit {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
