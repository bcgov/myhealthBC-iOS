//
//  VaccineCard+CoreDataProperties.swift
//  
//
//  Created by Amir Shayegh on 2021-10-27.
//
//

import Foundation
import CoreData


extension VaccineCard {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<VaccineCard> {
        return NSFetchRequest<VaccineCard>(entityName: "VaccineCard")
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var sortOrder: Int64
    @NSManaged public var user: User?

}
