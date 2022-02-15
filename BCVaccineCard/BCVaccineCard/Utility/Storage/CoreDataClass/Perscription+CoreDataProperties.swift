//
//  Perscription+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-02-10.
//
//

import Foundation
import CoreData


extension Perscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Perscription> {
        return NSFetchRequest<Perscription>(entityName: "Perscription")
    }

    @NSManaged public var dateEntered: Date?
    @NSManaged public var directions: String?
    @NSManaged public var dispensedDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var prescriptionIdentifier: String?
    @NSManaged public var practitionerSurname: String?
    @NSManaged public var status: String?
    @NSManaged public var medication: Medication?
    @NSManaged public var pharmacy: Pharmacy?
    @NSManaged public var patient: Patient?
    @NSManaged public var authenticated: Bool

}
