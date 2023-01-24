//
//  Dependent+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2022-10-27.
//
//

import Foundation
import CoreData


extension Dependent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dependent> {
        return NSFetchRequest<Dependent>(entityName: "Dependent")
    }

    @NSManaged public var ownerID: String?
    @NSManaged public var delegateID: String?
    @NSManaged public var version: Int64
    @NSManaged public var reasonCode: Int64
    @NSManaged public var sortOrder: Int64
    @NSManaged public var guardian: Patient?
    @NSManaged public var info: Patient?

}
