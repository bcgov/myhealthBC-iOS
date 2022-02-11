//
//  Medication+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-02-10.
//
//

import Foundation
import CoreData


extension Medication {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medication> {
        return NSFetchRequest<Medication>(entityName: "Medication")
    }

    @NSManaged public var brandName: String?
    @NSManaged public var din: String?
    @NSManaged public var drugDiscontinuedDate: Date?
    @NSManaged public var form: String?
    @NSManaged public var genericName: String?
    @NSManaged public var isPin: Bool
    @NSManaged public var manufacturer: String?
    @NSManaged public var maxDailyDosage: Int64
    @NSManaged public var quantity: Double
    @NSManaged public var strength: String?
    @NSManaged public var strengthUnit: String?

}
