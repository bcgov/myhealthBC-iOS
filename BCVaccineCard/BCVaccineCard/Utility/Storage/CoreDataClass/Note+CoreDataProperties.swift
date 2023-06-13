//
//  Note+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-06.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: String?
    @NSManaged public var hdid: String?
    @NSManaged public var title: String?
    @NSManaged public var text: String?
    @NSManaged public var journalDate: Date?
    @NSManaged public var version: Int64
    @NSManaged public var createdDateTime: Date?
    @NSManaged public var createdBy: String?
    @NSManaged public var updatedDateTime: Date?
    @NSManaged public var updatedBy: String?
    @NSManaged public var addedToTimeline: Bool
//    @NSManaged public var patient: Patient?

}
