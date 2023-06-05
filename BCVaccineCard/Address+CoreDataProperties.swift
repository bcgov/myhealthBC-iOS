//
//  Address+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-05-23.
//
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var state: String?
    @NSManaged public var streetLines: [String]?

}
