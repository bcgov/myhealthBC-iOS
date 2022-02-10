//
//  Pharmacy+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-02-10.
//
//

import Foundation
import CoreData


extension Pharmacy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pharmacy> {
        return NSFetchRequest<Pharmacy>(entityName: "Pharmacy")
    }

    @NSManaged public var addressLine1: String?
    @NSManaged public var addressLine2: String?
    @NSManaged public var city: String?
    @NSManaged public var countryCode: String?
    @NSManaged public var faxNumber: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var province: String?

}
