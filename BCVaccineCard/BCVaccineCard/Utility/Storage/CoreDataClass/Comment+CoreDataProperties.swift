//
//  Comment+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-03-04.
//
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var id: String?
    @NSManaged public var userProfileID: String?
    @NSManaged public var text: String?
    @NSManaged public var entryTypeCode: String?
    @NSManaged public var parentEntryID: String?
    @NSManaged public var version: Int64
    @NSManaged public var createdDateTime: Date?
    @NSManaged public var updatedDateTime: Date?
    @NSManaged public var updatedBy: String?
    @NSManaged public var immunization: ImmunizationRecord?

}
