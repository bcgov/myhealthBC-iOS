//
//  Immunization+CoreDataProperties.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2022-07-05.
//
//

import Foundation
import CoreData


extension Immunization {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Immunization> {
        return NSFetchRequest<Immunization>(entityName: "Immunization")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var dateOfImmunization: Date?
    @NSManaged public var id: String?
    @NSManaged public var providerOrClinic: String?
    @NSManaged public var status: String?
    @NSManaged public var targetedDisease: String?
    @NSManaged public var valid: Bool
    @NSManaged public var immunizationDetails: ImmunizationDetails?
    @NSManaged public var patient: Patient?

}
