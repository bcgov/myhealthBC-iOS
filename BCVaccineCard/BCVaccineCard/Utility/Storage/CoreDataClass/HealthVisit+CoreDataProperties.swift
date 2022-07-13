//
//  HealthVisit+CoreDataProperties.swift
//  
//
//  Created by Amir on 2022-07-12.
//
//

import Foundation
import CoreData


extension HealthVisit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HealthVisit> {
        return NSFetchRequest<HealthVisit>(entityName: "HealthVisit")
    }

    @NSManaged public var authenticated: Bool
    @NSManaged public var id: String?
    @NSManaged public var encounterDate: Date?
    @NSManaged public var specialtyDescription: String?
    @NSManaged public var practitionerName: String?
    @NSManaged public var clinic: HealthVisitClinic?
    @NSManaged public var patient: Patient?

}
